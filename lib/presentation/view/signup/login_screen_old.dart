import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../presentation/view/signup/login_restore_screen.dart';
import '../../../common/common_package.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/widget/custom_text_form_field.dart';
import '../../../common/const/widget/gray_5_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/const/widget/warning_icon.dart';
import '../../../common/provider/login_provider.dart';
import '../../../presentation/view/authpassword_screen.dart';
import '../../../presentation/view/recover_wallet_input_screen.dart';
import '../../../common/const/utils/userHelper.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/appVersionHelper.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/localStorageHelper.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../common/const/widget/rounded_button.dart';
import '../../../common/provider/market_provider.dart';
import '../../../common/provider/temp_provider.dart';
import '../../../services/localization_service.dart';
import '../../../services/social_service.dart';
import '../main_screen.dart';
import 'signup_pass_screen.dart';
import 'signup_email_screen.dart';
import 'login_email_screen.dart';
import 'signup_terms_screen.dart';
import '../terms_screen.dart';

class LoginScreenOld extends ConsumerStatefulWidget {
  LoginScreenOld({this.isAppStart = true, this.isWillReturn = false, super.key});
  static String get routeName => 'loginScreenOld';
  bool isAppStart;
  bool isWillReturn;

  @override
  ConsumerState<LoginScreenOld> createState() => _LoginScreenOldState();
}

class _LoginScreenOldState extends ConsumerState<LoginScreenOld>
  with WidgetsBindingObserver {
  FocusNode _focusNode = FocusNode();
  TextEditingController _textEditingController = TextEditingController();
  bool hasAddress = false;
  var isAppUpdateCheckDone = false;
  var isShowToast = true;
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
                          TR('지갑 초기화 유의사항'),
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
                        text: TR('reset_00'),
                        style: typo14medium150.copyWith(color: GRAY_70),
                        children: [
                          TextSpan(
                            text: TR('reset_01'),
                          ),
                          TextSpan(
                              text: TR('reset_02'),
                              style: TextStyle(color: PRIMARY_90)),
                          TextSpan(text: TR('reset_03')),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 19.0),
                      child: CustomTextFormField(
                          hintText: TR('입력하기'),
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
                              TR('문구가 일치하지 않습니다'),
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
                                TR('취소'),
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
                                  TR('초기화')) {
                                  // TODO: 초기화 후 다시 첫 화면으로 돌아가도록
                                  print('초기화!!');
                                  clearWallet();
                                  _addressCheck();
                                  context.pop();
                                  fToast.showToast(
                                    child: CustomToast(
                                      msg: TR('지갑이 초기화되었습니다'),
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
                                TR('초기화 하기'),
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
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   checkAppUpdate(context).then((result) {
    //     LOG('----> checkAppUpdate result 1 : $result');
    //   });
    // });
  }

  @override
  void didChangeDependencies() {
    if (!widget.isAppStart && isShowToast) {
      showToast(TR('로그인이 필요한 서비스입니다.'));
      isShowToast = false;
    }
    super.didChangeDependencies();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   print('---> didChangeAppLifecycleState : $state');
  //   if (state == AppLifecycleState.resumed) {
  //     setState(() {
  //       checkAppUpdate(context).then((result) {
  //         LOG('----> checkAppUpdate result 2 : $result');
  //       });
  //     });
  //   }
  // }

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
    final prov = ref.watch(loginProvider);
    // LOG('---> loginProv.isLogin : ${loginProv.isLogin}');
    // if (loginProv.isLogin) {
    //   LOG('--> loginType : ${loginProv.loginType}');
    // }
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: WHITE,
        appBar: !widget.isAppStart ? AppBar(
          title: Text(TR('로그인'), style: typo16bold),
          centerTitle: true,
          backgroundColor: Colors.white,
        ) : null,
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
                        height: 400 - (!widget.isAppStart ? kToolbarHeight : 0),
                        margin: EdgeInsets.only(top: 40),
                        child: logoWidget(),
                      ),
                    ),
                    if (prov.isLoginCheckDone)...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // if (loginProv.isLogin)...[
                          //   _buildPinLoginBox(),
                          // ],
                          Container(
                            height: 30.h,
                            margin: EdgeInsets.only(bottom: 10.h),
                            child: Text(
                              TR(prov.isSignUpMode ? '회원가입' : '로그인'),
                              style: typo16bold.copyWith(color: PRIMARY_100),
                            ),
                          ),
                          if (!prov.isLogin)...[
                            _buildEmailBox(),
                            _buildKakaoBox(),
                            // _buildCenterLine(),
                            // _buildSocialBox(),
                            _buildCreateBox(),
                          ],
                          SizedBox(height: 100),
                        ],
                      ),
                    ],
                    if (!prov.isLoginCheckDone)...[
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
            text: hasAddress ? TR('잠금 해제') :
            TR('지갑 만들기'),
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
                    titleString: TR('지갑 초기화 유의사항'),
                    infoString: TR(
                      '지갑 복구는 비밀 복구 구문을 입력하여\n'
                      '복구하는 과정이며, 먼저 지갑을\n'
                      '초기화 한 후 진행할 수 있습니다.\n\n'
                      '지갑을 초기화 하면 지갑의 계정 정보 및 자산이 본 기기에서 제거 되며\n'
                      '취소할 수 없습니다.\n\n'
                      '정말로 지갑을 초기화 하시겠습니까?',
                    ),
                    hasOptions: true,
                    defaultButtonText: TR('취소'),
                    optionButtonText: TR('다음'),
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
            TR('지갑 초기화') : TR('지갑 복구'),
          ),
          SizedBox(height: 10.h),
          _buildLogoutButton(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  _buildEmailBox() {
    final loginProv = ref.read(loginProvider);
    final isSignUp  = loginProv.isSignUpMode;
    return Container(
      width: 320,
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // clean user info..
              loginProv.init();
              if (isSignUp) {
                Navigator.of(context)
                    .push(createAniRoute(SignUpEmailScreen()));
              } else {
                Navigator.of(context)
                    .push(createAniRoute(LoginEmailScreen()))
                    .then((result) {
                  if (BOL(result)) {
                    _startWallet();
                  }
                });
              }
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(width: 1, color: GRAY_50)
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SvgPicture.asset('assets/svg/icon_mail.svg'),
                  ),
                  Center(
                    child: Text(
                      TR('이메일로 ${isSignUp ? '회원가입' : '로그인'}'),
                      style: typo14bold,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  _startWallet() {
    LOG('---> startWallet : ${widget.isWillReturn}');
    final loginProv = ref.read(loginProvider);
    loginProv.mainPageIndexOrg = 0;
    if (widget.isWillReturn) {
      context.pop(true);
    } else {
      context.pushReplacementNamed(
          MainScreen.routeName, queryParams: {'selectedPage': '1'});
    }
  }

  _startRestore(index) {
    final loginProv = ref.read(loginProvider);
    LOG('---> _startRestore : $index / ${loginProv.userEmail}');
    // 기존 회원가입된 메일인지 체크..
    loginProv.emailDupCheck(loginProv.userEmail).then((result) {
      if (result) {
        // 니모닉 복구 화면으로 이동..
        Navigator.of(context).push(
            createAniRoute(LoginRestoreScreen())).then((rResult) {
          LOG('----> LoginRestoreScreen result : $rResult');
          if (rResult == true) {
            _startLogin(index);
          }
        });
        showLoginErrorDialog(context,
            LoginErrorType.recoverRequire, text: loginProv.userEmail);
      } else {
        showLoginErrorDialog(context,
            LoginErrorType.signupRequire, text: loginProv.userEmail);
      }
    });
  }

  _buildKakaoBox() {
    final loginProv = ref.read(loginProvider);
    final isSignUp  = loginProv.isSignUpMode;
    return Container(
      width: 320,
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // clean user info..
              loginProv.init();
              if (isSignUp) {
                loginProv.initSignUpKakao(onError: (code, text) {
                  showLoginErrorDialog(context, code, text: text);
                }).then((result) {
                  if (result == true) {
                    Navigator.of(context)
                        .push(createAniRoute(SignUpPassScreen()));
                  }
                });
              } else {
                _startLogin(LoginType.kakaotalk.index);
              }
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      child: Image.asset('assets/images/login_kakao.png'),
                    ),
                  ),
                  Center(
                    child: Text(
                      TR('카카오로 시작하기'),
                      style: typo14bold,
                    ),
                  )
                ],
              ),
            )
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
              TR('또는'),
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
        children: List.generate(2, (index) => GestureDetector(
          onTap: () {
            _startLogin(index);
          },
          child: Image.asset('assets/images/login_icon_$index.png',
            width: iconSize, height: iconSize),
        )).toList(),
      ),
    );
  }

  Future<bool?> _startLogin(index) async {
    final loginProv = ref.read(loginProvider);
    bool? result = false;
    switch(index) {
      case 0: result = await loginProv.loginKakao(onError: _loginError); break;
      case 1: result = await loginProv.loginGoogle(onError: _loginError); break;
      // case 2:  loginProv.loginNaver(); break;
      // case 3:  loginProv.loginApple(); break;
      default: result = await loginProv.loginEmail(onError: _loginError);
    }
    if (result == true) {
      _startWallet();
    } else if (result == null) {
      _startRestore(index);
    }
    return result;
  }

  _loginError(LoginErrorType type, String? error) {
    LOG('--> _loginError : $type, $error');
    showLoginErrorDialog(context, type, text: error);
  }

  _buildLogoutButton() {
    final loginProv = ref.read(loginProvider);
    return GestureDetector(
      onTap: () {
        loginProv.logout().then((_) {
          showToast(TR('로그아웃 완료'));
        });
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
                  TR(isSignUp ? '로그인' : '회원가입'),
                  style: typo14semibold.copyWith(color: GRAY_50),
                ),
                Container(
                  width: 60.w,
                  height: 1,
                  color: GRAY_50,
                )
              ],
            )
          ),
          // Container(
          //   height: 15,
          //   width: 2,
          //   color: GRAY_20,
          //   margin: EdgeInsets.symmetric(horizontal: 20),
          // ),
          // InkWell(
          //   onTap: () {
          //
          //   },
          //   child: Column(
          //     children: [
          //       Text(
          //         TR('ID/PW 찾기'),
          //         style: typo14normal.copyWith(color: GRAY_50),
          //       ),
          //       Container(
          //         width: 80,
          //         height: 1,
          //         color: GRAY_50,
          //       )
          //     ],
          //   )
          // ),
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
