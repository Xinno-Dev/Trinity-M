import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/const/utils/localStorageHelper.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/CustomCheckBox.dart';
import 'package:larba_00/common/const/widget/SimpleCheckDialog.dart';
import 'package:larba_00/common/const/widget/disabled_button.dart';
import 'package:larba_00/common/const/widget/primary_button.dart';
import 'package:larba_00/common/provider/language_provider.dart';
import 'package:larba_00/presentation/view/recover_wallet_complete_screen.dart';
import 'package:larba_00/presentation/view/registComplete_screen.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:provider/provider.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import 'signup_mnemonic_screen.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class SignUpBioScreen extends ConsumerStatefulWidget {
  SignUpBioScreen({super.key});
  static String get routeName => 'signUpBioScreen';

  @override
  ConsumerState createState() => _SignUpBioScreenState();
}

class _SignUpBioScreenState extends ConsumerState<SignUpBioScreen> {
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
        signInTitle: '생체인증 사용 동의',
        biometricHint: '지문',
        cancelButton: '사용안함',
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
      LOG('--> Authentication error : $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleCheckDialog(
            titleString: TR(context, '등록에 실패했습니다.'),
            infoString: TR(context, e.toString()),
          );
        },
      );
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

    setState(() {
      final String message = authenticated ? 'Authorized' : 'Not Authorized';
      if (authenticated) {
        _localAuthAgree = true;
      }
      LOG('----> authenticated result : $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          backgroundColor: WHITE,
          centerTitle: true,
          title: Text(
            TR(context, '생체인증 사용동의'),
            style: ref.read(languageProvider).isKor ? typo18semibold : typo16semibold,
          ),
          titleSpacing: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.only(top: 30.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TR(context, '빠른 이용을 위해\n생체인증을 설정하세요.'),
                      style: typo24bold150,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      TR(context, '본인확인 목적으로 기기에 등록된 모든 생체정보를\n'
                          '이용하여 로그인 및 인증작업을 진행하며,\n서버로 전송/저장되지 않습니다.'),
                      style: typo16medium150,
                    ),
                  ],
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
                    setState(() {
                      if (_localAuthAgree == true) {
                        _localAuthAgree = false;
                      } else {
                        _authenticateWithBiometrics(context);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: PrimaryButton(
            text: TR(context, _localAuthAgree ? '다음' : '건너뛰기'),
            round: 0,
            onTap: () {
              UserHelper().setUser(localAuth: _localAuthAgree ? 'true' : 'false');
              Navigator.of(context).push(createAniRoute(SignUpMnemonicScreen()));
            },
          ),
        ),
      ),
    );
  }
}
