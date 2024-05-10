
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
import '../../domain/repository/market_repository.dart';
import '../../domain/usecase/ecc_usecase_impl.dart';
import '../../presentation/view/authpassword_screen.dart';
import '../../presentation/view/signup/login_pass_screen.dart';
import '../../services/google_service.dart';
import '../../services/api_service.dart';
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
  code,
  text,
  network,
  mailDuplicate,
  mailSend,
  mailSendServer,
  mailNotVerified,
  nickDuplicate,
  loginKakaoFail,
  loginFail,
  recoverRequire,
  recoverFail,
  signupRequire,
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
      case recoverRequire:
        return '지갑 복구가 필요한 메일입니다.';
      case recoverFail:
        return '지갑 복구에 실패했습니다.';
      case signupRequire:
        return '회원가입이 필요한 메일입니다.';
      case signupFail:
        return '회원가입에 실패했습니다.';
      default:
        return '';
    }
  }
}

final drawerTitleN = [
  '내 정보','구매 내역','-','이용약관','개인정보처리방침', '버전 정보', '로그아웃',
  '본인인증(test)', '로컬정보 삭제(test)'];

enum DrawerActionType {
  my,
  history,
  line,
  terms,
  privacy,
  version,
  logout,

  test_identity,
  test_delete;

  String get title {
    return drawerTitleN[this.index];
  }
}

final testEmail = 'jubal2000@hanmail.net';
final testPass  = 'testpass00';

final loginProvider = ChangeNotifierProvider<LoginProvider>((_) {
  return LoginProvider();
});

class LoginProvider extends ChangeNotifier {
  static final _singleton = LoginProvider._internal();
  static final apiService = ApiService();

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

  String? localLoginType;
  String? socialName;
  String? socialId;
  String? emailVfCode;

  get userPass {
    return inputPass.first;
  }

  get userMail {
    return STR(userInfo?.email);
  }

  get userId {
    return accountName;
  }

  get userName {
    return accountSubtitle;
  }

  get userIdentityYN {
    return BOL(userInfo?.identityYN);
  }

  get userBioYN {
    return BOL(userInfo?.bioIdentityYN);
  }

  refresh() {
    notifyListeners();
  }

  init() {
    selectAccount = null;
    userInfo    = null;
    socialName  = null;
    socialId    = null;
  }

  setMaskStatus(bool status) {
    isShowMask = status;
    notifyListeners();
  }

  setBioIdentity(bool status) async {
    if (isLogin) {
      userInfo!.bioIdentityYN = status;
      await UserHelper().setUser(bioIdentity: status ? 'y' : '');
      notifyListeners();
      return true;
    }
    return false;
  }

  // local에 있는 address 목록을 userInfo 에 추가 & 케싱 한다..
  _refreshAccountList() async {
    if (userInfo == null) return null;
    var accountListStr = await UserHelper().get_addressList();
    if (accountListStr != 'NOT_ADDRESSLIST') {
      userInfo!.addressList = [];
      List<dynamic> accountList = json.decode(accountListStr);
      LOG('---------------------------------');
      for (var item in accountList) {
        var address = AddressModel.fromJson(item);
        LOG('----> ${address.accountName} / ${address.address}');
        userInfo!.addressList!.add(address);
      }
      LOG('---------------------------------');
    }
    await _refreshSelectAccount();
    return userInfo;
  }

  _refreshSelectAccount([String? address]) async {
    selectAccount = null;
    if (userInfo?.addressList != null) {
      address ??= await UserHelper().get_address();
      // LOG('--> _refreshSelectAccount : $address');
      if (address != 'NOT_ADDRESS') {
        for (var item in userInfo!.addressList!) {
          if (item.address == address) {
            selectAccount = item;
            LOG('--> _refreshSelectAccount item : ${item.toJson()}');
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
    if (isLogin || isLoginCheckDone) return true;
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
      loginAuto(info!).then((result) {
        if (isLogin) {
          Fluttertoast.showToast(
              msg: "${account?.accountName} 로그인 완료");
          notifyListeners();
        }
      });
      // userInfo = await UserModel.createFromLocal(info!);
      // LOG('---> auto login info : ${userInfo?.toJson()}');
      // if (STR(userInfo?.email).isNotEmpty) {
      //   await UserHelper().setUserKey(userInfo!.email!);
      // }
    }
    isLoginCheckDone = true;
    return isLogin;
  }

  get isLogin {
    return STR(userInfo?.uid).isNotEmpty;
  }

  AddressModel? get account {
    selectAccount ??= userInfo?.addressList?.first;
    return selectAccount;
  }

  get accountAddress {
    return account?.address;
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

  Future<bool?> loginAuto(String user) async {
    init();
    userInfo = await UserModel.createFromLocal(user);
    if (userInfo != null && STR(userInfo?.email).isNotEmpty) {
      if (userInfo?.loginType == LoginType.kakaotalk) {
        await loginKakao();
      }
      await UserHelper().setUserKey(userInfo!.email!);
      await _refreshAccountList();
      var result = await startLoginWithKey();
      LOG('--> loginAuto result : $result');
      if (result != true) {
        userInfo = null;
        return false;
      }
      return result;
    }
    return false;
  }

  Future<bool?> loginEmail(
      {Function(LoginErrorType, String?)? onError, var isAutoLogin = false})
  async {
    init();
    LOG('------> loginEmail : $inputEmail / $userPass');
    userInfo = UserModel.createFromEmail(inputEmail);
    if (STR(userInfo?.email).isNotEmpty) {
      await UserHelper().setUserKey(userInfo!.email!);
      await _refreshAccountList();
      var result = await startLoginWithKey(
          onError: !isAutoLogin ? onError : null);
      LOG('--> loginEmail result : $result');
      if (result != true) {
        userInfo = null;
        if (!isAutoLogin && onError != null) {
          onError(LoginErrorType.loginFail, null);
        }
        return result;
      }
      return true;
    }
    return false;
  }

  Future<bool?> loginKakao(
      {Function(LoginErrorType, String?)? onError, var isAutoLogin = false})
  async {
    init();
    final user = await startKakaoLogin();
    LOG('----> loginKakao user : $user');
    if (user != null) {
      userInfo = await UserModel.createFromKakao(user);
      LOG('----> loginKakao userInfo : ${userInfo?.toJson()}');
      if (STR(userInfo?.email).isNotEmpty) {
        await UserHelper().setUserKey(userInfo!.email!);
        await _refreshAccountList();
        var result = await startLoginWithKey(onError: onError);
        if (result != true) {
          // 로그인 실패시 카카오 로그아웃..
          await logout(false);
          if (!isAutoLogin && onError != null) {
            onError(LoginErrorType.loginFail, '회원가입이 필요한 계정입니다.');
          }
          return result;
        }
        return true;
      }
      return null;
    } else {
      if (!isAutoLogin && onError != null) {
        onError(LoginErrorType.loginKakaoFail, null);
      }
    }
    return false;
  }

  Future<bool> initSignUpKakao(
      {Function(LoginErrorType, String?)? onError}) async {
    init();
    final user = await startKakaoLogin();
    LOG('----> initSignUpKakao user : $user');
    if (user != null) {
      userInfo = await UserModel.createFromKakao(user);
      LOG('----> signUpKakao userInfo : ${userInfo?.toJson()} / '
          '${userInfo!.socialToken}');
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

  Future<bool?> loginGoogle(
    {Function(LoginErrorType, String?)? onError}) async {
    init();
    var result = await startGoogleLogin();
    if (result != null) {
      final user = result.runtimeType == User ? result : result?.user;
      userInfo = UserModel.createFromGoogle(user);
      if (STR(userInfo?.email).isNotEmpty) {
        await UserHelper().setUserKey(userInfo!.email!);
        await _refreshAccountList();
        userInfo!.loginType = LoginType.google;
        userInfo!.socialToken = await UserHelper().get_token();
        var result = await startLoginWithKey(onError: onError);
        if (result != true) {
          userInfo = null;
          return false;
        }
        return result;
      }
    }
    return false;
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
    var cResult   = await createNewAccount(userPass);
    var email     = STR(userInfo?.email);
    var type      = STR(userInfo?.loginType?.name);
    var address   = STR(account?.address);
    // create user info..
    if (cResult && email.isNotEmpty && address.isNotEmpty) {
      var token = userInfo!.socialToken ?? '';
      LOG('----> createNewUser token : $token');
      if (userInfo!.loginType == LoginType.email) {
        emailVfCode ??= await UserHelper().get_vfCode();
        LOG('----> createNewUser emailVfCode : $email => $emailVfCode');
        token = emailVfCode ?? '';
      }
      if (token.isNotEmpty) {
        // signing..
        var nickId  = Uri.encodeFull(inputNick);
        var msg     = email + nickId + address + token;
        var sig     = await createSign(msg);
        LOG('----> createNewUser : $msg');
        // create user from server..
        var result = await apiService.createUser(
          userName ?? '',
          socialId ?? '',
          email,
          nickId, '', '',
          address,
          sig,
          type,
          token,
          onError: onError
        );
        LOG('----> createNewUser result : $result');
        if (result != null) {
          var loginResult = await startLoginWithKey(onError: onError);
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

  Future<UserModel?> recoverUser(
    {String? mnemonic, String? privateKey,
     Function(LoginErrorType, String?)? onError}) async {
    // set user key..
    userInfo ??= _createEmailUser();
    inputNick = ''; // nickId unknown..
    await UserHelper().setUserKey(userInfo!.email!);
    var result  = await createNewAccount(
        userPass, mnemonic: mnemonic, privateKey: privateKey);
    LOG('--> recoverUser : $result <= $mnemonic / $privateKey');
    // create user info..
    if (result) {
      var loginResult = await startLoginWithKey(onError: onError);
      if (loginResult == true) {
        return userInfo;
      }
    }
    userInfo = null;
    return userInfo;
  }

  Future<bool?> startLoginWithKey({Function(LoginErrorType, String?)? onError}) async {
    var key = await getAccountKey();
    if (key != null) {
      return await startLogin(key, onError: onError);
    }
    return null;
  }

  Future<bool?> startLogin(EccKeyPair? key,
    {Function(LoginErrorType, String?)? onError}) async {
    LOG('========> startLogin : ${userInfo?.email} / ${userInfo?.loginType} / $key');
    if (STR(userInfo?.email).isNotEmpty) {
      var nickStr = STR(account?.accountName);
      var nickId  = Uri.encodeFull(nickStr);
      var type    = STR(userInfo?.loginType?.name);
      var email   = STR(userInfo?.email);
      var token   = STR(userInfo?.socialToken);
      LOG('--> startLogin info : $type / $email / $nickId / $userPass -> $token');
      if (type == 'email') {
        if (key != null) {
          var pubKey = await getPublicKey(key.d);
          var shareKey = formatBytesAsHexString(pubKey.Q!.getEncoded());
          var secretKey = await apiService.getSecretKey(
              nickStr, email, shareKey);
          if (secretKey != null) {
            var curve = getS256();
            var pKey = PublicKey.fromHex(curve, secretKey);
            var signKey = computeSecretHex(
                PrivateKey.fromHex(curve, key.d), pKey);
            var message = email + nickId + signKey;
            token = await createSign(message);
          } else {
            if (onError != null) onError(LoginErrorType.loginFail, null);
          }
        } else {
          if (onError != null) onError(LoginErrorType.loginFail, null);
        }
      }
      LOG('--> startLogin token : $token');
      if (token.isNotEmpty) {
        var result = await apiService.loginUser(
            nickStr, type, email, token, onError: onError);
        if (result) {
          userInfo      = await _setAccountListFromServer();
          userInfo!.uid = await UserHelper().get_uid();
          var userEnc   = await userInfo?.encryptAes;
          await UserHelper().setUser(loginInfo: userEnc);
          LOG('-----------> loginUser success : [${userInfo!.uid}] ${userInfo?.toJson()}');
        }
        return result;
      }
    }
    return null;
  }

  Future<UserModel?> getUserInfo() async {
    var result = await apiService.getUserInfo();
    if (result != null) {
      return UserModel.createFromInfo(result);
    }
    return null;
  }

  // add new wallet & account..
  Future<bool> createNewAccount(String passOrg, {String? mnemonic, String? privateKey}) async {
    var result  = false;
    if (STR(privateKey).isNotEmpty) {
      result = await _importPrivateKey(privateKey!);
    } else {
      var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
      var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
      result = await eccImpl.generateKeyPair(
          pass, nickId: inputNick, mnemonic: mnemonic);
      LOG('--> createNewAccount : $inputNick / $passOrg => $result');
    }
    if (result) {
      await _refreshAccountList();
    }
    return result;
  }

  // add new account..
  Future<bool> addNewAccount(String passOrg, String newNickId) async {
    var pass    = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    var result  = await eccImpl.addKeyPair(pass, nickId: newNickId);
    LOG('--> addNewAccount : $newNickId / $passOrg => $result / $walletAddress');
    if (result) {
      await _refreshAccountList();
      var uid     = STR(await UserHelper().get_uid());
      var nickId  = Uri.encodeFull(newNickId);
      var message = uid + nickId + walletAddress;
      LOG('--> addNewAccount message : $uid + $nickId + $walletAddress');
      var sig = await createSign(message);
      var addResult = await apiService.addAccount(nickId, walletAddress, sig);
      if (addResult) {
        LOG('--> addNewAccount success !!');
        notifyListeners();
        return true;
      } else {
        // restore org address..
        await removeAccountFromAddr(walletAddress);
      }
    }
    return false;
  }

  // change user nickId..
  Future<bool> setUserNickId(String newNickId) async {
    var uid     = STR(userInfo?.uid);
    var nickId  = Uri.encodeFull(STR(newNickId));
    var message = uid + nickId + walletAddress;
    LOG('--> setUserNickId : [$newNickId] / $message');
    var sig = await createSign(message);
    var addResult = await apiService.addAccount(nickId, walletAddress, sig);
    if (addResult == true) {
      LOG('--> setUserNickId success !!');
      return true;
    }
    return false;
  }

  // change user info..
  Future<bool> setUserInfo(AddressModel info) async {
    var uid     = STR(userInfo?.uid);
    var nickId  = Uri.encodeFull(accountName);
    var message = uid + nickId + walletAddress;
    LOG('--> setUserInfo : $message / ${info.toJson()}');
    var sig = await createSign(message);
    var addResult = await apiService.setUserInfo(walletAddress, sig,
        subTitle: info.subTitle,
        desc:     info.description,
        imageUrl: info.image,
    );
    if (addResult == true) {
      LOG('--> setUserInfo success !!');
      return true;
    }
    return false;
  }

  removeAccountFromAddr(String address) async {
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    await eccImpl.removeKeyPair(address);
    await _refreshAccountList();
  }

  Future<bool> changeAccount(AddressModel select) async {
    var key = await getAccountKey(tmpKeyStr: select.keyPair);
    LOG('--> changeAccount : ${select.address} / ${select.keyPair} => ${key?.toJson()}');
    if (key != null) {
      selectAccount = select;
      await _refreshSelectAccount(select.address);
      var userEnc = await userInfo?.encryptAes;
      await UserHelper().setUser(
        loginInfo: userEnc,
        address: select.address ?? '',
      );
      return true;
    }
    return false;
  }

  setAccountName(AddressModel account) async {
    if (isLogin) {
      if (await setUserNickId(STR(account.accountName))) {
        // nickId 가 변경될경우 jwt 값이 바뀌는 이유로 재로그인 필요..
        var result = await startLoginWithKey();
        LOG('--> loginAuto result : $result');
        if (result == true) {
          await setLocalAccountInfo(account);
          await _refreshAccountList();
          notifyListeners();
        }
        return result;
      }
    }
    return false;
  }

  setAccountInfo(AddressModel account) async {
    if (isLogin) {
      if (await setUserInfo(account)) {
        await setLocalAccountInfo(account);
        await _refreshAccountList();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  setLocalAccountInfo(AddressModel account) async {
    var addrListStr = await UserHelper().get_addressList();
    if (addrListStr != 'NOT_ADDRESSLIST') {
      List<dynamic> accountList = json.decode(addrListStr);
      List<AddressModel> addrList = [];
      // LOG('--> setLocalAccountName : ${account.toJson()} / ${accountList.length}');
      for (var item in accountList) {
        var itemModel = AddressModel.fromJson(item);
        if (account.address == itemModel.address) {
          itemModel = itemModel.copyWithInfo(account);
        }
        addrList.add(itemModel);
      }
      var addressListJson = addrList.map((e) => e.toJson()).toList();
      await UserHelper().setUser(addressList: json.encode(addressListJson));
    }
  }

  // passOrg : 실제로 입력 받은 패스워드 문자열..
  Future<bool> checkWalletPass(String passOrg) async {
    var keyEnc = await getAccountKey(passOrg: passOrg);
    LOG('--> checkWalletPass result : $keyEnc');
    return keyEnc != null;
  }

  Future<EccKeyPair?> getAccountKey({String? passOrg, String? tmpKeyStr}) async {
    // LOG('--> getAccountKey : ${selectAccount?.toJson()}');
    try {
      passOrg ??= userPass;
      var keyData = tmpKeyStr ?? selectAccount?.keyPair;
      LOG('--> getAccountKey [$passOrg] : $tmpKeyStr / ${selectAccount?.address}');
      if (passOrg != null && STR(keyData).isNotEmpty) {
        var keyStr = await decryptKey(passOrg, keyData!);
        // LOG('--> getAccountKey : $keyStr');
        if (keyStr != 'fail') {
          var keyPair = EccKeyPair.fromJson(jsonDecode(keyStr));
          return keyPair;
        }
      }
    } catch (e) {
      LOG('--> getAccountKey error : $e');
    }
    return null;
  }

  decryptKey(String passOrg, String keyData) async {
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    var keyStr = await AesManager().decrypt(pass, keyData);
    return keyStr;
  }

  createSign(String msg) async {
    try {
      var privateKey = await getAccountKey();
      if (privateKey != null) {
        var signature = await EccManager().signingEx(privateKey.d, msg);
        LOG('---> createSign : $privateKey / $signature <= $msg');
        return signature;
      }
    } catch (e) {
      LOG('--> createSign error : ${e.toString()}');
    }
    return null;
  }

  // for test..
  createSignedMsg() async {
    emailVfCode ??= await UserHelper().get_vfCode();
    var address = await UserHelper().get_address();
    var vfCodeEnc = crypto.sha256.convert(utf8.encode(emailVfCode!));
    var msg = '$inputEmail$inputNick$address$vfCodeEnc';
    final sign = await createSign(msg);
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

  Future<bool> emailDupCheck() async {
    return !await apiService.checkEmail(STR(userInfo?.email));
  }

  Future<bool> emailVfCheck({Function(LoginErrorType)? onError}) async {
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

  setSignUpMode([bool status = true]) {
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

  Future<UserModel?> _setAccountListFromServer() async {
    var tmpUserInfo = await getUserInfo();
    if (tmpUserInfo?.addressList != null) {
      var accountCount = INT(userInfo?.addressList?.length);
      var pass = crypto.sha256.convert(utf8.encode(userPass)).toString();
      var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
      LOG('--> _setAccountListFromServer accountCount : $accountCount');
      for (var i = 0; i < tmpUserInfo!.addressList!.length; i++) {
        var item = tmpUserInfo.addressList![i];
        if (i < accountCount) {
          // LOG('--> _setAccountListFromServer set nick [$i] : ${item.accountName}');
          await setLocalAccountInfo(item);
        } else {
          // LOG('--> _setAccountListFromServer addKeyPair [$i] : ${item.accountName}');
          await eccImpl.addKeyPair(pass, nickId: item.accountName);
        }
      }
      await _refreshAccountList();
      // LOG('--> _setAccountListFromServer result : ${userInfo?.toJson()}');
      return userInfo;
    }
    return null;
  }

  Future<bool> _importPrivateKey(String privateKeyHex,
    {String? pass, Function(LoginErrorType)? onError}) async {
    var isValid = await _validateKeyPair(privateKeyHex);
    LOG('--> _importPrivateKey : $isValid <= $privateKeyHex / $pass');
    if (isValid) {
      pass ??= userPass;
      if (STR(pass).isNotEmpty) {
        var encPass = crypto.sha256.convert(utf8.encode(pass!)).toString();
        var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
        LOG('--> _importPrivateKey addKeyPair : $pass');
        return await eccImpl.addKeyPair(
            encPass, nickId: '', privateKeyHex: privateKeyHex);
      } else {
        if (onError != null) onError(LoginErrorType.recoverFail);
      }
    }
    return false;
  }

  Future<bool> _validateKeyPair(String privateKey) async {
    EccManager eccManager = EccManager();
    var keyPair = await eccManager.loadKeyPair(privateKey);
    if (keyPair == null) {
      return false;
    }
    return await eccManager.isValidateKeyPair(keyPair);
  }
}
