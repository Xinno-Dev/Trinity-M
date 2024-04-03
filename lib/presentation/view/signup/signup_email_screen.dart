import 'package:flutter/services.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_input_screen.dart';
import 'package:larba_00/presentation/view/signup/login_pass_screen.dart';

import '../../../common/common_package.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/languageHelper.dart';
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

  @override
  void initState() {
    super.initState();
    emailInputController.text = ref.read(loginProvider).inputEmail;
    ref.read(loginProvider).emailStep = EmailSignUpStep.none;
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
            TR(context, '이메일 등록'),
            style: typo18semibold,
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
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
              ),
              SizedBox(height: 30.h),
              Container(
                height: 240,
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
                        loginProv.emailInput(text);
                      },
                    ),
                    SizedBox(height: 40.h),
                    InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode()); //remove focus
                        if (loginProv.isEmailSendReady) {
                          loginProv.emailSend();
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: !loginProv.isEmailSendReady ? Border.all(width: 2, color: GRAY_20) : null,
                          color: loginProv.isEmailSendReady ? PRIMARY_90 : WHITE
                        ),
                        child: Text(TR(context, loginProv.isEmailSendDone ? '인증 다시 받기' : '인증 링크 받기'), style: typo16bold),
                      ),
                    ),
                  ],
                )
              ),
            ],
          )
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: IS_DEV_MODE || loginProv.isEmailSendDone
              ? PrimaryButton(
            text: TR(context, '다음'),
            round: 0,
            onTap: () {
              // todo: check email vf..
              Navigator.of(context).push(createAniRoute(SignUpPassScreen()));
            },
          ) : DisabledButton(
            text: TR(context, '다음'),
          ),
        ),
      )
    );
  }
}
