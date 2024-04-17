
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart' as dv;
import 'package:googleapis/websecurityscanner/v1.dart';

import 'package:http/io_client.dart';
import 'package:intl/intl.dart';
import 'package:larba_00/common/const/widget/dialog_utils.dart';
import 'package:larba_00/services/social_service.dart';
import 'package:path_provider/path_provider.dart';

import '../common/common_package.dart';
import '../common/const/utils/convertHelper.dart';
import '../common/const/utils/languageHelper.dart';

GoogleSignInAccount? googleUser;

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
  static Map<String, List<dv.File>> dirListData = {};

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

  static showUploadDriveDlg(context, desc, {bool isUpload = true}) async {
    var formatter = DateFormat('yyyyMMdd-HHmmss');
    var fileName = 'larba-mnemonic-${formatter.format(DateTime.now())}.rwf';
    if (googleUser != null) {
      var result = await _showDriveSelectDialog(context, isUpload);
      LOG('---> _showDriveSelectDialog result 1 : $result');
      if (STR(result).isNotEmpty) {
        return await _startUploadDrive(context, desc, fileName);
      }
      return result;
    } else {
      var user = await signIn();
      if (user != null) {
        var result = await _showDriveSelectDialog(context, isUpload);
        LOG('---> _showDriveSelectDialog result 2 : $result');
        if (STR(result).isNotEmpty) {
          return await _startUploadDrive(context, desc, fileName);
        }
      }
    }
  }

  static _startUploadDrive(context, desc, fileName) async {
    LOG('---> _startUploadDrive : $folderId / $fileName / $desc');
    if (STR(folderId).isNotEmpty) {
      showLoadingDialog(context, '복구키를 백업중 입니다..');
      var parentId = folderId != 'root' ? folderId : null;
      var result = await uploadToGoogleDrive(
          desc, fileName: fileName, parentId: parentId);
      hideLoadingDialog();
      Fluttertoast.showToast(
          msg: result != null ? "복구키 백업 완료" : "복구키 백업 실패",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: result != null ? Colors.white : Colors.orange,
          fontSize: 16.0
      );
      return result != null;
    }
    return false;
  }

  static get folderTitle {
    return selectDir.isNotEmpty ? selectDir.last.split('&/').first : '/';
  }

  static get folderId {
    return selectDir.isNotEmpty ? selectDir.last.split('&/').last : 'root';
  }

  static Future<List<dv.File>> _getFolderList() async {
    LOG("--> _getFolderList : $folderId / ${dirListData.keys}");
    if (dirListData.containsKey(folderId)) {
      return dirListData[folderId] as List<dv.File>;
    }
    return await GoogleService.getDriveFolders(folderId);
  }

  static _showDriveSelectDialog(context, isUpload) {
    selectDir.clear();
    dirListData.clear();
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
            title: Text(TR(context, '저장 위치 선택'), style: typo16semibold),
            buttonPadding: EdgeInsets.only(top: 10),
            contentPadding: EdgeInsets.fromLTRB(30, 20, 30, 0),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder(
                  future: _getFolderList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<DropdownMenuItem> dirList = snapshot.data!.map((e) =>
                          dirItem(e.title, '${e.title}&/${e.id}')).toList();
                      dirListData[folderId] = snapshot.data as List<dv.File>;
                      dirList.insert(0, dirItem(folderTitle, '[top]', isTop: true));
                      if (selectDir.isNotEmpty) {
                        dirList.insert(1, dirItem('..', '[back]'));
                      }
                      return _driveSelectWidget(dirList, onSelected: (select) {
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
              // if (selectDir.isNotEmpty)
              //   TextButton(
              //     onPressed: () {
              //       setState(() {
              //         selectDir.removeLast();
              //         LOG('---> back dir : ${selectDir.length}');
              //       });
              //     },
              //     child: Text('Back'),
              //   ),
              TextButton(
                onPressed: context.pop,
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
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
    return DropdownButton(
      value: selectValue ?? (list.isNotEmpty ? list.first.value : null),
      underline: Container(height: 1, color: GRAY_50),
      padding: EdgeInsets.symmetric(vertical: 5),
      items: list,
      isExpanded: true,
      onChanged: (value) {
        LOG('---> selected item : $value');
        if (onSelected != null) onSelected(value);
      },
    );
  }

  static DropdownMenuItem dirItem(text, value, {bool isTop = false}) {
    return DropdownMenuItem(
      child: Row(
        children: [
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
      query: "mimeType = 'application/vnd.google-apps.folder'"
    );
  }

  static Future<List<dv.File>> getDriveFiles({String? parentId, String? query}) async {
    var client = GoogleHttpClient(await googleUser!.authHeaders);
    var drive = dv.DriveApi(client);
    var list = await drive.files.list(
        spaces: 'drive',
        q: "'${parentId ?? 'root'}' in parents${query != null ? ' and $query' : ''}",
    );
    if (list.items != null) {
      for (var i = 0; i < list.items!.length; i++) {
        LOG("--> file item [${list.items![i].title}]: ${list.items![i].mimeType}");
        // if (!isDirOnly || list.items![i].)
      }
    } else {
      LOG("--> file error: ${list.toJson()}");
    }
    return list.items ?? [];
  }

  static Future<String?> uploadToGoogleDrive(String desc,
    {var fileName = 'larba-mnemonic-backup.rwf', var parentId = ''}) async {
    LOG('--> uploadToGoogleDrive : $desc');
    // List<dv.ParentReference> parents = [];
    // var dirList = await listGoogleDriveFiles();
    // parents.add(dirList.first);
    try {
      if (googleUser == null) {
        // TODO: show google sign in dialog..
        await signIn();
        if (googleUser == null) return null;
      }
      var client = GoogleHttpClient(await googleUser!.authHeaders);
      var drive = dv.DriveApi(client);
      dv.File fileToUpload = dv.File();

      var file = await createFile(fileName);
      file.writeAsStringSync(desc);
      LOG('--> uploadToGoogleDrive file : ${file.path} / ${await file.length()}');
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
      LOG('--> uploadToGoogleDrive response [${file.path}] : ${response.toJson()}');
      file.delete();
      return response.downloadUrl;
    } catch (e) {
      LOG('--> uploadToGoogleDrive error : $e');
    }
    return null;
  }

  static Future<String> get _directoryPath async {
    Directory? directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> createFile(String fileNameWithExtension) async {
    final path = await _directoryPath;
    return File("$path/$fileNameWithExtension");
  }
}