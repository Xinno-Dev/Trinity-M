import 'package:flutter/services.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_input_screen.dart';

import '../../../common/common_package.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../registMnemonic_screen.dart';
import 'signup_bio_screen.dart';
import 'signup_pass_screen.dart';
import 'signup_mnemonic_screen.dart';

class SignUpNickScreen extends ConsumerStatefulWidget {
  const SignUpNickScreen({Key? key, this.isSignUpMode = true}) : super(key: key);
  static String get routeName => 'signUpNickScreen';
  final bool isSignUpMode;

  @override
  ConsumerState createState() => _InputNickScreenState();
}

class _InputNickScreenState extends ConsumerState<SignUpNickScreen> {
  final textInputController = TextEditingController();
  final textFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    textInputController.text = ref.read(loginProvider).inputNick;
    ref.read(loginProvider).nickStep = NickCheckStep.none;
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
              TR(context, '사용자 이름 등록'),
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
                          TR(context, '사용자 이름을\n등록해 주세요.'),
                          style: typo24bold150,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          TR(context, '서비스에서 사용 될 ID(닉네임)입니다.\n가입 후 변경 가능합니다.'),
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
                            controller: textInputController,
                            focusNode: textFocusNode,
                            decoration: InputDecoration(
                              hintText: TR(context, '사용자 이름 입력'),
                            ),
                            keyboardType: TextInputType.name,
                            scrollPadding: EdgeInsets.only(bottom: 200),
                            onChanged: (text) {
                              loginProv.emailInput(text);
                            },
                          ),
                          SizedBox(height: 40.h),
                          InkWell(
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode()); //remove focus
                              if (loginProv.isNickCheckReady) {
                                loginProv.checkNickId().then((result) {
                                  if (result) {

                                  }
                                });
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
                              child: Text(TR(context, '중복 확인'), style: typo16bold),
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
                Navigator.of(context).push(
                    createAniRoute(SignUpBioScreen()));
              },
            ) : DisabledButton(
              text: TR(context, '다음'),
            ),
          ),
        )
    );
  }
}
