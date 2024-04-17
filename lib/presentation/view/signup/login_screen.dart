import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/const/widget/custom_text_form_field.dart';
import 'package:larba_00/common/const/widget/gray_5_button.dart';
import 'package:larba_00/common/const/widget/primary_button.dart';
import 'package:larba_00/common/const/widget/warning_icon.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/presentation/view/authpassword_screen.dart';
import 'package:larba_00/presentation/view/recover_wallet_input_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/SimpleCheckDialog.dart';
import 'package:larba_00/common/style/buttonStyle.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:larba_00/common/style/colors.dart';
import 'package:larba_00/common/style/textStyle.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/appVersionHelper.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/localStorageHelper.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../common/const/widget/rounded_button.dart';
import '../../../common/provider/temp_provider.dart';
import '../../../services/localization_service.dart';
import '../../../services/social_service.dart';
import 'signup_pass_screen.dart';
import 'signup_email_screen.dart';
import 'login_email_screen.dart';
import 'signup_terms_screen.dart';
import '../terms_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  static String get routeName => 'login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with WidgetsBindingObserver {
  FocusNode _focusNode = FocusNode();
  TextEditingController _textEditingController = TextEditingController();
  bool hasAddress = false;
  var isAppUpdateCheckDone = false;
  late FToast fToast;

  final loginButtonH = 40.0;

  Future<void> _addressCheck() async {
    String get_address = await UserHelper().get_address();
    // String? mnemonicCheck;
    // if (get_address != 'NOT_ADDRESS') {
    //   mnemonicCheck = await LocalStorageManager.readData(MNEMONIC_CHECK);
    // }
    // setState(() {
    //   hasAddress = get_address != 'NOT_ADDRESS' && !BOL(mnemonicCheck);
    // });
    setState(() {
      hasAddress = get_address != 'NOT_ADDRESS';
    });
  }

  Future<void> clearWallet() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    isGlobalLogin = false;
    await storage.deleteAll();
    await UserHelper().clearUser();
  }

  Future<void> _showInputDialog() async {
    bool showErrorText = false;
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
            return LayoutBuilder(builder: (context, constraints) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 32.h),
                        child: WarningIcon(),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0),
                        // margin: EdgeInsets.all(0),
                        child: Center(
                          child: Text(
                            TR(context, '지갑 초기화 유의사항'),
                            style: typo16semibold,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: TR(context, 'reset_00'),
                          style: typo14medium150.copyWith(color: GRAY_70),
                          children: [
                            TextSpan(
                              text: TR(context, 'reset_01'),
                            ),
                            TextSpan(
                                text: TR(context, 'reset_02'),
                                style: TextStyle(color: PRIMARY_90)),
                            TextSpan(text: TR(context, 'reset_03')),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 19.0),
                        child: CustomTextFormField(
                            hintText: TR(context, '입력하기'),
                            constraints: constraints,
                            focusNode: _focusNode,
                            controller: _textEditingController),
                      ),
                      if (showErrorText)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                TR(context, '문구가 일치하지 않습니다'),
                                style: typo14regular.copyWith(color: ERROR_90),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        height: 32,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.pop();
                                  _textEditingController.clear();
                                },
                                child: Text(
                                  TR(context, '취소'),
                                  style: typo14bold100.copyWith(
                                      color: SECONDARY_90),
                                ),
                                style: popupGrayButtonStyle.copyWith(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      // side: BorderSide(),
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.zero,
                                        bottomLeft: Radius.circular(8.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 48.h,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_textEditingController.text ==
                                    TR(context, '초기화')) {
                                    // TODO: 초기화 후 다시 첫 화면으로 돌아가도록
                                    print('초기화!!');
                                    clearWallet();
                                    _addressCheck();
                                    context.pop();
                                    fToast.showToast(
                                      child: CustomToast(
                                        msg: TR(context, '지갑이 초기화되었습니다'),
                                      ),
                                      gravity: ToastGravity.BOTTOM,
                                      toastDuration: Duration(seconds: 2),
                                    );
                                    setState(() {});
                                  } else {
                                    stateSetter(() {
                                      showErrorText = true;
                                    });
                                  }
                                },
                                child: Text(
                                  TR(context, '초기화 하기'),
                                  style: typo14bold100.copyWith(color: WHITE),
                                ),
                                style: popupSecondaryButtonStyle.copyWith(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) => SECONDARY_90,
                                  ),
                                  overlayColor:
                                      MaterialStateProperty.all(SECONDARY_90),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      // side: BorderSide(),
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(8.r),
                                        bottomLeft: Radius.zero,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          });
        });
  }

  @override
  void initState() {
    super.initState();
    _addressCheck();
    isRecoverLogin = false;
    fToast = FToast();
    fToast.init(context);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkAppUpdate(context).then((result) {
        LOG('----> checkAppUpdate result 1 : $result');
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('---> didChangeAppLifecycleState : $state');
    if (state == AppLifecycleState.resumed) {
      setState(() {
        checkAppUpdate(context).then((result) {
          LOG('----> checkAppUpdate result 2 : $result');
        });
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final loginProv = ref.watch(loginProvider);
    LOG('---> LoginScreen isSocialLogin : ${loginProv.isLogin}');
    if (loginProv.isLogin) {
      LOG('--> loginType : ${loginProv.loginType}');
    }
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: WHITE,
        body: SafeArea(
          // bottom: false,
          child: LayoutBuilder(builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                height: double.infinity,
                child: Stack(
                  // crossAxisAlignment: loginProv.isLogin ?
                  //   CrossAxisAlignment.end : CrossAxisAlignment.center,
                  // mainAxisSize: MainAxisSize.max,
                  children: [
                    // Spacer(),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 400,
                        margin: EdgeInsets.only(top: 40),
                        child: SvgPicture.asset(
                          'assets/svg/logo.svg',
                        ),
                      ),
                    ),
                    if (loginProv.isLoginCheckDone)...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // if (loginProv.isLogin)...[
                          //   _buildPinLoginBox(),
                          // ],
                          if (!loginProv.isLogin)...[
                            _buildEmailBox(),
                            _buildCenterLine(),
                            _buildSocialBox(),
                            _buildCreateBox(),
                          ],
                          SizedBox(height: 100),
                        ],
                      ),
                    ],
                    if (!loginProv.isLoginCheckDone)...[
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 80),
                          child: CircularProgressIndicator()
                        ),
                      )
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  _buildPinLoginBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          PrimaryButton(
            onTap: () {
              if (hasAddress) {
                context.pushNamed(
                  AuthPasswordScreen.routeName,
                  queryParams: {'auth': 'true'});
              } else {
                context.pushNamed(TermsScreen.routeName);
              }
            },
            text: hasAddress ? TR(context, '잠금 해제') :
            TR(context, '지갑 만들기'),
          ),
          SizedBox(
            height: 16.h,
          ),
          Gray5Button(
            onTap: () {
              hasAddress
                  ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleCheckDialog(
                    hasIcon: true,
                    icon: WarningIcon(),
                    hasTitle: true,
                    titleString: TR(context, '지갑 초기화 유의사항'),
                    infoString: TR(context,
                      '지갑 복구는 비밀 복구 구문을 입력하여\n'
                      '복구하는 과정이며, 먼저 지갑을\n'
                      '초기화 한 후 진행할 수 있습니다.\n\n'
                      '지갑을 초기화 하면 지갑의 계정 정보 및 자산이 본 기기에서 제거 되며\n'
                      '취소할 수 없습니다.\n\n'
                      '정말로 지갑을 초기화 하시겠습니까?',
                    ),
                    hasOptions: true,
                    defaultButtonText: TR(context, '취소'),
                    optionButtonText: TR(context, '다음'),
                    onTapOption: () {
                      Navigator.pop(context);
                      _showInputDialog();
                    },
                  );
                },
              )
              : context.pushNamed(
              RecoverWalletInputScreen.routeName);
            },
            text: hasAddress ?
            TR(context, '지갑 초기화') : TR(context, '지갑 복구'),
          ),
          SizedBox(height: 10.h),
          _buildLogoutButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  _buildEmailBox() {
    final isSignUp = ref.read(loginProvider).isSignUpMode;
    return Container(
      width: 320,
      margin: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Container(
            height: 30.h,
            margin: EdgeInsets.only(bottom: 10.h),
            child: Text(
              TR(context, isSignUp ? '회원가입' : '로그인'),
              style: typo16bold.copyWith(color: PRIMARY_100),
            ),
          ),
          InkWell(
            onTap: () {
              if (isSignUp) {
                Navigator.of(context)
                    .push(createAniRoute(SignUpEmailScreen()))
                    .then((email) {
                  if (STR(email).isNotEmpty) {
                    _startLogin(-1);
                  }
                });
              } else {
                Navigator.of(context)
                    .push(createAniRoute(LoginEmailScreen()))
                    .then((result) {
                  if (BOL(result)) {
                    ref.read(loginProvider).startWallet(context);
                  }
                });
              }
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 2, color: GRAY_30)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/svg/icon_mail.svg'),
                  SizedBox(width: 10),
                  Text(
                    TR(context, '이메일로 ${isSignUp ? '회원가입' : '로그인'}'),
                    style: typo14bold,
                  )
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  _buildCenterLine() {
    return Container(
      width: 320,
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: GRAY_10)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              TR(context, '또는'),
              style: typo12normal,
            ),
          ),
          Expanded(child: Container(height: 1, color: GRAY_10)),
        ],
      ),
    );
  }

  _buildSocialBox() {
    final iconSize = 60.0;
    return Container(
      height: iconSize,
      margin: EdgeInsets.symmetric(vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) => GestureDetector(
          onTap: () {
            _startLogin(index);
          },
          child: Image.asset('assets/images/login_icon_$index.png',
            width: iconSize, height: iconSize),
        )).toList(),
      ),
    );
  }

  _startLogin(index) {
    final loginProv = ref.read(loginProvider);
    switch(index) {
      case 0:  loginProv.loginKakao(context); break;
      case 1:  loginProv.loginNaver(); break;
      case 2:  loginProv.loginGoogle(context); break;
      case 3:  loginProv.loginApple(); break;
      default: loginProv.loginEmail();
    }
  }

  _buildLogoutButton() {
    final loginProv = ref.read(loginProvider);
    return GestureDetector(
      onTap: () {
        loginProv.logout();
      },
      child: Container(
        padding: EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text('${loginProv.loginType.title} 로그아웃', style: typo12semibold100),
      )
    );
  }

  _buildCreateBox() {
    final isSignUp = ref.read(loginProvider).isSignUpMode;
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              ref.read(loginProvider).toggleLogin();
            },
            child: Column(
              children: [
                Text(
                  TR(context, isSignUp ? '로그인' : '회원가입'),
                  style: typo14normal.copyWith(color: GRAY_50),
                ),
                Container(
                  width: 80,
                  height: 1,
                  color: GRAY_50,
                )
              ],
            )
          ),
          Container(
            height: 15,
            width: 2,
            color: GRAY_20,
            margin: EdgeInsets.symmetric(horizontal: 20),
          ),
          InkWell(
            onTap: () {

            },
            child: Column(
              children: [
                Text(
                  TR(context, 'ID/PW 찾기'),
                  style: typo14normal.copyWith(color: GRAY_50),
                ),
                Container(
                  width: 80,
                  height: 1,
                  color: GRAY_50,
                )
              ],
            )
          ),
        ],
      ),
    );
  }
}

class Data {
  String? uid;
  String? publicKey;
  String? pushToken;

  Data({this.uid, this.publicKey, this.pushToken});

  Data.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    publicKey = json['publicKey'];
    pushToken = json['pushToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['publicKey'] = this.publicKey;
    data['pushToken'] = this.pushToken;
    return data;
  }
}
