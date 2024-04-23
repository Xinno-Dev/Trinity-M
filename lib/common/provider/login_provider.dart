
import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/aesManager.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/domain/model/user_model.dart';
import 'package:larba_00/presentation/view/main_screen.dart';
import 'package:larba_00/presentation/view/signup/signup_pass_screen.dart';
import 'package:larba_00/services/social_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:secp256k1cipher/secp256k1cipher.dart';
import 'package:uuid/uuid.dart';

import '../../data/repository/ecc_repository_impl.dart';
import '../../domain/model/account_model.dart';
import '../../domain/model/address_model.dart';
import '../../domain/model/ecckeypair.dart';
import '../../domain/usecase/ecc_usecase_impl.dart';
import '../../services/google_service.dart';
import '../../services/larba_api_service.dart';
import '../const/utils/convertHelper.dart';
import '../const/utils/eccManager.dart';
import '../const/utils/languageHelper.dart';
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

final testEmail = 'jubal2000@hanmail.net';

final loginProvider = ChangeNotifierProvider<LoginProvider>((_) {
  return LoginProvider();
});

class LoginProvider extends ChangeNotifier {
  static final _singleton = LoginProvider._internal();
  factory LoginProvider() {
    return _singleton;
  }
  LoginProvider._internal();

  UserModel? userInfo;
  String? currentAddress;

  bool isLoginCheckDone = false;
  bool isSignUpMode = false;

  var emailStep   = EmailSignUpStep.none;
  var nickStep    = NickCheckStep.none;
  var recoverStep = RecoverPassStep.none;

  var inputNick   = 'jubal2000';
  var inputEmail  = testEmail; // for test..
  var inputPass   = List.generate(2, (index) => 'testpass00');
  var recoverPass = List.generate(2, (index) => 'recoverpass00');

  Future<bool> checkLogin() async {
    isLoginCheckDone = false;
    userInfo = null;
    var startLoginType = await UserHelper().get_loginType();
    var checkLogin = false;
    LOG('-----------> checkLogin local : $startLoginType');

    if (startLoginType == LoginType.kakao.name) {
      if (await checkKakaoLogin()) {
        try {
          var token = await UserHelper().get_token();
          LOG('--> kakao local token $token');
          kakao.User? user;
          if (token != null) {
            user = await getKakaoUserInfo();
          } else {
            // 토큰이 없을 경우 다시 로그인..
            user = await startKakaoLogin();
          }
          if (user != null) {
            userInfo = UserModel.createFromKakao(user);
            // TODO: 카카오 정보 가저온후 서버에 로그인 필요..
            checkLogin = true;
          }
        } catch (error) {
          LOG('--> kakao 로그인 실패 $error');
        }
      }
    }
    if (startLoginType == LoginType.google.name) {
      checkLogin = await checkGoogleLogin();
      LOG('--> checkGoogleLogin : $checkLogin');
      if (checkLogin) {
        final user = await getGoogleUserInfo();
        userInfo = UserModel.createFromGoogle(user);
      }
    }
    if (startLoginType == LoginType.email.name) {
      var check = await checkEmailLogin();
      LOG('--> checkEmailLogin : $check');
      if (check) {
        final user = await getEmailUserInfo(testEmail);
        if (user != null) {
          checkLogin = true;
          userInfo = UserModel.createFromGoogle(user);
        }
      }
    }

    LOG('-----------------------------');
    if (!isLogin) {
      // clear login record..
      await UserHelper().setUser(
        loginType: '',
        token: ''
      );
    }
    notifyListeners();
    isLoginCheckDone = true;
    return isLogin;
  }

  get isLogin {
    return userInfo != null;
  }

  get account async {
    LOG('-----> wallet currentAddress : $currentAddress');
    if (userInfo != null && currentAddress != null &&
        userInfo!.addressData!.containsKey(currentAddress)) {
      final account = userInfo?.addressData?[currentAddress];
      LOG('--> wallet account : ${account?.toJson()}');
      return account;
    }
    LOG('--> wallet account empty !!');
    return null;
  }

  _createEmailUser() {
    return UserModel(
      ID: Uuid().v4(),
      status:     1,
      loginType:  LoginType.email,
      userName:   inputNick,
      email:      inputEmail,
      createTime: DateTime.now(),
    );
  }

  ////////////////////////////////////////////////////////////////////////

  loginKakao(BuildContext context) async {
    final user = await startKakaoLogin();
    if (user != null) {
      userInfo = UserModel.createFromKakao(user);
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
      userInfo = UserModel.createFromGoogle(user);
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

  Future<UserModel?> createNewUser() async {
    userInfo ??= _createEmailUser();
    UserHelper().setUserKey(inputEmail);
    final userPass = inputPass.first;
    final result = await createNewAccount(userPass);
    // create user info..
    LOG('----> createNewUser : $result <- '
      '$loginType / $userPass / ${userInfo?.toJson()}');
    if (result) {
      UserHelper().setUser(loginType: loginType.name);
    }
    return userInfo;
  }

  // add new wallet & account..
  Future<bool> createNewAccount(String passOrg) async {
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    LOG('--> createNewAccount : $passOrg');
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    var result = await eccImpl.generateKeyPair(pass, nickId: inputNick);
    if (result) {
      await _refreshAccountList();
    }
    return result;
  }

  // add new wallet & account..
  Future<bool> addNewAccount(String passOrg) async {
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    LOG('--> addNewAccount : $passOrg');
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    var result = await eccImpl.addKeyPair(pass, nickId: inputNick);
    if (result) {
      await _refreshAccountList();
    }
    return result;
  }

  // local에 있는 address 목록을 userInfo 에 추가 & 케싱 한다..
  _refreshAccountList() async {
    if (userInfo == null) return null;
    var accountListStr = await UserHelper().get_addressList();
    if (accountListStr != 'NOT_ADDRESSLIST') {
      userInfo!.addressData = {};
      List<dynamic> accountList = json.decode(accountListStr);
      for (var item in accountList) {
        var address = AddressModel.fromJson(item);
        userInfo!.addressData![address.address!] = address;
      }
    }
    LOG('--> _refreshAccountList : ${userInfo!.addressData}');
    return userInfo;
  }

  // passOrg : 실제로 입력 받은 패스워드 문자열..
  Future<bool> checkWalletPass(String passOrg, {String? email}) async {
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

  nickInput(String nickId) {
    if (nickId.length > 4) {
      inputNick = nickId;
      final orgStep = nickStep;
      nickStep = NickCheckStep.ready;
      if (orgStep != emailStep) {
        notifyListeners();
      }
    }
  }

  emailInput(String email) {
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

  signupEmail() {
  }

  loginEmail() {
  }

  ////////////////////////////////////////////////////////////////////////

  LoginType get loginType {
    if (userInfo != null) {
      return userInfo!.loginType!;
    }
    return LoginType.email;
  }

  toggleLogin() {
    isSignUpMode = !isSignUpMode;
    notifyListeners();
  }

  setSignUpMode(bool status) {
    isSignUpMode = status;
    notifyListeners();
  }

  logout() async {
    userInfo = null;
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
