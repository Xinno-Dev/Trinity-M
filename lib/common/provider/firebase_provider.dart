
import '../../../common/common_package.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/model/app_start_model.dart';
import '../../domain/model/mdl_check_model.dart';
import '../../services/firebase_api_service.dart';
import '../const/utils/convertHelper.dart';

final firebaseProvider = ChangeNotifierProvider<FirebaseProvider>((_) {
  return FirebaseProvider();
});

class FirebaseProvider extends ChangeNotifier {
  final api = FirebaseApiService();
  FirebaseMessaging? messaging;
  String? pushToken;
  AppStartModel? startInfo;

  FirebaseProvider() {
    messaging ??= FirebaseMessaging.instance;
    messaging!.getToken().then((token) {
      pushToken = token;
    });
  }

  Future<AppStartModel?> getAppStartInfo() async {
    var result = await api.getAppStartInfo();
    if (result != null) {
      startInfo = AppStartModel.fromJson(result);
      print('---> getServerVersion : ${getServerVersion('android')}');
      return startInfo;
    }
    return null;
  }

  Future<List<MDLCheckModel>> getMDLNetworkCheckUrl() async {
    List<MDLCheckModel> resultList = [];
    var result = await api.getMDLNetworkCheckUrl();
    if (result != null) {
      for (var item in result.entries) {
        print('---> mdlCheckInfo add : ${item.value}');
        resultList.add(MDLCheckModel.fromJson(item.value));
      }
    }
    print('---> mdlCheckInfo result : ${resultList.length}');
    return resultList;
  }

  getServerVersion(String deviceType) {
    if (startInfo == null) return null;
    return startInfo!.versionInfo[deviceType] as AppVersionData;
  }

  uploadProfileImage(JSON imageInfo) async {
    return await api.uploadImageData(imageInfo['id'], imageInfo['data'], 'profile_img');
  }
}
