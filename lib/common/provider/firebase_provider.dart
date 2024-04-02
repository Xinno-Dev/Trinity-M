
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/domain/model/app_start_model.dart';
import 'package:larba_00/domain/model/mdl_check_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../services/firebase_api_service.dart';
import '../const/utils/convertHelper.dart';

final firebaseProvider = ChangeNotifierProvider<FirebaseProvider>((_) {
  return FirebaseProvider();
});

class FirebaseProvider extends ChangeNotifier {
  FirebaseMessaging? messaging;
  FirebaseApiService? firebaseApiService;
  String? pushToken;
  AppStartModel? startInfo;

  FirebaseProvider() {
    messaging ??= FirebaseMessaging.instance;
    firebaseApiService ??= FirebaseApiService();
    messaging!.getToken().then((token) {
      pushToken = token;
    });
  }

  Future<AppStartModel?> getAppStartInfo() async {
    if (firebaseApiService != null) {
      var result = await firebaseApiService!.getAppStartInfo();
      if (result != null) {
        startInfo = AppStartModel.fromJson(result);
        print('---> getServerVersion : ${getServerVersion('android')}');
        return startInfo;
      }
    }
    return null;
  }

  Future<List<MDLCheckModel>> getMDLNetworkCheckUrl() async {
    List<MDLCheckModel> resultList = [];
    if (firebaseApiService != null) {
      var result = await firebaseApiService!.getMDLNetworkCheckUrl();
      if (result != null) {
        for (var item in result.entries) {
          print('---> mdlCheckInfo add : ${item.value}');
          resultList.add(MDLCheckModel.fromJson(item.value));
        }
      }
    }
    print('---> mdlCheckInfo result : ${resultList.length}');
    return resultList;
  }

  getServerVersion(String deviceType) {
    if (startInfo == null) return null;
    return startInfo!.versionInfo[deviceType] as AppVersionData;
  }
}
