import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crypto/crypto.dart' as crypto;

import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../presentation/view/asset/networkScreens/network_input_screen.dart';
import '../../../../services/social_service.dart';

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
  var isEmailReady = false;
  var passErrorText = '';

  checkNextReady() {
    setState(() {
      isNextReady =
        EmailValidator.validate(emailInputController.text) && (
        !isEmailReady || (
          passInputController.text.length >= PASS_LENGTH_MIN &&
          passInputController.text.length <= PASS_LENGTH_MAX)
        );
      passErrorText = '';
      if (isEmailReady && passInputController.text.length < PASS_LENGTH_MIN) {
        passErrorText = '$PASS_LENGTH_MIN 자 이상 입력해 주세요';
      }
      if (isEmailReady && passInputController.text.length > PASS_LENGTH_MAX) {
        passErrorText = '$PASS_LENGTH_MAX 자 이하 입력해 주세요';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    var prov = ref.read(loginProvider);
    emailInputController.text = prov.inputEmail;
    passInputController.text  = IS_DEV_MODE ? prov.inputPass.first : '';
    isEmailReady = false;
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
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
                    if (isEmailReady)...[
                      SizedBox(height: 40.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: passInputController,
                            decoration: InputDecoration(
                              hintText: TR(context, '비밀번호 입력'),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            autofocus: true,
                            scrollPadding: EdgeInsets.only(bottom: 200),
                            onChanged: (text) {
                              checkNextReady();
                            },
                          ),
                          if (passErrorText.isNotEmpty)...[
                            SizedBox(height: 5),
                            Text(TR(context, passErrorText), style: errorStyle)
                          ]
                        ],
                      )
                    ],
                  ],
                )
              ),
            ],
          )
        ),
        bottomNavigationBar: IS_DEV_MODE || isNextReady ?
          PrimaryButton(
            text: TR(context, '다음'),
            round: 0,
            onTap: () async {
              var email = emailInputController.text;
              if (isEmailReady) {
                _startEmailLogin();
              } else {
                if (email == EX_TEST_MAIL_EX) {
                  setState(() {
                    isEmailReady = true;
                  });
                } else {
                  var userKey = crypto.sha256.convert(utf8.encode(email)).toString();
                  var result  = await UserHelper().get_mnemonic(userKeyTmp: userKey);
                  setState(() {
                    isEmailReady = result != 'NOT_MNEMONIC';
                  });
                }
              }
            },
          ) : DisabledButton(
            text: TR(context, '다음'),
          ),
      ),
    );
  }

  _startEmailLogin() async {
    var prov = ref.read(loginProvider);
    prov.inputEmail = emailInputController.text;
    prov.inputPass.first = passInputController.text;
    LOG('=================> _startEmailLogin : ${prov.inputEmail}');
    showLoadingDialog(context, '로그인중입니다...');
    var result = await prov.loginEmail(onError: (code, text) {
      if (prov.inputEmail != EX_TEST_MAIL_EX) {
        hideLoadingDialog();
        showLoginErrorDialog(context, code);
      }
    });
    LOG('----> loginProv.loginEmail result : $result');
    hideLoadingDialog();
    if (result == true) {
      // 로그인 완료..
      showToast('로그인 성공');
      Navigator.of(context).pop(true);
    } else if (result == null) {
      // tester00 계정용 자동 니모닉 복구..
      if (prov.inputEmail == EX_TEST_MAIL_EX) {
        prov.recoverUser(
          EX_TEST_PASS_EX,
          mnemonic: EX_TEST_MN_EX).then((result) {
          if (prov.isLogin) {
            _startEmailLogin();
          }
        });
      } else {
        // 이미 생성된 계정인지 체크..
        prov.inputEmailDupCheck().then((result) {
          if (result) {
            // 계정 복구..
            Navigator.of(context).push(
                createAniRoute(LoginRestoreScreen()));
            showLoginErrorDialog(context,
                LoginErrorType.recoverRequire, prov.userInfo?.email);
          } else {
            // 회원가입..
            showLoginErrorDialog(context,
                LoginErrorType.signupRequire, prov.userInfo?.email).then((_) {
              prov.setSignUpMode();
              context.pop();
            });
          }
        });
      }
    } else {
      // showToast('로그인 실패');
      LOG('----> login fail! : ${prov.inputEmail}');
      if (prov.inputEmail == EX_TEST_MAIL_EX) {
        prov.recoverUser(
            EX_TEST_PASS_EX,
            mnemonic: EX_TEST_MN_EX).then((result) {
          if (prov.isLogin) {
            _startEmailLogin();
          }
        });
      }
    }
  }
}
