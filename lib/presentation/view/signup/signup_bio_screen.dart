import '../../../../common/common_package.dart';
import '../../../../common/const/constants.dart';
import '../../../../common/const/utils/localStorageHelper.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/const/utils/userHelper.dart';
import '../../../../common/const/widget/CustomCheckBox.dart';
import '../../../../common/const/widget/SimpleCheckDialog.dart';
import '../../../../common/const/widget/disabled_button.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/provider/language_provider.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../common/style/textStyle.dart';
import '../../../../presentation/view/recover_wallet_complete_screen.dart';
import '../../../../presentation/view/registComplete_screen.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:provider/provider.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/identityHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import 'signup_mnemonic_screen.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class SignUpBioScreen extends ConsumerStatefulWidget {
  SignUpBioScreen({super.key, this.isShowNext = true});
  static String get routeName => 'signUpBioScreen';
  bool isShowNext;

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


  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: defaultAppBar(TR(context, '생체인증 사용동의')),
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
                      TR(context, '본인 확인 목적으로 기기에 등록된 생체정보를\n'
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
                    if (_localAuthAgree == true) {
                      setState(() {
                        _localAuthAgree = false;
                      });
                    } else {
                      showBioIdentity(context,
                        TR(context, '생체인증 등록'),
                        onError: (err) {
                          setState(() {
                            _localAuthAgree = false;
                            showLoginErrorTextDialog(context, err);
                          });
                      }).then((result) {
                        prov.isScreenLocked = false;
                        if (BOL(result)) {
                          setState(() {
                            _localAuthAgree = true;
                            prov.setBioIdentity(_localAuthAgree);
                            if (!widget.isShowNext) {
                              context.pop(result);
                            }
                          });
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.isShowNext ? PrimaryButton(
          text: TR(context, _localAuthAgree ? '다음' : '건너뛰기'),
          round: 0,
          onTap: () {
            UserHelper().setUser(localAuth: _localAuthAgree ? 'true' : 'false');
            Navigator.of(context).push(createAniRoute(SignUpMnemonicScreen()));
          },
        ) : null,
      ),
    );
  }
}
