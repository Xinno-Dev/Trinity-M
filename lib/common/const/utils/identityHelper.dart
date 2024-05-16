import 'package:flutter/services.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../../common_package.dart';
import 'convertHelper.dart';
import 'languageHelper.dart';

Future<bool?> showBioIdentity(BuildContext context,
  {String? title, Function(String)? onError}) async {
  LOG('--> showBioIdentity');
  final auth = LocalAuthentication();
  var result = false;
  try {
    var iosStrings = IOSAuthMessages(
      // cancelButton: '취소',
      // goToSettingsButton: '설정',
      // goToSettingsDescription: '생체인증 설정을 해주세요.',
      // lockOut: 'Please reenable your Touch ID',
      // localizedFallbackTitle: '암호입력',
    );
    var androidStrings = AndroidAuthMessages(
      signInTitle: '생체인증 사용 동의',
      biometricHint: '지문',
      cancelButton: '닫기',
    );
    result = await auth.authenticate(
      localizedReason: title ?? TR(context, '본인 확인을 위해 생체인증을 사용합니다.'),
      authMessages: <AuthMessages>[
        androidStrings,
        iosStrings,
      ],
      options: AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: true,
        useErrorDialogs: false,
      ),
    );
  } on PlatformException catch (e) {
    LOG('--> Authentication error : $e');
    if (onError != null) onError(e.toString());
  }
  LOG('--> showBioIdentity result : $result');
  return result;
}
