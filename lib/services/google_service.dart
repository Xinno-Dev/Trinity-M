
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart' as dv;
import 'package:googleapis/websecurityscanner/v1.dart';

import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';

import '../common/const/utils/convertHelper.dart';

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

  static listGoogleDriveFiles() async {
    var client = GoogleHttpClient(await googleUser!.authHeaders);
    var drive = dv.DriveApi(client);
    var list = await drive.files.list(spaces: 'drive');
    if (list.items != null) {
      for (var i = 0; i < list.items!.length; i++) {
        LOG("--> items Id: ${list.items![i].id} File Name:${list.items![i].title}");
      }
    } else {
      LOG("--> items error: ${list.toJson()}");
    }
    return list.items;
  }

  static Future<String?> uploadToGoogleDrive(String contents,
    {var fileName = 'larba-key-backup.txt'}) async {
    LOG('--> uploadToGoogleDrive : $contents');
    // List<dv.ParentReference> parents = [];
    // var dirList = await listGoogleDriveFiles();
    // parents.add(dirList.first);
    try {
      if (googleUser == null) {
        await signIn();
        if (googleUser == null) return null;
      }
      var client = GoogleHttpClient(await googleUser!.authHeaders);
      var drive = dv.DriveApi(client);
      dv.File fileToUpload = dv.File();

      var file = await createFile(fileName);
      file.writeAsStringSync(contents);
      LOG('--> uploadToGoogleDrive file : ${file.path} / ${await file.length()}');

      fileToUpload.title = fileName;
      var response = await drive.files.insert(
        fileToUpload,
        uploadMedia: dv.Media(file.openRead(), file.lengthSync()),
      );
      LOG('--> uploadToGoogleDrive response [${file.path}] : ${response.toJson()}');
      file.delete();
      return response.resourceKey;
    } catch (e) {
      LOG('--> uploadToGoogleDrive error : $e');
    }
    return null;
  }

  // static Future authorizedClient(String id, scopes) async {
  //   final result = await auth.requestAccessCredentials(clientId: id, scopes: scopes);
  //   LOG('--> authorizedClient : $result');
  //   return result;
  // }


  static Future<String> get _directoryPath async {
    Directory? directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> createFile(String fileNameWithExtension) async {
    final path = await _directoryPath;
    return File("$path/$fileNameWithExtension");
  }
}