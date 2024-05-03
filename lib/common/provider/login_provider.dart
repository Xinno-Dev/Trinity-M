
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:elliptic/ecdh.dart';
import 'package:elliptic/elliptic.dart';
import 'package:email_validator/email_validator.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis/jobs/v3.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/aesManager.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/provider/market_provider.dart';
import 'package:larba_00/domain/model/user_model.dart';
import 'package:larba_00/presentation/view/main_screen.dart';
import 'package:larba_00/presentation/view/signup/signup_nick_screen.dart';
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
import '../../domain/repository/product_repository.dart';
import '../../domain/usecase/ecc_usecase_impl.dart';
import '../../presentation/view/authpassword_screen.dart';
import '../../presentation/view/signup/login_pass_screen.dart';
import '../../services/google_service.dart';
import '../../services/larba_api_service.dart';
import '../const/constants.dart';
import '../const/utils/appVersionHelper.dart';
import '../const/utils/convertHelper.dart';
import '../const/utils/eccManager.dart';
import '../const/utils/languageHelper.dart';
import '../const/utils/walletHelper.dart';
import '../const/widget/dialog_utils.dart';
import '../const/widget/primary_button.dart';

enum LoginType {
  kakaotalk,
  naver,
  google,
  apple,
  email;

  get title {
    switch(this) {
      case LoginType.kakaotalk: return '카카오';
      case LoginType.naver:     return '네이버';
      case LoginType.google:    return '구글';
      case LoginType.apple:     return '애플';
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

enum LoginErrorType {
  text,
  network,
  mailDuplicate,
  mailSend,
  mailSendServer,
  mailNotVerified,
  nickDuplicate,
  loginKakaoFail,
  loginFail,
  signupFail,
  none;

  get errorText {
    switch (this) {
      case network:
        return '서버에 접속할 수 없습니다.';
      case mailDuplicate:
        return '이미 사용중인 이메일주소입니다.';
      case mailSend:
        return '메일전송에 실패했습니다.';
      case mailSendServer:
        return '메일확인에 실패했습니다.';
      case mailNotVerified:
        return '인증이 완료되지않았습니다.\n(받은 이메일을 확인해 주세요)';
      case nickDuplicate:
        return '이미 사용중인 닉네임입니다.';
      case loginKakaoFail:
        return '카카오 로그인에 실패했습니다.';
      case loginFail:
        return '로그인에 실패했습니다.';
      case signupFail:
        return '회원가입에 실패했습니다.';
      default:
        return '';
    }
  }
}

enum DrawerActionType {
  my,
  history,
  none,
  terms,
  privacy,
  version,
  logout,
}

final testEmail = 'jubal2000@hanmail.net';
final testPass  = 'testpass00';

final loginProvider = ChangeNotifierProvider<LoginProvider>((_) {
  return LoginProvider();
});

class LoginProvider extends ChangeNotifier {
  static final _singleton = LoginProvider._internal();
  static final _marketRepo = ProductRepository();
  static final apiService = LarbaApiService();

  factory LoginProvider() {
    return _singleton;
  }
  LoginProvider._internal();

  UserModel?    userInfo;
  AddressModel? selectAccount;

  var isLoginCheckDone = false;
  var isSignUpMode = false;
  var isShowMask = false;

  var mainPageIndex = 0;
  var mainPageIndexOrg = 0;

  var emailStep   = EmailSignUpStep.none;
  var nickStep    = NickCheckStep.none;
  var recoverStep = RecoverPassStep.none;

  var inputNick   = IS_DEV_MODE ? EX_TEST_ACCCOUNT_00 : '';
  var inputEmail  = IS_DEV_MODE ? EX_TEST_MAIL_00 : '';
  var inputPass   = List.generate(2, (index) => IS_DEV_MODE ? EX_TEST_PASS_00 : '');
  var recoverPass = List.generate(2, (index) => 'recoverpass00');

  String? localLoginType;
  String? userName;
  String? socialId;
  String? emailVfCode;

  get userPass {
    return inputPass.first;
  }

  refresh() {
    notifyListeners();
  }

  init() {
    selectAccount = null;
    userInfo = null;
    userName = null;
    socialId = null;
  }

  setMaskStatus(bool status) {
    isShowMask = status;
    notifyListeners();
  }

  // local에 있는 address 목록을 userInfo 에 추가 & 케싱 한다..
  _refreshAccountList() async {
    if (userInfo == null) return null;
    var accountListStr = await UserHelper().get_addressList();
    if (accountListStr != 'NOT_ADDRESSLIST') {
      userInfo!.addressList = [];
      List<dynamic> accountList = json.decode(accountListStr);
      for (var item in accountList) {
        var address = AddressModel.fromJson(item);
        LOG('--> _refreshAccountList address : ${address.accountName} / ${address.address}');
        userInfo!.addressList!.add(address);
      }
    }
    await _refreshSelectAccount();
    return userInfo;
  }

  _refreshSelectAccount([String? address]) async {
    selectAccount = null;
    if (userInfo?.addressList != null) {
      address ??= await UserHelper().get_address();
      if (address != 'NOT_ADDRESS') {
        for (var item in userInfo!.addressList!) {
          if (item.address == address) {
            selectAccount = item;
            LOG('--> _refreshSelectAccount : ${item.toJson()}');
            return selectAccount;
          }
        }
      }
      if (userInfo!.addressList!.isNotEmpty) {
        selectAccount = userInfo!.addressList!.first;
      }
    }
    LOG('--> _refreshSelectAccount 2 : ${selectAccount?.toJson()}');
    return selectAccount;
  }

  Future<bool> checkLogin([var isSignUp = false]) async {
    var jwt  = await UserHelper().get_jwt();
    var info = await UserHelper().get_loginInfo();
    // LOG('-----------> checkLogin');
    // kakao login..
    // if (startLoginType == LoginType.kakaotalk.name) {
    //   if (await checkKakaoLogin()) {
    //     // await loginKakao(true);
    //     // kakao.User? user = await getKakaoUserInfo();
    //     // userName = user?.kakaoAccount?.name;
    //     // socialId = user?.id.toString();
    //     // LOG('--> kakao login done ${userInfo?.socialToken}');
    //     // try {
    //     //   var token = await UserHelper().get_token();
    //     //   LOG('--> kakao local token $token');
    //     //   kakao.User? user;
    //     //   if (token != null) {
    //     //     user = await getKakaoUserInfo();
    //     //   } else {
    //     //     // 토큰이 없을 경우 다시 로그인..
    //     //     user = await startKakaoLogin();
    //     //   }
    //     //   if (user != null) {
    //     //     userName = user.kakaoAccount?.name;
    //     //     socialId = user.id.toString();
    //     //     // userInfo = UserModel.createFromKakao(user);
    //     //   }
    //     // } catch (error) {
    //     //   LOG('--> kakao 로그인 실패 $error');
    //     // }
    //   }
    // }
    // // google login..
    // if (startLoginType == LoginType.google.name) {
    //   if (await checkGoogleLogin()) {
    //     // await loginGoogle();
    //     // User? user = await getGoogleUserInfo();
    //     // if (user != null) {
    //     //   userName = user.displayName;
    //     //   socialId = user.uid;
    //     //   // userInfo = UserModel.createFromGoogle(user);
    //     // }
    //   }
    // }
    // // email login..
    // if (startLoginType == LoginType.email.name) {
    //   var infoStr = await UserHelper().get_loginInfo();
    //   LOG('------> infoStr : $infoStr');
    //   if (infoStr != null) {
    //     // await loginEmail();
    //     // final user = await getEmailUserInfo(testEmail);
    //     // if (user != null) {
    //     //   // userInfo = UserModel.createFromEmail(user.ID!, user.email!);
    //     // }
    //   }
    // }
    LOG('----------------------------- $info / $jwt');
    // auto login..
    if (STR(jwt).isNotEmpty && STR(info).isNotEmpty) {
      userInfo = await UserModel.createFromLocal(info!);
      LOG('---> auto login info : ${userInfo?.toJson()}');
      if (STR(userInfo?.email).isNotEmpty) {
        await UserHelper().setUserKey(userInfo!.email!);
        if (isLogin) {
          Fluttertoast.showToast(
              msg: "${account?.accountName} 로그인 완료");
        }
      }
    }

    isLoginCheckDone = true;
    notifyListeners();
    return isLogin;
  }

  get isLogin {
    return INT(userInfo?.status) == 1;
  }

  AddressModel? get account {
    selectAccount ??= userInfo?.addressList?.first;
    return selectAccount;
  }

  get accountName {
    if (account?.accountName != null) {
      return account?.accountName;
    }
    return '';
  }

  get accountSubtitle {
    if (account?.subTitle != null) {
      return account?.subTitle;
    }
    return '';
  }

  get accountMail {
    if (userInfo?.email != null) {
      return userInfo?.email;
    }
    return '';
  }

  get walletAddress {
    if (account?.address != null) {
      return account?.address;
    }
    return '';
  }

  setMainPageIndex(int index) {
    mainPageIndex = index;
    LOG('---> setMainPageIndex : $mainPageIndexOrg / $index');
    refresh();
  }

  _createEmailUser() {
    return UserModel(
      status:     1,
      loginType:  LoginType.email,
      userName:   inputNick,
      email:      inputEmail,
      createTime: DateTime.now(),
    );
  }

  ////////////////////////////////////////////////////////////////////////

  Future<bool?> loginEmail({Function(LoginErrorType, String?)? onError, var isAutoLogin = false}) async {
    init();
    UserHelper().setUserKey(inputEmail);
    var user = await UserHelper().get_loginInfo();
    LOG('----> loginEmail user : $user');
    if (user != null) {
      userInfo = await UserModel.createFromLocal(user);
      LOG('----> loginEmail userInfo : ${userInfo?.toJson()}');
      if (userInfo != null) {
        userInfo!.email       = inputEmail;
        userInfo!.loginType   = LoginType.email;
        userInfo!.socialToken = '';
        var result = await startLogin(onError: !isAutoLogin ? onError : null);
        if (result != true) {
          userInfo = null;
          if (!isAutoLogin && onError != null) {
            onError!(LoginErrorType.loginFail, null);
          }
          return false;
        }
        return true;
      }
    }
    return false;
  }

  Future<bool> loginKakao({Function(LoginErrorType, String?)? onError, var isAutoLogin = false}) async {
    init();
    final user = await startKakaoLogin();
    LOG('----> loginKakao user : $user');
    if (user != null) {
      userInfo = await UserModel.createFromKakao(user);
      LOG('----> loginKakao userInfo : ${userInfo?.toJson()}');
      await UserHelper().setUserKey(userInfo!.email!);
      var result = await startLogin(onError: onError);
      if (result != true) {
        // 로그인 실패시 카카오 로그아웃..
        await logout(false);
        if (!isAutoLogin && onError != null) {
          onError(LoginErrorType.loginFail, '회원가입이 필요한 계정입니다.');
        }
        return false;
      }
      return true;
    } else {
      if (!isAutoLogin && onError != null) {
        onError(LoginErrorType.loginKakaoFail, null);
      }
    }
    return false;
  }

  Future<bool> initSignUpKakao({Function(LoginErrorType, String?)? onError}) async {
    init();
    final user = await startKakaoLogin();
    LOG('----> initSignUpKakao user : $user');
    if (user != null) {
      userInfo = await UserModel.createFromKakao(user);
      LOG('----> signUpKakao userInfo : ${userInfo?.toJson()} / ${userInfo!.socialToken}');
      if (STR(userInfo?.email).isNotEmpty) {
        var result = await apiService.checkEmail(userInfo!.email!);
        if (!result && onError != null) {
          onError(LoginErrorType.mailDuplicate, userInfo!.email!);
          init();
          return false;
        }
        return true;
      }
    } else if (onError != null) {
      onError(LoginErrorType.loginKakaoFail, null);
    }
    return false;
  }

  Future<bool?> loginGoogle({Function(LoginErrorType, String?)? onError}) async {
    init();
    var result = await startGoogleLogin();
    if (result != null) {
      final user = result.runtimeType == User ? result : result?.user;
      userInfo = UserModel.createFromGoogle(user);
      if (userInfo != null) {
        userInfo!.loginType   = LoginType.google;
        userInfo!.socialToken = await UserHelper().get_token();
        var result = await startLogin(onError: onError);
        if (result != true) {
          userInfo = null;
          return false;
        }
        return true;
      }
    }
    return null;
  }

  loginNaver() async {
    return isLogin;
  }

  loginApple() async {
    return isLogin;
  }

  ////////////////////////////////////////////////////////////////////////

  Future<UserModel?> signUpUser({Function(LoginErrorType, String?)? onError}) async {
    LOG('----> createNewUser : ${userInfo?.toJson()}');
    userInfo ??= _createEmailUser();
    await UserHelper().setUserKey(userInfo!.email!);
    var userPass  = inputPass.first;
    var result    = await createNewAccount(userPass);
    var email     = STR(userInfo?.email);
    var type      = STR(userInfo?.loginType?.name);
    var address   = STR(account?.address);
    // create user info..
    if (result && email.isNotEmpty && address.isNotEmpty) {
      var token = userInfo!.socialToken ?? '';
      LOG('----> createNewUser token : $token');
      if (userInfo!.loginType == LoginType.email) {
        emailVfCode ??= await UserHelper().get_vfCode();
        LOG('----> createNewUser emailVfCode : $email => $emailVfCode');
        token = emailVfCode ?? '';
      }
      if (token.isNotEmpty) {
        // signing..
        var sig = await createSign(
            userPass, email + inputNick + address + token);
        LOG('----> createNewUser : $result <- '
            '$loginType / $userPass / $address / $sig');
        // create user from server..
        var error = await apiService.createUser(
            userName ?? '',
            socialId ?? '',
            email,
            inputNick, '', '',
            address,
            sig,
            type,
            token,
        );
        LOG('----> createNewUser result : $error');
        if (error == null) {
          var loginResult = await startLogin(onError: onError);
          if (loginResult == true) {
            return userInfo;
          }
        }
      } else {
        LOG('--> createNewUser token error');
      }
    } else {
      LOG('--> createNewUser info error');
    }
    // 회원가입 실패시 소셜 로그아웃..
    await logout(false);
    return null;
  }

  Future<UserModel?> recoverUser(String mnemonic, {Function(LoginErrorType, String?)? onError}) async {
    // set user key..
    userInfo ??= _createEmailUser();
    await UserHelper().setUserKey(userInfo!.email!);
    var userPass  = inputPass.first;
    var result    = await createNewAccount(userPass, mnemonic: mnemonic);
    var address   = STR(account?.address);
    // create user info..
    if (result && address.isNotEmpty) {
      var loginResult = await startLogin(onError: onError);
      if (loginResult == true) {
        return userInfo;
      }
    }
    userInfo = null;
    return userInfo;
  }

  Future<bool?> startLogin({Function(LoginErrorType, String?)? onError}) async {
    LOG('========> startLogin : ${userInfo?.email} / ${userInfo?.loginType}');
    if (STR(userInfo?.email).isNotEmpty) {
      await _refreshAccountList();
      var nickId  = account?.accountName ?? '';
      if (nickId.isEmpty) {
        return null;
      }
      var type    = STR(userInfo?.loginType?.name);
      var email   = STR(userInfo?.email);
      var token   = STR(userInfo?.socialToken);
      if (type == 'email') {
        var privKey  = await getPrivateKey(userPass);
        var pubKey   = await getPublicKey(privKey.d);
        var shareKey = formatBytesAsHexString(pubKey.Q!.getEncoded());
        LOG('--> startLogin keyPair [$userPass]: $shareKey');
        var secretKey = await LarbaApiService().getSecretKey(nickId, shareKey);
        if (secretKey != null) {
          var curve  = getS256();
          var pKey = PublicKey.fromHex(curve, secretKey);
          LOG('--> startLogin pubKey : $pKey');
          var signKey = computeSecretHex(PrivateKey.fromHex(curve, privKey.d), pKey);
          var message = email + nickId + signKey;
          LOG('--> startLogin signKey : $signKey / $message');
          var sign = await createSign(userPass, message);
          token = sign;
        } else {
          if (onError != null) onError(LoginErrorType.loginFail, null);
        }
      }
      LOG('--> startLogin token : $token');
      var result = await apiService.loginUser(nickId, type, email, token, onError: onError);
      if (result) {
        var userEnc = await userInfo?.encryptAes;
        await UserHelper().setUser(loginInfo: userEnc);
        LOG('-----------> loginUser success : ${userInfo?.toJson()}');
      }
      return result;
    }
    return null;
  }

  // add new wallet & account..
  Future<bool> createNewAccount(String passOrg, {String? mnemonic}) async {
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    var result = await eccImpl.generateKeyPair(
        pass, nickId: inputNick, mnemonic: mnemonic);
    LOG('--> createNewAccount : $inputNick / $passOrg => $result');
    if (result) {
      await _refreshAccountList();
    }
    return result;
  }

  // add new account..
  Future<bool> addNewAccount(String passOrg) async {
    var addressOrg = walletAddress;
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    var result = await eccImpl.addKeyPair(pass, nickId: inputNick);
    LOG('--> addNewAccount : $inputNick / $passOrg => $result / $walletAddress');
    if (result) {
      await _refreshAccountList();
      var uid = STR(await UserHelper().get_uid());
      var message = uid + inputNick + walletAddress;
      LOG('--> addNewAccount message : $uid + $inputNick + $walletAddress');
      var sig = await createSign(passOrg, message);
      var addResult = await apiService.addAccount(inputNick, walletAddress, sig);
      if (addResult) {
        LOG('--> addNewAccount success !!');
        notifyListeners();
        return true;
      } else {
        // restore org address..
        await changeAccountFromAddress(addressOrg);
      }
    }
    return false;
  }

  changeAccountFromAddress(String address) async {
    LOG('--> changeAccountFromAddress : $address');
    if (userInfo?.addressList != null) {
      for (var item in userInfo!.addressList!) {
        if (item.address == address) {
          return await changeAccount(item);
        }
      }
    }
    return null;
  }

  changeAccount(AddressModel select) async {
    LOG('--> changeAccount : ${select.toJson()}');
    selectAccount = select;
    await UserHelper().setUser(address: select.address ?? '');
    _refreshSelectAccount(select.address);
    return selectAccount;
  }

  // passOrg : 실제로 입력 받은 패스워드 문자열..
  Future<bool> checkWalletPass(String passOrg, {String? email}) async {
    try {
      String? userKey;
      if (STR(email).isNotEmpty) {
        userKey = crypto.sha256.convert(utf8.encode(email!)).toString();
      }
      var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
      var keyEnc = await UserHelper().get_key(userKeyTmp: userKey);
      LOG('--> checkWalletPass : $inputEmail / $passOrg / $pass -> $keyEnc');
      if (keyEnc != 'NOT_KEY') {
        var result = await AesManager().decrypt(pass, keyEnc);
        LOG('--> checkWallet decrypt done : $result');
        return result != 'fail';
      }
    } catch (e) {
      LOG('--> checkWallet error : $e');
    }
    return false;
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
      LOG('---> createSign : $privateKey / $signature <= $msg');
      return signature;
    } catch (e) {
      LOG('--> createSign error : ${e.toString()}');
    }
    return null;
  }

  // for test..
  createSignedMsg(String passOrg) async {
    emailVfCode ??= await UserHelper().get_vfCode();
    var address = await UserHelper().get_address();
    var vfCodeEnc = crypto.sha256.convert(utf8.encode(emailVfCode!));
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
    emailStep = EmailValidator.validate(email) ?
      EmailSignUpStep.ready : EmailSignUpStep.none;
    LOG('---> emailInput [$inputEmail] : $emailStep');
    notifyListeners();
  }

  emailSend(Function(LoginErrorType) onError) async {
    apiService.checkEmail(inputEmail).then((result) {
      LOG('---> checkEmail result : $result');
      if (result) {
        startEmailSend(inputEmail, onError).then((vfCode) {
          if (STR(vfCode).isNotEmpty) {
            apiService.sendEmailVfCode(inputEmail, vfCode!).then((result) async {
              if (result) {
                emailStep = EmailSignUpStep.check;
                emailVfCode = vfCode;
                await UserHelper().setUserKey(inputEmail);
                await UserHelper().setUser(vfCode: vfCode);
                notifyListeners();
              } else {
                onError(LoginErrorType.mailSendServer);
              }
            });
          }
        });
      } else {
        onError(LoginErrorType.mailDuplicate);
      }
    });
  }

  emailCheck({Function(LoginErrorType)? onError}) async {
    emailVfCode ??= await UserHelper().get_vfCode();
    if (STR(emailVfCode).isNotEmpty) {
      var result = await apiService.checkEmailVfComplete(emailVfCode!);
      if (result != null) {
        if (result) {
          emailStep = EmailSignUpStep.complete;
          notifyListeners();
        } else if (onError != null) {
          onError(LoginErrorType.mailDuplicate);
        }
        return result;
      }
    }
    return false;
  }

  Future<bool?> checkNickId({Function(LoginErrorType)? onError, String? nickId}) async {
    if (nickId != null) {
      inputNick = nickId;
    }
    var result = await apiService.checkNickname(inputNick);
    if (result == true) {
      nickStep = NickCheckStep.complete;
      notifyListeners();
    } else if (onError != null) {
      onError(LoginErrorType.nickDuplicate);
    }
    return result;
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

  logout([var isRefresh = true]) async {
    switch(loginType) {
      case LoginType.kakaotalk:
        await startKakaoLogout();
        break;
      case LoginType.google:
        await startGoogleLogout();
        break;
      default:
    }
    LOG('--> logout : $loginType');
    userInfo = null;
    await UserHelper().logoutUser();
    if (isRefresh) {
      notifyListeners();
    }
    return true;
  }
}
