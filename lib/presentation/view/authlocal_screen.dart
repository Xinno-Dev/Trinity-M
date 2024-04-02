import 'package:flutter/services.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/utils/aesManager.dart';
import 'package:larba_00/common/provider/temp_provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'dart:async';

import 'package:larba_00/presentation/view/authpassword_screen.dart';

import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/back_button.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class AuthLocalScreen extends ConsumerStatefulWidget {
  const AuthLocalScreen({super.key});
  static String get routeName => 'authlocal';

  @override
  ConsumerState<AuthLocalScreen> createState() => _LocalAuthScreenState();
}

class _LocalAuthScreenState extends ConsumerState<AuthLocalScreen> {
  final String storageName = 'ecc';
  // BiometricStorageFile _biometricStorageFile
  AesManager? _aesmanager;

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );

    _getAvailableBiometrics();
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
      print(availableBiometrics);
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticateWithBiometrics(context) async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });

      var iosStrings = IOSAuthMessages(
          // cancelButton: '취소',
          // goToSettingsButton: '설정',
          // goToSettingsDescription: '생체인증 설정을 해주세요.',
          // lockOut: 'Please reenable your Touch ID',
          // localizedFallbackTitle: '암호입력',
          );

      var androidStrings = AndroidAuthMessages(
          // signInTitle: 'Oops! Biometric authentication required!',
          // cancelButton: 'No thanks',
          );

      authenticated = await auth.authenticate(
        localizedReason: TR(context, '본인 확인을 위해 생체인증을 사용합니다.'),
        authMessages: <AuthMessages>[
          androidStrings,
          iosStrings,
        ],
        options: AuthenticationOptions(
          stickyAuth: true,
          // biometricOnly: true,
          useErrorDialogs: false,
        ),
      );

      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      print(e.message);
      print('Authentication canceled.');

      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    if (authenticated) {
      UserHelper().setUser(loginDate: DateTime.now().toString());
      // context.goNamed(SignGenerateScreen.routeName,
      //   queryParams: {'noti': _payloadString});
      // context.pushNamed(HomeScreen.routeName);
      isGlobalLogin = true;
      context.go('/firebaseSetup');
    } else {
      print('패스워드 입력');
    }
    setState(() {
      print(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    _aesmanager = AesManager();
    _authenticateWithBiometrics(context);

    return Scaffold(
      backgroundColor: PRIMARY_20,
      appBar: AppBar(
        backgroundColor: PRIMARY_20,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 40.h,
            ),
            Text(
              TR(context, '본인확인'),
              style: typo24bold150,
            ),
            SizedBox(
              height: 16.h,
            ),
            Text(
              TR(context, 'Mauth에서 본인확인을 진행할 수 있도록\n생체인증을 진행해 주세요.'),
              style: typo16medium150,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 16.h,
            ),
            Container(
              //버튼의 크기가 너무 작아져서 너무 작아지지 않도록 대응
              height: 32.h < 32 ? 32 : 32.h,
              width: 139.w,
              child: ElevatedButton(
                  onPressed: () {
                    context.pushNamed(AuthPasswordScreen.routeName,
                        queryParams: {'auth': 'false'});
                  },
                  child: Text(
                      TR(context, '비밀번호 인증하기'),
                    style: typo14bold.copyWith(color: PRIMARY_90),
                  ),
                  style: grayButtonStyle),
            ),
          ],
        ),
      ),
    );
  }
}
