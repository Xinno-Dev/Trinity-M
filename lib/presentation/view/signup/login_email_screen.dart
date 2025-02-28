import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:trinity_m_00/domain/model/user_model.dart';
import 'package:trinity_m_00/presentation/view/signup/signup_email_screen.dart';

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
import '../../../common/const/widget/custom_text_form_field.dart';
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
  final focusNode = FocusNode();
  var isNextReady = false;
  var isEmailReady = false;
  var passErrorText = '';
  var reLogin = false;

  _checkNextReady() {
      isNextReady =
        EmailValidator.validate(emailInputController.text) && (
        !isEmailReady || (
          passInputController.text.length >= PASS_LENGTH_MIN &&
          passInputController.text.length <= PASS_LENGTH_MAX)
        );
      if (isNextReady) {
        focusNode.requestFocus();
      }
      _checkPassLength();
  }

  _checkPassLength() {
    setState(() {
      passErrorText = '';
      if (isEmailReady && passInputController.text.length < PASS_LENGTH_MIN) {
        passErrorText = '$PASS_LENGTH_MIN 자 이상 입력해 주세요';
      }
      if (isEmailReady && passInputController.text.length > PASS_LENGTH_MAX) {
        passErrorText = '$PASS_LENGTH_MAX 자 이하 입력해 주세요';
      }
    });
    return passErrorText.isEmpty;
  }

  @override
  void initState() {
    super.initState();
    var prov = ref.read(loginProvider);
    emailInputController.text = '';
    passInputController.text = IS_DEV_MODE ? prov.inputPass.first : '';
    isEmailReady = false;
  }

  @override
  Widget build(BuildContext context) {
    // isEmailReady = true; // for Test..
    final prov = ref.watch(loginProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: defaultAppBar(TR('이메일 로그인')),
        body: LayoutBuilder(builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 20),
                height: constraints.maxHeight / 2.5,
                alignment: Alignment.center,
                child: logoWidget(),
              ),
              Center(
                child: Container(
                  height: constraints.maxHeight / 4 + (isEmailReady ? 35 : 0),
                  margin: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    children: [
                      // TextField(
                      //   controller: emailInputController,
                      //   decoration: InputDecoration(
                      //     hintText: TR('이메일 주소 입력'),
                      //   ),
                      //   keyboardType: TextInputType.emailAddress,
                      //   autofocus: true,
                      //   onTap: () {
                      //     setState(() {
                      //       passErrorText = '';
                      //       isEmailReady = false;
                      //     });
                      //   },
                      //   onChanged: (text) {
                      //     _checkNextReady();
                      //   },
                      // ),
                      CustomEmailFormField(
                        controller: emailInputController,
                        hintText: TR('이메일 주소 입력'),
                        onTap: () {
                          setState(() {
                            passErrorText = '';
                            isEmailReady = false;
                          });
                        },
                        onChanged: (text) {
                          _checkNextReady();
                        },
                      ),
                      if (isEmailReady)...[
                        SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomPassFormField(
                              controller: passInputController,
                              focusNode: focusNode,
                              hintText: TR('비밀번호 입력'),
                              onChanged: (text) {
                                _checkNextReady();
                              },
                            ),
                            // TextField(
                            //   controller: passInputController,
                            //   decoration: InputDecoration(
                            //     hintText: TR('비밀번호 입력'),
                            //   ),
                            //   keyboardType: TextInputType.visiblePassword,
                            //   obscureText: true,
                            //   focusNode: focusNode,
                            //   onChanged: (text) {
                            //     _checkNextReady();
                            //   },
                            // ),
                            // if (passErrorText.isNotEmpty)...[
                            //   SizedBox(height: 5),
                            //   Text(TR(passErrorText), style: errorStyle)
                            // ]
                          ],
                        )
                      ],
                    ],
                  )
                )
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: IS_DEV_MODE || isNextReady ?
                PrimaryButton(
                text: TR('다음'),
                round: 0,
                onTap: () async {
                  var email = emailInputController.text;
                  if (isEmailReady) {
                    if (_checkPassLength()) {
                      _startEmailLogin();
                    }
                  } else {
                    if (email == EX_TEST_MAIL_EX) {
                      setState(() {
                        isEmailReady = true;
                      });
                    } else {
                      // var userKey = crypto.sha256.convert(utf8.encode(email)).toString();
                      // var mnCheck  = await UserHelper().get_mnemonic(userKeyTmp: userKey);
                      if (await prov.checkUserHasLocalInfo(email)) {
                        LOG('--> isEmailReady : $email');
                        setState(() {
                          isEmailReady = true;
                        });
                      } else {
                        // check already created email..
                        prov.inputEmail = emailInputController.text;
                        prov.emailDupCheck(email).then((result) {
                          if (result) {
                            FocusScope.of(context).requestFocus(FocusNode()); //remove focus
                            showLoginErrorDialog(context,
                                LoginErrorType.recoverRequire, text: email).then((_) {
                              Navigator.of(context).push(
                                  createAniRoute(LoginRestoreScreen()));
                            });
                          } else {
                            showLoginErrorDialog(context,
                              LoginErrorType.signupRequire,
                              text: email,
                              okText: '회원가입',
                              cancelText: '취소',
                            ).then((result) {
                              if (BOL(result)) {
                                Navigator.of(context).push(
                                  createAniRoute(SignUpEmailScreen()));
                              }
                            });
                          }
                        });
                      }
                    }
                  }
                },
              ) : DisabledButton(
                text: TR('다음'),
              )),
            ],
          ),
          );
        })
      ),
    );
  }

  _loginError(LoginErrorType type, String? error) {
    LOG('--> _loginError : $type, $error');
    showLoginErrorDialog(context, type, text: error).then((_) async {
      if (error == '__not_found__') {
        if (!reLogin) {
          reLogin = true;
          var prov = ref.read(loginProvider);
          prov.userInfo = UserModel();
          prov.mainPageIndex = 0;
          prov.mainPageIndexOrg = -1;
          await UserHelper().setUserKey(prov.inputEmail);
          await prov.removeNickId();
          prov.refresh();
        }
      }
    });
  }

  _startEmailLogin() async {
    var prov = ref.read(loginProvider);
    prov.inputEmail = emailInputController.text;
    prov.setUserPass(passInputController.text);
    LOG('=================> _startEmailLogin : ${prov.inputEmail}');
    FocusScope.of(context).requestFocus(FocusNode()); //remove focus
    showLoadingDialog(context, TR('로그인중입니다...'));
    await Future.delayed(Duration(milliseconds: 100));
    var result = await prov.loginEmail(onError: (code, text) {
      LOG('--> loginEmail error : $code / $text');
      if (prov.inputEmail != EX_TEST_MAIL_EX) {
        // showToast(code.errorText);
        hideLoadingDialog();
        _loginError(code, text);
      }
    });
    LOG('----> loginProv.loginEmail result : $result');
    hideLoadingDialog();
    if (result == true) {
      // 로그인 완료..
      showToast(TR('로그인 성공'));
      Navigator.of(context).pop(true);
    } else if (result == null) {
      // tester00 계정용 자동 니모닉 복구..
      if (prov.inputEmail == EX_TEST_MAIL_EX) {
        if (prov.userPass == EX_TEST_PASS_EX) {
          prov.recoverUser(
              EX_TEST_PASS_EX,
              mnemonic: EX_TEST_MN_EX).then((result) {
            if (prov.isLogin) {
              _startEmailLogin();
            }
          });
        } else {
          showLoginErrorDialog(context,
              LoginErrorType.passFailEx);
        }
      } else {
        // 이미 생성된 계정인지 체크..
        prov.inputEmailDupCheck().then((result) {
          if (result) {
            // 계정 복구..
            showLoginErrorDialog(context,
              LoginErrorType.recoverRequire, text: prov.userInfo?.email).then((_) {
              Navigator.of(context).push(
                  createAniRoute(LoginRestoreScreen()));
            });
          } else {
            // 회원가입..
            showLoginErrorDialog(context,
              LoginErrorType.signupRequire, text: prov.userInfo?.email).then((_) {
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
