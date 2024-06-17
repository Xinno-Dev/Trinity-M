import 'dart:math';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../presentation/view/asset/networkScreens/network_input_screen.dart';

import '../../../common/common_package.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../registLocalAuth_screen.dart';
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
  String? _errorText;

  @override
  void initState() {
    super.initState();
    textInputController.text = ref.read(loginProvider).inputNick;
    ref.read(loginProvider).nickStep = textInputController.text.isNotEmpty ?
      NickCheckStep.ready : NickCheckStep.none;
  }

  @override
  Widget build(BuildContext context) {
    final loginProv = ref.watch(loginProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: defaultAppBar(TR('사용자 이름 등록')),
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
                      padding: EdgeInsets.only(top: 30.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TR('사용자 이름을\n등록해 주세요.'),
                            style: typo24bold150,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            TR('서비스에서 사용 될 ID(닉네임)입니다.\n가입 후 변경 가능합니다.'),
                            style: typo16medium150.copyWith(
                              color: GRAY_70,
                            ),
                          ),
                        ],
                      ),
                    )),
                    Expanded(
                      flex: constraints.maxHeight > 500 ? 2 : 1,
                      child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Column(
                        children: [
                          TextField(
                            controller: textInputController,
                            focusNode: textFocusNode,
                            decoration: InputDecoration(
                              hintText: TR('사용자 이름 입력'),
                              errorText:  _errorText
                            ),
                            keyboardType: TextInputType.name,
                            scrollPadding: EdgeInsets.only(bottom: 100),
                            maxLength: NICK_LENGTH_MAX,
                            onChanged: (text) {
                              setState(() {
                                _errorText = loginProv.nickInput(text);
                              });
                            },
                          ),
                          SizedBox(height: 20.h),
                          InkWell(
                            onTap: () {
                              FocusScope.of(context).requestFocus(
                                  FocusNode()); //remove focus
                              if (loginProv.isNickCheckReady) {
                                loginProv.checkNickId(onError: (type) =>
                                    showLoginErrorDialog(context, type)).then((
                                    result) {
                                  if (BOL(result)) {
                                    showToast(TR('중복 확인 완료'));
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
                                border: !loginProv.isNickCheckReady ? Border.all(
                                    width: 2, color: GRAY_20) : null,
                                color: loginProv.isNickCheckReady
                                    ? PRIMARY_90
                                    : WHITE
                              ),
                              child: Text(TR('중복 확인'), style: typo14bold),
                            ),
                          ),
                        ],
                      )
                    )),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: loginProv.isNickCheckDone
                    ? PrimaryButton(
                      text: TR('다음'),
                      round: 0,
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode()); //remove focus
                        showLoadingDialog(context, TR('회원 가입중입니다...'));
                        Future.delayed(Duration(milliseconds: 200)).then((_) {
                          loginProv.signUpUser().then((result) {
                            hideLoadingDialog();
                            if (loginProv.isLogin) {
                              BiometricStorage().canAuthenticate().then((response) {
                                LOG('---> canAuthenticate : $response');
                                if (response == CanAuthenticateResponse.success) {
                                  Navigator.of(context).push(
                                      createAniRoute(SignUpBioScreen()));
                                } else {
                                  Navigator.of(context).push(
                                      createAniRoute(SignUpMnemonicScreen()));
                                }
                              });
                            }
                            showToast(TR(
                                loginProv.isLogin ? '회원가입 성공' : '회원가입 실패'));
                          });
                        });
                      },
                    ) : DisabledButton(
                      text: TR('다음'),
                    ),
                  ),
                ],
              )
            );
          }
        ),
      )
    );
  }
}
