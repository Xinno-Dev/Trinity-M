import 'package:flutter/services.dart';
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_input_screen.dart';
import 'package:larba_00/presentation/view/registMnemonic_screen.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import 'signup_terms_screen.dart';

class SignUpPassScreen extends ConsumerStatefulWidget {
  const SignUpPassScreen({Key? key, this.isSignUpMode = true}) : super(key: key);
  static String get routeName => 'signUpPassScreen';
  final bool isSignUpMode;

  @override
  ConsumerState createState() => _SignUpPassScreenState();
}

class _SignUpPassScreenState extends ConsumerState<SignUpPassScreen> {
  final passInputController = List.generate(2, (index) => TextEditingController());
  var inputPass = List.generate(2, (index) => '');

  @override
  void initState() {
    super.initState();
    passInputController[0].text = ref.read(loginProvider).inputPass[0];
    passInputController[1].text = ref.read(loginProvider).inputPass[1];
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
              TR(context, '비밀번호 등록'),
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
                          TR(context, '비밀번호를\n등록해 주세요.'),
                          style: typo24bold150,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          TR(context, '비밀번호 등록을 진행합니다.'),
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
                        for (var index=0; index<2; index++)
                          _buildInputBox(index),
                      ],
                    )
                  ),
                ],
              )
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: IS_DEV_MODE || loginProv.isPassCheckDone
                ? PrimaryButton(
              text: TR(context, '다음'),
              round: 0,
              onTap: () {
                Navigator.of(context).push(createAniRoute(SignUpTermsScreen()));
              },
            ) : DisabledButton(
              text: TR(context, '다음'),
            ),
          ),
        )
    );
  }

  _buildInputBox(int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: TextField(
      controller: passInputController[index],
      decoration: InputDecoration(
        hintText: TR(context, index == 0 ? '비밀번호 입력' : '비밀번호 재입력'),
      ),
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      scrollPadding: EdgeInsets.only(bottom: 200),
      onChanged: (text) {
        inputPass[index] = passInputController[index].text;
      },
    ));
  }
}
