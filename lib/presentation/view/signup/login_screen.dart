import 'package:trinity_m_00/common/const/utils/userHelper.dart';

import '../../../presentation/view/signup/login_restore_screen.dart';
import '../../../common/common_package.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/provider/login_provider.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/provider/temp_provider.dart';
import '../main_screen.dart';
import 'signup_pass_screen.dart';
import 'signup_email_screen.dart';
import 'login_email_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  LoginScreen({this.isAppStart = true, this.isWillReturn = false, super.key});
  static String get routeName => 'loginScreen';
  bool isAppStart;
  bool isWillReturn;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with WidgetsBindingObserver {
  FocusNode _focusNode = FocusNode();
  TextEditingController _textEditingController = TextEditingController();
  bool hasAddress = false;
  var isAppUpdateCheckDone = false;
  var isShowToast = true;
  var loginButtonH = 40.0;

  @override
  void initState() {
    super.initState();
    isRecoverLogin = false;
  }

  @override
  void didChangeDependencies() {
    if (!widget.isAppStart && isShowToast) {
      showToast(TR(context, '로그인이 필요한 서비스입니다.'));
      isShowToast = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final prov = ref.watch(loginProvider);
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: WHITE,
        appBar: !widget.isAppStart ? defaultAppBar(TR(context, '로그인')) : null,
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
                              TR(context, prov.isSignUpMode ? '회원가입' : '로그인'),
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
                        TR(context, '이메일로 ${isSignUp ? '회원가입' : '로그인'}'),
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
                      TR(context, '카카오로 ${isSignUp ? '회원가입' : '로그인'}'),
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

  Future<bool?> _startLogin(index) async {
    final loginProv = ref.read(loginProvider);
    bool? result = false;
    switch(index) {
      case 0: result = await loginProv.loginKakao(context, onError: _loginError); break;
      case 1: result = await loginProv.loginGoogle(onError: _loginError); break;
    // case 2:  loginProv.loginNaver(); break;
    // case 3:  loginProv.loginApple(); break;
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
    showLoginErrorDialog(context, type, text: error).then((_) async {
      if (error == '__not_found__') {
        final loginProv = ref.read(loginProvider);
        loginProv.logoutWithRemoveNickId();
      }
    });
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
        ],
      ),
    );
  }
}
