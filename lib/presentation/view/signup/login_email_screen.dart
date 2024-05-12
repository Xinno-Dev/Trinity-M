import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_input_screen.dart';
import 'package:larba_00/services/social_service.dart';

import '../../../common/common_package.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import 'login_restore_screen.dart';
import 'signup_pass_screen.dart';

class LoginEmailScreen extends ConsumerStatefulWidget {
  const LoginEmailScreen({Key? key, this.isSignUpMode = true}) : super(key: key);
  static String get routeName => 'loginEmailScreen';
  final bool isSignUpMode;

  @override
  ConsumerState createState() => _LoginEmailScreenState();
}

class _LoginEmailScreenState extends ConsumerState<LoginEmailScreen> {
  final emailInputController = TextEditingController();
  final passInputController = TextEditingController();
  var isNextReady = false;

  checkNextReady() {
    setState(() {
      isNextReady =
          EmailValidator.validate(emailInputController.text) &&
          passInputController.text.length > 4;
    });
  }

  @override
  void initState() {
    super.initState();
    emailInputController.text = ref.read(loginProvider).inputEmail;
    passInputController.text = ref.read(loginProvider).inputPass.first;
  }

  @override
  Widget build(BuildContext context) {
    final loginProv = ref.watch(loginProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          backgroundColor: WHITE,
          centerTitle: true,
          title: Text(
            TR(context, '이메일 로그인'),
            style: typo18semibold,
          ),
          titleSpacing: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 300,
                margin: EdgeInsets.only(top: 20),
                child: SvgPicture.asset(
                  'assets/svg/logo.svg',
                ),
              ),
              Container(
                height: 240,
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                child: Column(
                  children: [
                    TextField(
                      controller: emailInputController,
                      decoration: InputDecoration(
                        hintText: TR(context, '이메일 주소 입력'),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      scrollPadding: EdgeInsets.only(bottom: 200),
                      onChanged: (text) {
                        checkNextReady();
                      },
                    ),
                    SizedBox(height: 40.h),
                    TextField(
                      controller: passInputController,
                      decoration: InputDecoration(
                        hintText: TR(context, '비밀번호 입력'),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      scrollPadding: EdgeInsets.only(bottom: 200),
                      onChanged: (text) {
                        checkNextReady();
                      },
                    ),
                  ],
                )
              ),
            ],
          )
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: IS_DEV_MODE || isNextReady ?
            PrimaryButton(
              text: TR(context, '다음'),
              round: 0,
              onTap: () {
                _startEmailLogin();
              },
            ) : DisabledButton(
              text: TR(context, '다음'),
            ),
        ),
      )
    );
  }

  _startEmailLogin() async {
    var loginProv = ref.read(loginProvider);
    loginProv.inputEmail = emailInputController.text;
    loginProv.inputPass.first = passInputController.text;
    LOG('=================> _startEmailLogin : ${loginProv.inputEmail}');
    showLoadingDialog(context, '로그인중입니다...');
    await Future.delayed(Duration(milliseconds: 200));
    var result = await loginProv.loginEmail();
    LOG('----> loginProv.loginEmail result : $result');
    hideLoadingDialog();
    if (result == true) {
      // 로그인 완료..
      Fluttertoast.showToast(msg: '로그인 성공');
      Navigator.of(context).pop(true);
    } else if (result == null) {
      // tester00 계정용 자동 니모닉 복구..
      if (loginProv.inputEmail == EX_TEST_MAIL_EX) {
        loginProv.recoverUser(mnemonic: EX_TEST_MN_EX).then((result) {
          if (loginProv.isLogin) {
            _startEmailLogin();
          }
        });
      } else {
        // 이미 생성된 계정인지 체크..
        loginProv.inputEmailDupCheck().then((result) {
          if (result) {
            // 계정 복구..
            Navigator.of(context).push(
                createAniRoute(LoginRestoreScreen()));
            showLoginErrorDialog(context,
                LoginErrorType.recoverRequire, loginProv.userInfo?.email);
          } else {
            // 회원가입..
            showLoginErrorDialog(context,
                LoginErrorType.signupRequire, loginProv.userInfo?.email).then((_) {
              loginProv.setSignUpMode();
              context.pop();
            });
          }
        });
      }
    } else {
      Fluttertoast.showToast(msg: '로그인 실패');
    }
  }
}
