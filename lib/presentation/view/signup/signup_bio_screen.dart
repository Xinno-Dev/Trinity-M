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
import 'signup_pass_screen.dart';
import 'signup_mnemonic_screen.dart';

class SignUpBioScreen extends ConsumerStatefulWidget {
  const SignUpBioScreen({Key? key, this.isSignUpMode = true}) : super(key: key);
  static String get routeName => 'signUpBioScreen';
  final bool isSignUpMode;

  @override
  ConsumerState createState() => _SignUpBioScreenState();
}

class _SignUpBioScreenState extends ConsumerState<SignUpBioScreen> {
  @override
  void initState() {
    super.initState();
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
            TR(context, '생체인증 등록'),
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
                        TR(context, '빠른 이용을 위해\n생체인증을 설정하세요.'),
                        style: typo24bold150,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        TR(context, '본인확인 목적으로 기기에 등록된 생체정보를\n이용하여 지갑의 로그인 및 인증을 대체합니다.\n서버로 전송/저장되지 않습니다.'),
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
                  createAniRoute(SignUpMnemonicScreen()));
            },
          ) : DisabledButton(
            text: TR(context, '다음'),
          ),
        ),
      )
    );
  }
}
