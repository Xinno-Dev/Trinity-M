import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/const/utils/localStorageHelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/CustomCheckBox.dart';
import 'package:larba_00/common/const/widget/SimpleCheckDialog.dart';
import 'package:larba_00/common/const/widget/disabled_button.dart';
import 'package:larba_00/common/const/widget/primary_button.dart';
import 'package:larba_00/presentation/view/recover_wallet_complete_screen.dart';
import 'package:larba_00/presentation/view/registComplete_screen.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/back_button.dart';
import '../../common/const/widget/gray_5_button.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class RegistLocalAuthScreen extends StatefulWidget {
  const RegistLocalAuthScreen({super.key, required this.previousScreen});
  static String get routeName => 'registLocalAuth';
  final String? previousScreen;

  @override
  State<RegistLocalAuthScreen> createState() => _RegistLocalAuthScreenState();
}

class _RegistLocalAuthScreenState extends State<RegistLocalAuthScreen> {
  bool _localAuthAgree = false; //로컬인증 사용
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

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
          biometricOnly: true,
          useErrorDialogs: false,
        ),
      );

      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleCheckDialog(
            infoString: TR(context, '권한이 허용되지 않았습니다.'),
          );
        },
      );
      print('Authentication canceled.');

      setState(() {
        _localAuthAgree = false;
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
      // userHelper().setUser(loginDate: DateTime.now().toString());
      // context.goNamed(SignGenerateScreen.routeName,
      //   queryParams: {'noti': _payloadString});
      // context.pushNamed(HomeScreen.routeName);
      _localAuthAgree = true;
      // context.go('/firebaseSetup');
    } else {
      print('패스워드 입력');
    }
    setState(() {
      print(message);
    });
  }

  setPushNextPage() {
    // set mnemonic check done..
    LocalStorageManager.saveData(MNEMONIC_CHECK, '');
    if (widget.previousScreen == 'recover') {
      context.pushNamed(RecoverWalletCompleteScreen.routeName);
    } else {
      context.pushNamed(RegistCompleteScreen.routeName,
          queryParams: {'join': 'true'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR(context, '생체인증 사용동의'),
          style: typo14bold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Spacer(),
                    SizedBox(height: 80.h),
                    Padding(
                      padding: EdgeInsets.only(left: 20.r, right: 20.r),
                      child: Text(
                        TR(context, '빠른 이용을 위해\n생체인증을 설정하세요'),
                        style: typo24bold150,
                      ),
                    ),
                    SizedBox(
                      height: 16.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.r, right: 20.r),
                      child: Text(
                        TR(context, '본인확인 목적으로 기기에 등록된 모든 생체정보를\n'
                          '이용하여 로그인 및 인증작업을 진행하며\n서버로 전송/저장되지 않습니다.'),
                        style: typo16medium150,
                      ),
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20.r),
                      child: CustomCheckbox(
                        title: TR(context, '생체인증 사용 동의'),
                        checked: _localAuthAgree,
                        pushed: false,
                        localAuth: true,
                        onChanged: (agree) async {
                          if (_localAuthAgree == true) {
                            _localAuthAgree = false;
                          } else {
                            _authenticateWithBiometrics(context);
                          }
                        },
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Gray5Button(
                            text: TR(context, '다음에 하기'),
                            onTap: () {
                              UserHelper().setUser(localAuth: 'false');
                              setPushNextPage();
                            },
                          ),
                          SizedBox(
                            height: 16.h,
                          ),
                          _localAuthAgree
                              ? PrimaryButton(
                                  text: TR(context, '생체인증 사용'),
                                  onTap: () {
                                    UserHelper().setUser(localAuth: 'true');
                                    setPushNextPage();
                                  },
                                )
                              : DisabledButton(text: TR(context, '생체인증 사용')),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40.h,
                    )
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
