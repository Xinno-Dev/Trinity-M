import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../presentation/view/asset/networkScreens/network_input_screen.dart';
import '../../../../presentation/view/signup/login_pass_screen.dart';

import '../../../common/common_package.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import 'signup_pass_screen.dart';

class SignUpEmailScreen extends ConsumerStatefulWidget {
  const SignUpEmailScreen({Key? key, this.isSignUpMode = true}) : super(key: key);
  static String get routeName => 'signUpEmailScreen';
  final bool isSignUpMode;

  @override
  ConsumerState createState() => _SignUpEmailScreenState();
}

class _SignUpEmailScreenState extends ConsumerState<SignUpEmailScreen> {
  final emailInputController = TextEditingController();
  final emailFocusNode = FocusNode();

  var _seconds = 0;
  var _isRunning = false;
  Timer? _timer;

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        LOG('--> _seconds : $_seconds');
        if (++_seconds > EMAIL_SEND_TIME_MAX) {
          ref.read(loginProvider).emailStep = EmailSignUpStep.ready;
          _stopTimer();
        }
      });
    });
  }

  void _stopTimer() {
    _seconds = 0;
    _isRunning = false;
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
  }

  void _resetTimer() {
    setState(() {
      _seconds = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    emailInputController.text = ref.read(loginProvider).inputEmail;
    _seconds = 0;
    // ref.read(loginProvider).emailStep = IS_DEV_MODE ? EmailSignUpStep.ready : EmailSignUpStep.none;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginProv = ref.watch(loginProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: defaultAppBar(TR(context, '이메일 등록')),
        body: LayoutBuilder(builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Stack(
              children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TR(context, '이메일을\n등록해 주세요.'),
                              style: typo24bold150,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              TR(context, '이메일 인증을 진행합니다.'),
                              style: typo16medium150.copyWith(
                                color: GRAY_70,
                              ),
                            ),
                          ],
                        ),
                      )),
                      Expanded(
                        flex: 2,
                        child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Column(
                          children: [
                            TextField(
                              controller: emailInputController,
                              focusNode: emailFocusNode,
                              decoration: InputDecoration(
                                hintText: TR(context, '이메일 주소 입력'),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              scrollPadding: EdgeInsets.only(bottom: 200),
                              onChanged: (text) {
                                _stopTimer();
                                loginProv.emailInput(text);
                              },
                            ),
                            if (loginProv.isEmailSendReady || loginProv.isEmailSendDone)...[
                              SizedBox(height: 20),
                              InkWell(
                                onTap: () {
                                  if (loginProv.isEmailSendReady) {
                                    FocusScope.of(context).requestFocus(
                                        FocusNode()); //remove focus
                                    if (loginProv.isEmailSendReady) {
                                      loginProv.emailSend((error) {
                                        showResultDialog(
                                            context, error.errorText);
                                        loginProv.sendMail = '';
                                      }).then((result) {
                                        if (result) {
                                          _startTimer();
                                          loginProv.sendMail = loginProv.inputEmail;
                                        } else {
                                          loginProv.sendMail = '';
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: !loginProv.isEmailSendReady ? Border
                                        .all(width: 2, color: GRAY_20) : null,
                                    color: loginProv.isEmailSendReady
                                        ? PRIMARY_90
                                        : WHITE
                                  ),
                                  child: Text(TR(context, loginProv.isEmailSendDone
                                      ? '발송 완료 / 재전송 ${EMAIL_SEND_TIME_MAX - _seconds}'
                                      : '인증 링크 받기'),
                                    style: loginProv.isEmailSendDone ?
                                      typo14normal.copyWith(color: GRAY_40) :
                                      typo14bold.copyWith(color: WHITE))
                                ),
                              ),
                            ],
                          ],
                        )
                      )),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: loginProv.isEmailSendReady || loginProv.isEmailSendDone
                      ? PrimaryButton(
                      text: TR(context, '인증 완료'),
                      round: 0,
                      onTap: () async {
                        await UserHelper().setUserKey(loginProv.inputEmail);
                        loginProv.emailVfCheck(onError: (error) {
                          showLoginErrorTextDialog(context, error.errorText);
                        }).then((result) {
                          if (result == true) {
                            showToast(TR(context, '이메일 인증 완료'));
                            Navigator.of(context).push(
                                createAniRoute(SignUpPassScreen()));
                          } else if (result == false) {
                            showLoginErrorDialog(
                              context, LoginErrorType.mailNotVerified);
                          }
                        });
                      },
                    ) : DisabledButton(
                      text: TR(context, '다음'),
                    ),
                  )
                ],
              )
            );
          }
        ),
      ),
    );
  }
}
