import 'dart:convert';
import 'dart:io';

import 'package:cloud_kit/cloud_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:url_launcher/url_launcher.dart';

import '../common/common_package.dart';
import '../common/const/constants.dart';
import '../common/const/utils/convertHelper.dart';
import '../common/const/utils/languageHelper.dart';
import '../common/const/utils/uihelper.dart';
import '../common/const/widget/dialog_utils.dart';

CloudKit cloudKit = CloudKit(ICLOUD_CONTAINER_ID);

class ICloudService {
  static Future<bool> uploadKeyToDrive(
    BuildContext context, String email, String exportText,
      Function() onDone, Function(String) onError) async {
    if (await _checkAccount(context)) {
      var key = crypto.sha256.convert(utf8.encode(email)).toString();
      var result = await _startUpload(exportText, key, onDone, onError);
      return result;
    } else {
      onError(TR('iCloud 활성화가 필요합니다.\n설정 > Apple ID, iCloud'));
    }
    return false;
  }

  static Future<bool> downloadKeyFromDrive(
    BuildContext context, String email,
    Function(String) onDone, Function(String) onError) async {
    if (await _checkAccount(context)) {
      var key = crypto.sha256.convert(utf8.encode(email)).toString();
      await _startDownload(key, (result) {
        onDone(result);
      }, (err) {
        onError(err);
      });
      return true;
    } else {
      onError(TR('iCloud 활성화가 필요합니다.\n설정 > Apple ID, iCloud'));
    }
    return false;
  }

  static _startUpload(String desc, String fileName,
    Function() onDone, Function(String) onError) async {
    File file = await openFile(fileName);
    file.writeAsStringSync(desc);
    try {
      await ICloudStorage.upload(
        containerId: ICLOUD_CONTAINER_ID,
        filePath: file.path,
        destinationRelativePath: fileName,
        onProgress: (stream) {
          var uploadProgressSub = stream.listen(
                (progress) => LOG('--> Upload File Progress: $progress'),
            onDone: () {
              LOG('--> Upload File Done');
              onDone();
            },
            onError: (err) {
              LOG('--> Upload File Error: $err');
              onError(TR('다운로드에 실패했습니다.'));
            },
            cancelOnError: true,
          );
        },
      );
      return true;
    } catch (err) {
      if (err is PlatformException) {
        if (err.code == PlatformExceptionCode.iCloudConnectionOrPermission) {
          LOG('--> Platform Exception: iCloud container ID is not valid');
          onError(TR('iCloud에 로그인 되어있지 않습니다.'));
          return;
        } else {
          LOG('--> Platform Exception: ${err.message}; Details: ${err.details}');
        }
      } else {
        LOG('--> _startDownload Error: $err');
      }
      onError(err.toString());
    }
    return false;
  }

  static _startDownload(String fileName,
    Function(String) onDone, Function(String) onError) async {
    try {
      var file = await openFile('tmp_00.rwf');
      await ICloudStorage.download(
        containerId: ICLOUD_CONTAINER_ID,
        relativePath: fileName,
        destinationFilePath: file.path,
        onProgress: (stream) {
          var downloadProgressSub = stream.listen(
                (progress) => LOG('--> Download File Progress: $progress'),
            onDone: () {
              file.readAsString().then((result) {
                LOG('--> Download File Done : $result');
                onDone(result);
              });
            },
            onError: (err) {
              LOG('--> Download File Error: $err');
              onError(TR('다운로드에 실패했습니다.'));
            },
            cancelOnError: true,
          );
        },
      );
    } catch (err) {
      if (err is PlatformException) {
        if (err.code == PlatformExceptionCode.iCloudConnectionOrPermission) {
          LOG('--> Platform Exception: iCloud container ID is not valid');
          onError(TR('iCloud에 로그인 되어있지 않습니다.'));
          return;
        } else if (err.code == PlatformExceptionCode.fileNotFound) {
          LOG('--> File not found');
          onError(TR('대상을 찾을 수 없습니다.'));
          return;
        } else {
          LOG('--> Platform Exception: ${err.message}; Details: ${err.details}');
        }
      } else {
        LOG('--> _startDownload Error: $err');
      }
      onError(err.toString());
    }
  }

  static _checkAccount(BuildContext context) async {
    var accountStatus = await cloudKit.getAccountStatus();
    LOG('--> accountStatus : $accountStatus');
    if (accountStatus == CloudKitAccountStatus.available) {
      return true;
    }
    return false;
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