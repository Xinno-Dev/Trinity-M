
import 'dart:io';
import 'dart:convert' show utf8;

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart' as dv;
import 'package:googleapis/websecurityscanner/v1.dart';
import 'package:http/http.dart' as http;

import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../common/common_package.dart';
import '../common/const/utils/convertHelper.dart';
import '../common/const/utils/languageHelper.dart';
import '../common/const/utils/uihelper.dart';
import '../common/const/utils/userHelper.dart';
import '../common/const/widget/dialog_utils.dart';

GoogleSignInAccount? googleUser;
final dio = Dio();

class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;
  GoogleHttpClient(this._headers) : super();
  @override
  send(request) =>
      super.send(request..headers.addAll(_headers));
  @override
  head(Uri url, {Map<String, String>? headers}) =>
      super.head(url, headers: headers?..addAll(_headers));
}

class GoogleService extends GoogleAccount {

  static List<String> selectDir = [];
  static String? selectFile;
  static Map<String, List<dv.File>> dirListData = {};

  static init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        LOG('---> google sign out!');
      } else {
        LOG('---> google login!');
      }
    });
  }

  static signIn() async {
    // googleUser = await GoogleSignIn().signIn();
    googleUser = await GoogleSignIn(scopes: [
      'email', 'openid', 'profile', 'https://www.googleapis.com/auth/drive',
    ]).signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    final result = await FirebaseAuth.instance.signInWithCredential(credential);
    LOG('---> signIn result : $result');
    return result;
  }

  static signOut() async {
    try {
      // await FirebaseAuth.instance.signOut();
      GoogleSignIn().disconnect();
      return true;
    } catch (e) {
      LOG('--> signOut error : $e');
    }
    return false;
  }

  static userInfo() async {
    try {
      final user = await FirebaseAuth.instance.currentUser;
      LOG('---> userInfo : $user');
      return user;
    } catch (e) {
      LOG('--> userInfo error : $e');
    }
    return null;
  }

  //////////////////////////////////////////////////////////////////
  //
  // Google Drive Utils..
  //

  static uploadKeyToGoogleDrive(context, String title, String exportText) async {
    var formatter = DateFormat('yyyyMMdd');
    var fileName = '${title}_${formatter.format(DateTime.now())}.rwf';
    return await _startGoogleDriveUpload(context, exportText, fileName);
  }

  static downloadKeyFromGoogleDrive(context) async {
    return await _startGoogleDriveDownload(context, 'rwf');
  }

  static _startGoogleDriveUpload(context, desc, fileName) async {
    LOG('---> startGoogleDriveUpload RWF : $desc');
    if (googleUser != null) {
      var result = await _showDriveSelectDialog(context, true, ext: fileName);
      LOG('---> startGoogleDriveUpload result 1 : $result');
      if (STR(result).isNotEmpty) {
        return await _uploadToGoogleDrive(context, desc, fileName, parentId: folderId);
      }
      return result;
    } else {
      var user = await signIn();
      if (user != null) {
        var result = await _showDriveSelectDialog(context, true, ext: fileName);
        LOG('---> startGoogleDriveUpload result 2 : $result');
        if (STR(result).isNotEmpty) {
          return await _uploadToGoogleDrive(context, desc, fileName, parentId: folderId);
        }
      }
    }
  }

  // return Rwf text..
  static Future<String?> _startGoogleDriveDownload(context, ext) async {
    if (googleUser != null) {
      var result = await _showDriveSelectDialog(context, false, ext: ext);
      LOG('---> startGoogleDriveDownload result 1 : $result');
      if (STR(result).isNotEmpty) {
        return await _downloadFromGoogleDrive(context, result);
      }
      return result;
    } else {
      var user = await signIn();
      if (user != null) {
        var result = await _showDriveSelectDialog(context, false, ext: ext);
        LOG('---> startGoogleDriveDownload result 2 : $result');
        if (STR(result).isNotEmpty) {
          return await _downloadFromGoogleDrive(context, result);
        }
      }
    }
    return null;
  }

  static get folderTitle {
    return selectDir.isNotEmpty ? selectDir.last.split('&/').first : '/';
  }

  static get folderId {
    return selectDir.isNotEmpty ? selectDir.last.split('&/').last : 'root';
  }

  static Future<List<dv.File>> _getDriveFileList({bool isFolderOnly = false, String? ext}) async {
    LOG("--> _getDriveFileList : $folderId / ${dirListData.keys} / $isFolderOnly");
    if (dirListData.containsKey(folderId)) {
      return dirListData[folderId] as List<dv.File>;
    }
    if (isFolderOnly) {
      return await GoogleService.getDriveFolders(folderId);
    }
    return await GoogleService.getDriveFilesFromExt(ext);
  }

  static _showDriveSelectDialog(context, isUpload, {String? ext}) {
    selectDir.clear();
    dirListData.clear();
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(TR(isUpload ? '저장 위치 선택' : '복구 파일 선택'), style: typo16semibold),
            titlePadding: EdgeInsets.fromLTRB(20, 20, 10, 0),
            insetPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.fromLTRB(0, 0, 20, 5),
            contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpload)
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(TR('파일명'), style: typo12bold),
                        SizedBox(height: 5),
                        Text(STR(ext), style: typo14normal),
                      ],
                    ),
                  ),
                Text(TR('저장폴더'), style: typo12bold),
                SizedBox(height: 5),
                FutureBuilder(
                  future: _getDriveFileList(isFolderOnly: isUpload, ext: ext),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<DropdownMenuItem> dirList = snapshot.data!.map((e) =>
                          dirItem(e.title, '${e.title}&/${e.id}', isDir: isUpload)).toList();
                      dirListData[folderId] = snapshot.data as List<dv.File>;
                      if (isUpload) {
                        dirList.insert(0, dirItem(folderTitle, '[top]', isTop: true));
                        if (selectDir.isNotEmpty) {
                          dirList.insert(1, dirItem('..', '[back]'));
                        }
                      } else if (selectDir.isEmpty && dirList.isNotEmpty) {
                        selectDir.add(dirList.first.value);
                      }
                      return _driveSelectWidget(dirList,
                        selectValue: !isUpload ? selectDir.last : null,
                        onSelected: (select) {
                          setState(() {
                            if (select == '[back]') {
                              selectDir.removeLast();
                              LOG('---> back dir : ${selectDir.length}');
                            }
                            else if (select != '[top]' && (selectDir.isEmpty || selectDir.last != select)) {
                              LOG('---> selectDir add : $select / ${selectDir.length}');
                              selectDir.add(select);
                            }
                          });
                      });
                    } else {
                      return CircularProgressIndicator();
                    }
                  })
              ],
            ),
            actions: [
              TextButton(
                onPressed: context.pop,
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  LOG('---> select : $folderId');
                  context.pop(folderId);
                },
                child: Text(isUpload ? 'Upload' : 'Download'),
              ),
            ],
          );
        });
      }
    );
  }

  static _driveSelectWidget(List<DropdownMenuItem> list, {
    String? selectValue,
    Function(String)? onSelected,
  }) {
    LOG('--> _driveSelectWidget : $selectValue');
    return DropdownButton(
      value: selectValue ?? (list.isNotEmpty ? list.first.value : null),
      underline: Container(height: 1, color: GRAY_50),
      padding: EdgeInsets.symmetric(vertical: 5),
      items: list,
      isExpanded: true,
      menuMaxHeight: 800,
      onChanged: (value) {
        LOG('---> selected item : $value');
        if (onSelected != null) onSelected(value);
      },
    );
  }

  static DropdownMenuItem dirItem(text, value, {bool isTop = false, bool isDir = false}) {
    return DropdownMenuItem(
      child: Row(
        children: [
          if (isDir)
            Icon(isTop ? Icons.folder_open : Icons.folder, color: Colors.blueGrey),
          SizedBox(width: 7),
          Text(text, style: isTop ? typo16bold : null),
        ],
      ),
      value: value,
    );
  }

  static Future<List<dv.File>> getDriveFolders([String? parentId]) async {
    LOG('--> getDriveFolders : [$parentId]');
    return await getDriveFiles(
        parentId: parentId,
        query: "'${parentId ?? 'root'}' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false"
    );
  }

  static Future<List<dv.File>> getDriveFilesFromExt(ext) async {
    LOG('--> getDriveRwfFiles');
    List<dv.File> files = await getDriveFiles(
        query: "mimeType != 'application/vnd.google-apps.folder' and title contains '.${ext ?? 'rwf'}' and trashed = false"
    );
    return files;
  }

  static Future<List<dv.File>> getDriveFiles({String? parentId, String? query}) async {
    try {
      var client = GoogleHttpClient(await googleUser!.authHeaders);
      var drive = dv.DriveApi(client);
      var list = await drive.files.list(
        spaces: 'drive',
        q: query
      );
      if (list.items != null) {
        // for (var i = 0; i < list.items!.length; i++) {
        //   LOG("--> getDriveFiles item [${list.items![i].title}]: ${list.items![i]
        //       .mimeType}");
        // }
        return list.items ?? [];
      } else {
        LOG("--> list.items error: ${list.toJson()}");
      }
    } catch (e) {
      LOG("--> getDriveFiles error: $e");
    }
    return [];
  }

  // static _startUploadDrive(context, desc, fileName) async {
  //   LOG('---> _startUploadDrive : $folderId / $fileName / $desc');
  //   if (STR(folderId).isNotEmpty) {
  //     showLoadingDialog(context, '복구키를 백업중 입니다..');
  //     var parentId = folderId != 'root' ? folderId : null;
  //     var result = await uploadToGoogleDrive(
  //         desc, fileName: fileName, parentId: parentId);
  //     hideLoadingDialog();
  //     Fluttertoast.showToast(
  //         msg: result != null ? "복구키 백업 완료" : "복구키 백업 실패",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.black,
  //         textColor: result != null ? Colors.white : Colors.orange,
  //         fontSize: 16.0
  //     );
  //     return result != null;
  //   }
  //   return false;
  // }

  static Future<bool> _uploadToGoogleDrive(context, desc, fileName, {var parentId = ''}) async {
    LOG('--> _uploadToGoogleDrive : $desc / $parentId');
    var result = false;
    showLoadingDialog(context, '복구키를 백업중 입니다..');
    try {
      var client = GoogleHttpClient(await googleUser!.authHeaders);
      var drive = dv.DriveApi(client);
      dv.File fileToUpload = dv.File();
      var file = await openFile(fileName);
      file.writeAsStringSync(desc);
      LOG('--> _uploadToGoogleDrive file : ${file.path} / ${await file.length()}');
      fileToUpload.mimeType = ' application/vnd.google-apps.file';
      fileToUpload.title = fileName;
      if (parentId.isNotEmpty) {
        fileToUpload.parents = [
          dv.ParentReference(
            id: parentId,
          ),
        ];
      }
      var response = await drive.files.insert(
        fileToUpload,
        uploadMedia: dv.Media(file.openRead(), file.lengthSync()),
      );
      LOG('--> _uploadToGoogleDrive response [${file.path}] : ${response.toJson()}');
      file.delete();
      result = response.downloadUrl != null;
    } catch (e) {
      LOG('--> _uploadToGoogleDrive error : $e');
    }
    hideLoadingDialog();
    showToast(result ? "복구키 백업 완료" : "복구키 백업 실패");
    return result;
  }

  static Future<String?> _downloadFromGoogleDrive(context, fileId) async {
    LOG('--> _downloadFromGoogleDrive : $fileId');
    showLoadingDialog(context, '복구키를 내려받는 중 입니다..');
    String? rwfText;
    try {
      var client  = GoogleHttpClient(await googleUser!.authHeaders);
      var drive   = dv.DriveApi(client);
      var response = await drive.files.get(fileId, downloadOptions: dv.DownloadOptions.fullMedia);
      if (response is dv.Media) {
        var bytesArray = await response.stream.toList();
        List<int> bytes = [];
        for (var arr in bytesArray) {
          bytes.addAll(arr);
        }
        rwfText = utf8.decode(bytes);
        LOG('---> response rwfText : $rwfText');
      }
    } catch (e) {
      LOG('--> _downloadFromGoogleDrive error : $e');
    }
    hideLoadingDialog();
    showToast(rwfText != null ? "복구키 받기 완료" : "복구키 받기 실패");
    return rwfText;
  }

  static Future<String> get _directoryPath async {
    Directory? directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> openFile(String fileNameWithExtension) async {
    final path = await _directoryPath;
    return File("$path/$fileNameWithExtension");
  }
}