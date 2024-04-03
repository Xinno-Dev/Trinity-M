
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
import 'package:larba_00/presentation/view/signup/create_pass_screen.dart';
import 'package:larba_00/presentation/view/signup/input_email_screen.dart';
import 'package:larba_00/presentation/view/signup/signup_terms_screen.dart';
import 'package:larba_00/services/social_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/credentials.dart';
import 'package:crypto/crypto.dart' as crypto;

import '../../data/repository/ecc_repository_impl.dart';
import '../../domain/usecase/ecc_usecase.dart';
import '../../domain/usecase/ecc_usecase_impl.dart';
import '../../services/firebase_api_service.dart';
import '../../services/larba_api_service.dart';
import '../const/utils/convertHelper.dart';
import '../const/utils/localStorageHelper.dart';

enum LoginType {
  kakao,
  naver,
  google,
  apple,
  email;

  get title {
    switch(this) {
      case LoginType.kakao:   return '카카오';
      case LoginType.google:  return '구글';
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

final testEmail = 'jubal2000@gmail.com';

final loginProvider = ChangeNotifierProvider<LoginProvider>((_) {
  return LoginProvider();
});

class LoginProvider extends ChangeNotifier {
  LoginModel? loginInfo;
  bool isLoginCheckDone = false;
  bool isSignUpMode = false;

  var emailStep = EmailSignUpStep.none;
  var inputEmail = 'jubal2000@gmail.com'; // for test..
  var inputPass = List.generate(2, (index) => 'testpass00');

  LoginProvider() {
  }

  checkLogin() async {
    isLoginCheckDone = false;
    loginInfo = null;
    LOG('-----------> checkLogin');

    var checkLogin = await checkKakaoLogin();
    LOG('--> checkKakaoLogin : $checkLogin');
    if (checkLogin) {
      final user = await getKakaoUserInfo();
      loginInfo = LoginModel.createFromKakao(user); // TODO: 후에 서버에서 가져오는 정보로 대체..
    }
    if (!checkLogin) {
      checkLogin = await checkGoogleLogin();
      LOG('--> checkGoogleLogin : $checkLogin');
      if (checkLogin) {
        final user = await getGoogleUserInfo();
        loginInfo = LoginModel.createFromGoogle(user);
      }
    }
    if (!checkLogin) {
      checkLogin = await checkEmailLogin();
      LOG('--> checkEmailLogin : $checkLogin');
      if (checkLogin) {
        final user = await getEmailUserInfo(testEmail);
        loginInfo = LoginModel.createFromGoogle(user);
      }
    }
    LOG('-----------------------------');
    notifyListeners();
    isLoginCheckDone = true;
    return isLogin;
  }

  get isLogin {
    return loginInfo != null;
  }

  loginKakao(context) async {
    final user = await startKakaoLogin();
    if (user != null) {
      loginInfo = LoginModel.createFromKakao(user);
    }
    // todo: check signup user..
    if (!isLogin) {
      Navigator.of(context).push(createAniRoute(CreatePassScreen()));
      return false;
    }
    startWallet(context);
    return isLogin;
  }

  loginNaver() async {
    return isLogin;
  }

  loginGoogle() async {
    final result = await startGoogleLogin();
    if (result != null) {
      final user = result.runtimeType == User ? result : result?.user;
      loginInfo = LoginModel.createFromGoogle(user);
    }
    notifyListeners();
    return isLogin;
  }

  loginApple() async {
    return isLogin;
  }

  ////////////////////////////////////////////////////////////////////////

  checkWalletPass(String passOrg) async {
    try {
      var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
      var mnemonicEnc = await UserHelper().get_mnemonic();
      print('--> checkWalletPass : $inputEmail / $passOrg / $pass -> $mnemonicEnc');
      if (mnemonicEnc != 'NOT_MNEMONIC') {
        var result = await AesManager().decrypt(pass, mnemonicEnc);
        print('--> checkWallet mnemonic : $result');
        return result != 'fail';
      }
    } catch (e) {
      print('--> checkWallet error : $e');
    }
    return false;
  }

  // passOrg : 실제로 입력받은 패스워드 문자열..
  createNewWallet(String passOrg, {String? email}) async {
    UserHelper().setUserKey(email ?? inputEmail);
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    print('--> createNewWallet : ${email ?? inputEmail} / $passOrg -> $pass');
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    var generateKeyResult = await eccImpl.generateKeyPair(pass);
    if (generateKeyResult) {
      // check create complete..
      var result = await checkWalletPass(passOrg);
      print('--> createNewWallet success : $result');
      return result;
    } else {
      print('--> createNewWallet failed');
    }
    return false;
  }

  startWallet(context) {
    // load local wallet..
    Navigator.of(context).push(createAniRoute(MainScreen()));
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

  signupEmail() {
  }

  loginEmail() {
  }

  ////////////////////////////////////////////////////////////////////////

  get loginType {
    return loginInfo?.loginType ?? LoginType.email;
  }

  toggleLogin() {
    isSignUpMode = !isSignUpMode;
    notifyListeners();
  }

  logout() async {
    switch(loginType) {
      case LoginType.kakao:
        await startKakaoLogout();
        break;
      case LoginType.google:
        await startGoogleLogout();
        break;
    }
    loginInfo = null;
    notifyListeners();
  }
}
