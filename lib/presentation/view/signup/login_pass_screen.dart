import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_input_screen.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import 'signup_terms_screen.dart';

class LoginPassScreen extends ConsumerStatefulWidget {
  const LoginPassScreen({Key? key}) : super(key: key);
  static String get routeName => 'loginPassScreen';

  @override
  ConsumerState createState() => _LoginPassScreenState();
}

class _LoginPassScreenState extends ConsumerState<LoginPassScreen> {
  final passInputController = TextEditingController();
  var inputPass = '';

  @override
  void initState() {
    super.initState();
    inputPass = IS_DEV_MODE ? ref.read(loginProvider).inputPass[0] : '';
    passInputController.text = inputPass;
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
              TR(context, '비밀번호 입력'),
              style: typo18semibold,
            ),
            titleSpacing: 0,
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
                        TR(context, '비밀번호를\n입력해 주세요.'),
                        style: typo24bold150,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        TR(context, '회원가입시 생성하신 비밀번호를 입력해 주세요.'),
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
                      _buildInputBox(),
                    ],
                  )
                ),
              ],
            )
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: IS_DEV_MODE || inputPass.isNotEmpty
                ? PrimaryButton(
              text: TR(context, '확인'),
              round: 0,
              onTap: () {
                loginProv.checkWalletPass(inputPass).then((result) async {
                  if (result) {
                    await loginProv.loginEmail();
                    Navigator.of(context).pop(inputPass);
                  } else {
                    Fluttertoast.showToast(
                      msg: "잘못된 패스워드입니다.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.black,
                      textColor: result ? Colors.white : Colors.orange,
                      fontSize: 16.0
                    );
                  }
                });
              },
            ) : DisabledButton(
              text: TR(context, '확인'),
            ),
          ),
        )
    );
  }

  _buildInputBox() {
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: TextField(
        controller: passInputController,
        decoration: InputDecoration(
          hintText: TR(context, '비밀번호 입력'),
        ),
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        scrollPadding: EdgeInsets.only(bottom: 200),
        onChanged: (text) {
          setState(() {
            inputPass = passInputController.text;
          });
        },
      )
    );
  }
}
