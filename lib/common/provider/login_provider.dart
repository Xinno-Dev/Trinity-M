
import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/aesManager.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/domain/model/app_start_model.dart';
import 'package:larba_00/domain/model/login_model.dart';
import 'package:larba_00/domain/model/mdl_check_model.dart';
import 'package:larba_00/presentation/view/asset/asset_screen.dart';
import 'package:larba_00/presentation/view/main_screen.dart';
import 'package:larba_00/presentation/view/sign_password_screen.dart';
import 'package:larba_00/presentation/view/signup/signup_pass_screen.dart';
import 'package:larba_00/presentation/view/signup/signup_email_screen.dart';
import 'package:larba_00/presentation/view/signup/signup_terms_screen.dart';
import 'package:larba_00/services/google_service.dart';
import 'package:larba_00/services/social_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/credentials.dart';
import 'package:crypto/crypto.dart' as crypto;

import '../../data/repository/ecc_repository_impl.dart';
import '../../domain/model/ecckeypair.dart';
import '../../domain/usecase/ecc_usecase.dart';
import '../../domain/usecase/ecc_usecase_impl.dart';
import '../../services/firebase_api_service.dart';
import '../../services/larba_api_service.dart';
import '../const/utils/convertHelper.dart';
import '../const/utils/eccManager.dart';
import '../const/utils/localStorageHelper.dart';
import '../const/widget/dialog_utils.dart';

enum LoginType {
  kakao,
  naver,
  google,
  apple,
  email;

  get title {
    switch(this) {
      case LoginType.kakao:  return '카카오';
      case LoginType.naver:  return '네이버';
      case LoginType.google: return '구글';
      case LoginType.apple:  return '애플';
      default: return '이메일';
    }
  }
}

enum EmailSignUpStep {
  none,
  ready,
  send,
  check,
  complete;
}

enum NickCheckStep {
  none,
  ready,
  complete;
}

enum RecoverPassStep {
  none,
  ready,
  complete;
}

final testEmail = 'jubal2000@gmail.com';

final loginProvider = ChangeNotifierProvider<LoginProvider>((_) {
  return LoginProvider();
});

class LoginProvider extends ChangeNotifier {
  static final _singleton = LoginProvider._internal();
  factory LoginProvider() {
    return _singleton;
  }
  LoginProvider._internal();

  LoginModel? loginInfo;
  bool isLoginCheckDone = false;
  bool isSignUpMode = false;

  var emailStep   = EmailSignUpStep.none;
  var nickStep    = NickCheckStep.none;
  var recoverStep = RecoverPassStep.none;

  var inputEmail = 'jubal2000@gmail.com'; // for test..
  var inputPass   = List.generate(2, (index) => 'testpass00');
  var recoverPass = List.generate(2, (index) => 'recoverpass00');
  var inputNick = 'jubal2000';

  Future<bool> checkLogin() async {
    isLoginCheckDone = false;
    loginInfo = null;
    final localType = await UserHelper().get_loginType();
    var checkLogin = false;
    LOG('-----------> checkLogin : $localType');

    if (localType == LoginType.kakao.name) {
      checkLogin = await checkKakaoLogin();
      LOG('--> checkKakaoLogin : $checkLogin');
      if (checkLogin) {
        final user = await getKakaoUserInfo();
        loginInfo =
            LoginModel.createFromKakao(user); // TODO: 후에 서버에서 가져오는 정보로 대체..
      }
    }
    if (localType == LoginType.google.name) {
      checkLogin = await checkGoogleLogin();
      LOG('--> checkGoogleLogin : $checkLogin');
      if (checkLogin) {
        final user = await getGoogleUserInfo();
        loginInfo = LoginModel.createFromGoogle(user);
      }
    }
    if (localType == LoginType.email.name) {
      checkLogin = await checkEmailLogin();
      LOG('--> checkEmailLogin : $checkLogin');
      if (checkLogin) {
        final user = await getEmailUserInfo(testEmail);
        loginInfo = LoginModel.createFromGoogle(user);
      }
    }
    LOG('-----------------------------');
    if (!checkLogin) {
      await UserHelper().setUser(loginType: '');
    }
    notifyListeners();
    isLoginCheckDone = true;
    return isLogin;
  }

  get isLogin {
    return loginInfo != null;
  }

  loginKakao(BuildContext context) async {
    final user = await startKakaoLogin();
    if (user != null) {
      loginInfo = LoginModel.createFromKakao(user);
      UserHelper().setUser(loginType: LoginType.kakao.name);
    }
    // todo: check signup user..
    if (!isLogin) {
      Navigator.of(context).push(createAniRoute(SignUpPassScreen()));
      return false;
    }
    startWallet(context);
    return isLogin;
  }

  loginNaver() async {
    return isLogin;
  }

  loginGoogle(BuildContext context) async {
    final result = await startGoogleLogin();
    if (result != null) {
      final user = result.runtimeType == User ? result : result?.user;
      loginInfo = LoginModel.createFromGoogle(user);
      UserHelper().setUser(loginType: LoginType.google.name);
      context.replaceNamed('mainScreen');
    }
    notifyListeners();
    return isLogin;
  }

  loginApple() async {
    return isLogin;
  }

  ////////////////////////////////////////////////////////////////////////

  checkWalletPass(String passOrg, {String? email}) async {
    try {
      String? userKey;
      if (STR(email).isNotEmpty) {
        userKey = crypto.sha256.convert(utf8.encode(email!)).toString();
      }
      var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
      var mnemonicEnc = await UserHelper().get_mnemonic(userKeyTmp: userKey);
      LOG('--> checkWalletPass : $inputEmail / $passOrg / $pass -> $mnemonicEnc');
      if (mnemonicEnc != 'NOT_MNEMONIC') {
        var result = await AesManager().decrypt(pass, mnemonicEnc);
        LOG('--> checkWallet mnemonic : $result');
        return result != 'fail';
      }
    } catch (e) {
      LOG('--> checkWallet error : $e');
    }
    return false;
  }

  // passOrg : 실제로 입력받은 패스워드 문자열..
  createNewWallet(String passOrg, {String? email}) async {
    UserHelper().setUserKey(email ?? inputEmail);
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    LOG('--> createNewWallet : ${email ?? inputEmail} / $passOrg -> $pass');
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    var generateKeyResult = await eccImpl.generateKeyPair(pass);
    if (generateKeyResult) {
      // check create complete..
      var result = await checkWalletPass(passOrg);
      LOG('--> createNewWallet success : $result');
      return result;
    } else {
      LOG('--> createNewWallet failed');
    }
    return false;
  }

  startWallet(context) {
    // load local wallet..
    Navigator.of(context).push(createAniRoute(MainScreen()));
  }

  Future<EccKeyPair> getPrivateKey(String passOrg) async {
    var keyData = await UserHelper().get_key();
    var pass    = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    var keyStr  = await AesManager().decrypt(pass, keyData);
    var keyJson = EccKeyPair.fromJson(jsonDecode(keyStr));
    return keyJson;
  }

  createSign(String passOrg, String msg) async {
    try {
      var privateKey = await getPrivateKey(passOrg);
      var signature  = await EccManager().signingEx(privateKey.d, msg);
      LOG('---> createSign : $signature <= $msg');
      return signature;
    } catch (e) {
      LOG('--> createSign error : ${e.toString()}');
    }
    return null;
  }

  createSignedMsg(String passOrg) async {
    var address = await UserHelper().get_address();
    var vfCode = 'vfCode-test-0000';
    var vfCodeEnc = crypto.sha256.convert(utf8.encode(vfCode));
    var msg = '$inputEmail$inputNick$address$vfCodeEnc';
    final sign = await createSign(passOrg, msg);
    if (sign != null) {
      return {
        'email': inputEmail,
        'nickId': inputNick,
        'address': address,
        'sig': sign,
        'verifyCode': vfCodeEnc
      };
    }
  }

  ////////////////////////////////////////////////////////////////////////

  get isEmailSendReady {
    return emailStep == EmailSignUpStep.ready;
  }

  get isEmailSendDone {
    return emailStep == EmailSignUpStep.send;
  }

  get isEmailCheckDone {
    return emailStep == EmailSignUpStep.check;
  }

  get isPassCheckDone {
    return inputPass[0] == inputPass[1];
  }

  get isNickCheckReady {
    return nickStep == NickCheckStep.ready;
  }

  get isNickCheckDone {
    return nickStep == NickCheckStep.complete;
  }

  emailInput(email) {
    inputEmail = email;
    final orgStep = emailStep;
    emailStep = EmailValidator.validate(email) ?
    EmailSignUpStep.ready : EmailSignUpStep.none;
    if (orgStep != emailStep) {
      notifyListeners();
    }
  }

  createEmailVfCode() {
    if (inputEmail.isEmpty) return false;

  }

  emailSend() {
    startEmailSend(inputEmail, (vfCode) {
      if (STR(vfCode).isNotEmpty) {
        emailStep = EmailSignUpStep.check;
        LarbaApiService().sendEmailVfCode(inputEmail, vfCode!);
        notifyListeners();
      }
    });
  }

  checkNickId() {
    // todo: nickname duplicate check API..
    // inputNick
    return true;
  }

  createNewUser(context) {
    final userPass = inputPass.first;
    showLoadingDialog(context, '회원 등록중입니다...');
    createNewWallet(userPass).then((result) {
      if (result) {
        UserHelper().setUser(loginType: LoginType.email.name);
        // TODO: create user API..
        // loginProv.createSignedMsg(userPass).then((signMsg) {
        //   LOG('--> signMsg : $signMsg');
        // });
      }
      hideLoadingDialog();
    });
  }

  signupEmail() {
  }

  loginEmail() {
  }

  ////////////////////////////////////////////////////////////////////////

  get loginType {
    return loginInfo?.loginType;
  }

  toggleLogin() {
    isSignUpMode = !isSignUpMode;
    notifyListeners();
  }

  logout() async {
    loginInfo = null;
    switch(loginType) {
      case LoginType.kakao:
        await startKakaoLogout();
        break;
      case LoginType.google:
        await startGoogleLogout();
        break;
    }
    LOG('--> logout : $loginType');
    await UserHelper().setUser(loginType: 'logout');
    notifyListeners();
  }
}
