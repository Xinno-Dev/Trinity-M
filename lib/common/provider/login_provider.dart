
import 'dart:async';
import 'dart:convert';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:elliptic/ecdh.dart';
import 'package:elliptic/elliptic.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart' as crypto;

import '../../data/repository/ecc_repository_impl.dart';
import '../../domain/model/address_model.dart';
import '../../domain/model/ecckeypair.dart';
import '../../domain/model/user_model.dart';
import '../../domain/usecase/ecc_usecase_impl.dart';
import '../../presentation/view/signup/login_pass_screen.dart';
import '../../services/api_service.dart';
import '../../services/social_service.dart';
import '../../../common/common_package.dart';
import '../const/constants.dart';
import '../const/utils/aesManager.dart';
import '../const/utils/convertHelper.dart';
import '../const/utils/eccManager.dart';
import '../const/utils/languageHelper.dart';
import '../const/utils/uihelper.dart';
import '../const/utils/userHelper.dart';
import '../const/utils/walletHelper.dart';

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
  passFail,
  passFailEx,
  loginKakaoFail,
  loginFail,
  recoverRequire,
  recoverFail,
  signupRequire,
  signupFail,

  none;

  String get errorText {
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
      case passFail:
        return '잘못된 계정이나 패스워드 입니다.';
      case passFailEx:
        return '잘못된 패스워드 입니다.';
      case loginKakaoFail:
        return '카카오 로그인에 실패했습니다.';
      case loginFail:
        return '로그인에 실패했습니다.';
      case recoverRequire:
        return '지갑 복구가 필요한 이메일입니다.';
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
  '내 정보', '구매 내역', '-',
  '이용약관', '개인정보처리 방침', '버전 정보', '로그아웃',
];

enum DrawerActionType {
  my,
  history,
  line,
  terms,
  privacy,
  version,
  logout;

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
  factory LoginProvider() {
    return _singleton;
  }
  LoginProvider._internal();
  static final _singleton = LoginProvider._internal();
  static final _api = ApiService();

  UserModel?    userInfo;
  AddressModel? selectAccount;
  int lockTime = 0;

  var isLoginCheckDone = false;
  var isSignUpMode = false;
  var isShowMask = false;

  var isScreenLocked = false;
  var isScreenLockReady = false;
  var isPassInputShow = false;

  var mainPageIndex = 0;
  var mainPageIndexOrg = 0;

  var sendMail    = '';

  var emailStep   = EmailSignUpStep.none;
  var nickStep    = NickCheckStep.none;
  var recoverStep = RecoverPassStep.none;

  var inputNick   = IS_DEV_MODE ? EX_TEST_ACCCOUNT_00 : '';
  var inputEmail  = IS_DEV_MODE ? EX_TEST_MAIL_00 : '';
  var inputPass   = List.generate(2, (index) => IS_DEV_MODE ? EX_TEST_PASS_00 : '');
  var cloudPass   = List.generate(2, (index) => IS_DEV_MODE ? EX_TEST_PASS_00 : '');

  String? localLoginType;
  String? socialName;
  String? socialId;
  String? emailVfCode;
  String  appVersion = '';
  String? userInputPass;

  get userPass {
    return STR(userInputPass);
  }

  setUserPass(String pass) {
    LOG('--> setUserPass : $pass');
    userInputPass = pass;
  }

  get userPassReady {
    return userPass.isNotEmpty;
  }

  get userEmail {
    return STR(userInfo?.email);
  }

  get userId {
    return accountName;
  }

  get userName {
    return accountSubtitle;
  }

  get userNickId {
    return STR(account?.accountName);
  }

  get userIdentityYN {
    return STR(userInfo?.certUpdt).isNotEmpty;
  }

  get userBioYN {
    return BOL(userInfo?.bioIdentityYN);
  }

  get checkPassLength {
    return userPass.length > 4;
  }

  refresh() {
    notifyListeners();
  }

  init() {
    selectAccount = null;
    userInfo      = null;
    socialName    = null;
    socialId      = null;
    emailStep     = IS_DEV_MODE ? EmailSignUpStep.ready : EmailSignUpStep.none;
    PackageInfo.fromPlatform().then((info) {
      appVersion = info.version;
      LOG('--> appVersion: $appVersion');
    });
  }

  setMaskStatus(bool status) {
    isShowMask = status;
    notifyListeners();
  }

  enableLockScreen() {
    isScreenLockReady = true;
  }

  disableLockScreen() {
    isScreenLockReady = false;
  }

  setLockScreen(BuildContext context, bool status) {
    LOG('--> setLockScreen : $status / $isScreenLocked / $isScreenLockReady / ${!isPassInputShow}');
    if (IS_AUTO_LOCK_MODE && isLogin && isScreenLockReady) {
      if (!status && isScreenLocked && !isPassInputShow) {
        isScreenLocked = status;
        var offset = DateTime.now().millisecondsSinceEpoch - lockTime;
        LOG('--> lockTime [unlock] : $offset <= $lockTime / ${DateTime.now().millisecondsSinceEpoch}');
        if (offset <= LOCK_SCREEN_DELAY * 1000) {
          lockTime = 0;
          notifyListeners();
          return;
        }
        isScreenLockReady = false;
        Future.delayed(Duration(milliseconds: 200)).then((_) {
          Navigator.of(context).push(createAniRoute(OpenLockPassScreen())).then((_) {
            lockTime = 0;
          });
        });
        return;
      }
      if (isScreenLocked != status) {
        lockTime = DateTime.now().millisecondsSinceEpoch;
        LOG('--> lockTime [lock] : $status <= $lockTime');
        isScreenLocked = status;
        // if (status) {
        //   _startLockTimer();
        // }
        notifyListeners();
      }
    }
  }

  setUserBioIdentity(bool status) async {
    if (isLogin) {
      userInfo!.bioIdentityYN = status;
      await UserHelper().setUser(bioIdentity: status ? 'true' : '');
      notifyListeners();
      return true;
    }
    return false;
  }

  showUserBioIdentityCheck(BuildContext context) async {
    return await getBioIdentity(context,
      TR(context, '본인확인'),
      onError: (err) {
        showLoginErrorTextDialog(context, err);
      }
    );
  }

  // local에 있는 address 목록을 userInfo 에 추가 & 케싱 한다..
  _refreshAccountList() async {
    if (userInfo == null) return null;
    var accountListStr = await UserHelper().get_addressList();
    if (accountListStr != 'NOT_ADDRESSLIST') {
      userInfo!.addressList = [];
      List<dynamic> accountList = json.decode(accountListStr);
      LOG('------------- _refreshAccountList --------------------');
      for (var item in accountList) {
        var address = AddressModel.fromJson(item);
        LOG('----> [${address.accountName}] : ${address.address}');
        userInfo!.addressList!.add(address);
      }
      LOG('------------------------------------------------------');
    }
    await _refreshSelectAccount();
    return userInfo;
  }

  _refreshSelectAccount([String? address]) async {
    selectAccount = null;
    if (userInfo?.addressList != null) {
      address ??= await UserHelper().get_address();
      LOG('--> _refreshSelectAccount : $address');
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
    return selectAccount;
  }

  Future<bool> checkLogin([var isSignUp = false]) async {
    if (IS_AUTO_LOGIN_MODE) {
      if (isLogin || isLoginCheckDone) return isLogin;
      var user = await UserHelper().get_loginInfo();
      LOG('----------------------------- $user');
      // auto login..
      if (STR(user).isNotEmpty) {
        loginAuto(user!).then((result) {
          if (isLogin) {
            showToast('${account?.accountName} 로그인 완료');
            notifyListeners();
          }
        });
      }
      isLoginCheckDone = true;
      return isLogin;
    }
    isLoginCheckDone = true;
    return false;
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

  AddressModel? get accountFirst {
    return userInfo?.addressList?.first;
  }

  get accountFirstAddress {
    return accountFirst?.address;
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
    // LOG('---> setMainPageIndex : $mainPageIndexOrg / $index');
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

  Future<bool?> loginAuto(String encUser) async {
    init();
    userInfo = await UserModel.createFromLocalEnc(encUser);
    if (userInfo != null && STR(userInfo?.email).isNotEmpty) {
      if (STR(userNickId).isEmpty) {
        await UserHelper().setUserKey(STR(userInfo?.email));
        await _refreshAccountList();
        userInfo = await updateUserInfo();
        if (userInfo != null) {
          userInfo!.bioIdentityYN = await UserHelper().get_bioIdentityYN();
          return true;
        }
      }
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
      var result = await startLoginWithKey(onError: (type, text) {
        if (!isAutoLogin && onError != null) {
          onError(type, text);
        }
      });
      if (result != true) {
        userInfo = null;
        return false;
      }
      return true;
    }
    return false;
  }

  Future<bool?> loginKakao(BuildContext context,
    {Function(LoginErrorType, String?)? onError, var isAutoLogin = false})
    async {
    init();
    final user = await startKakaoLogin();
    LOG('----> loginKakao user : $user');
    if (user != null) {
      userInfo = await UserModel.createFromKakao(user);
      LOG('----> loginKakao email : ${userEmail}');
      if (STR(userEmail).isNotEmpty) {
        // read local user info..
        await UserHelper().setUserKey(userEmail!);
        await _refreshAccountList();
        if (await checkUserHasLocalInfo(STR(userEmail))) {
          // check login pass..
          final pass = await Navigator.of(context).push(
              createAniRoute(LoginPassScreen()));
          if (STR(pass).isNotEmpty) {
            setUserPass(pass!);
            final result = await startLoginWithKey(onError: (type, text) {
              if (!isAutoLogin && onError != null) {
                onError(type, text);
              }
            });
            if (result != true) {
              // 로그인 실패시 카카오 로그아웃..
              await startKakaoLogout();
              return result;
            }
            return true;
          }
        } else {
          return null;
        }
      }
    }
    return false;
  }

  Future<bool?> initSignUpKakao(
    {Function(LoginErrorType, String?)? onError}) async {
    init();
    final user = await startKakaoLogin();
    LOG('----> initSignUpKakao user : $user');
    if (user != null) {
      userInfo = await UserModel.createFromKakao(user);
      if (STR(userInfo?.email).isNotEmpty) {
        var result = await _api.checkEmail(userInfo!.email!);
        LOG('----> checkEmail result : $result');
        if (!result) {
          if (onError != null) {
            LOG('----> checkEmail onError : ${userInfo!.email}');
            onError(LoginErrorType.mailDuplicate, userInfo!.email!);
          }
          init();
          return null;
        }
        return true;
      }
    } else if (onError != null) {
      onError(LoginErrorType.loginKakaoFail, null);
    }
    return false;
  }

  Future<bool?> loginGoogle(
    {Function(LoginErrorType, String?)? onError, var isAutoLogin = false})
    async {
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
        var result = await startLoginWithKey();
        if (result != true) {
          userInfo = null;
          await logout(false);
          if (!isAutoLogin && onError != null) {
            onError(LoginErrorType.signupRequire, '회원가입이 필요한 계정입니다.');
          }
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
        var nickId = Uri.encodeFull(inputNick);
        var msg = email + nickId + address + token;
        var sig = await createSign(msg);
        if (sig != null) {
          // create user from server..
          var result = await _api.createUser(
              userName ?? '',
              socialId ?? '',
              email,
              inputNick,
              '',
              '',
              address,
              sig,
              type,
              token,
              onError: onError
          );
          LOG('----> createNewUser result : $result');
          if (result == true) {
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
    }
    // 회원가입 실패시 소셜 로그아웃..
    await logout(false);
    return null;
  }

  Future<UserModel?> recoverUser(String newPass,
    {String? mnemonic, String? privateKey,
     Function(LoginErrorType, String?)? onError}) async {
    // set user key..
    userInfo ??= _createEmailUser();
    LOG('--> recoverUser : ${userEmail}');
    inputNick = ''; // nickId unknown..
    await UserHelper().setUserKey(userEmail!);
    var result  = await createNewAccount(
        newPass, mnemonic: mnemonic, privateKey: privateKey);
    LOG('--> recoverUser create : $result <= $mnemonic / $privateKey');
    // create user info..
    if (result) {
      var loginResult = await startLoginWithKey(onError: onError);
      if (loginResult == true) {
        // '복구' 일경우 첫번째 계정을 디폴트로 지정..
        selectAccount = accountFirst;
        userInfo!.bioIdentityYN = false; // bio 인증 초기화
        await UserHelper().setUser(
            address: accountFirstAddress,
            bioIdentity: '');
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
    if (onError != null) onError(LoginErrorType.passFail, null);
    return false;
  }

  Future<bool?> startLogin(EccKeyPair? key,
    {Function(LoginErrorType, String?)? onError}) async {
    LOG('========> startLogin : $userEmail / ${userInfo?.loginType} / $key');
    if (STR(userEmail).isNotEmpty) {
      var nickStr = STR(account?.accountName);
      var nickId  = Uri.encodeFull(nickStr);
      var type    = STR(userInfo?.loginType?.name);
      var email   = STR(userInfo?.email);
      var token   = STR(userInfo?.socialToken);
      LOG('--> startLogin info : $type / $email / $nickId / $userPass / $token');
      if (type == 'email') {
        if (key != null) {
          var pubKey = await getPublicKey(key.d);
          var shareKey = formatBytesAsHexString(pubKey.Q!.getEncoded());
          var secretKey = await _api.getSecretKey(
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
      // } else if (type == 'kakaotalk' && token.isEmpty) {
      //   final user = await startKakaoLogin();
      //   token = STR(user.properties?['token']);
      //   userInfo?.socialToken = token;
      }
      if (token.isNotEmpty) {
        var result = await _api.loginUser(
          nickStr, type, email, token, onError: (code, text) {
            if (text == '__not_found__') {

            }
            if (onError != null) onError(code, text);
          }
        );
        if (result) {
          // // get all account info when nickId empty..
          // if (STR(userNickId).isEmpty) {
            userInfo = await updateUserInfo();
          // }
          userInfo!.uid = await UserHelper().get_uid();
          userInfo!.bioIdentityYN = await UserHelper().get_bioIdentityYN();
          var userEnc = await userInfo?.encryptAes;
          await UserHelper().setUser(loginInfo: userEnc);
          LOG('-----------> loginUser success : [${userInfo!.uid}] '
              '${userInfo!.bioIdentityYN} / ${userInfo?.toJson()}');
        }
        return result;
      }
    }
    return null;
  }

  Future<UserModel?> getUserInfo() async {
    var result = await _api.getUserInfo();
    if (result != null) {
      UserModel user = UserModel.createFromInfo(result);
      LOG('---> user.certUpdt : ${user.certUpdt}');
      return user;
    }
    return null;
  }

  // add new wallet & account..
  Future<bool> createNewAccount(String passOrg, {String? mnemonic, String? privateKey}) async {
    LOG('--> createNewAccount : $passOrg');
    var result  = false;
    if (STR(privateKey).isNotEmpty) {
      result = await _importPrivateKey(privateKey!);
    } else {
      var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
      var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
      result = await eccImpl.generateKeyPair(
          pass, nickId: inputNick, mnemonic: mnemonic);
    }
    if (result) {
      await _refreshAccountList();
    }
    LOG('--> createNewAccount result : $result <= $inputNick / ${account?.toJson()}');
    return result;
  }

  // add new account..
  Future<bool> addNewAccount(String passOrg, String newNickId) async {
    LOG('--> addNewAccount : $passOrg / $newNickId');
    var pass    = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    var keyResult = await eccImpl.addKeyPair(pass, nickId: newNickId);
    if (keyResult) {
      await _refreshAccountList();
      var uid     = STR(await UserHelper().get_uid());
      var nickId  = Uri.encodeFull(newNickId);
      var message = uid + nickId + walletAddress;
      LOG('--> addNewAccount message : $uid + $nickId + $walletAddress');
      var sig = await createSign(message);
      if (sig != null) {
        var addResult = await _api.addAccount(nickId, walletAddress, sig);
        if (addResult) {
          var result = await startLoginWithKey();
          LOG('--> addNewAccount result : $result');
          if (result != true) {
            return false;
          }
          notifyListeners();
          return true;
        } else {
          // restore org address..
          await removeAccountFromAddr(walletAddress);
        }
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
    if (sig != null) {
      var addResult = await _api.addAccount(nickId, walletAddress, sig);
      if (addResult == true) {
        LOG('--> setUserNickId success !!');
        return true;
      }
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
    if (sig != null) {
      LOG('--> setUserInfo ready : $walletAddress / $sig / ${info.subTitle} / '
          '${info.description} / ${info.image}');
      var addResult = await _api.setUserInfo(walletAddress, sig,
        subTitle: info.subTitle,
        imageUrl: info.image,
        desc:     info.description,
      );
      if (addResult == true) {
        LOG('--> setUserInfo success !!');
        return true;
      }
    }
    return false;
  }

  removeAccountFromAddr(String address) async {
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    await eccImpl.removeKeyPair(address);
    await _refreshAccountList();
  }

  Future<bool> changeAccount(AddressModel select) async {
    // var orgJson = account!.toJson();
    selectAccount = select;
    await UserHelper().setUser(address: select.address);
    LOG('--> changeAccount : ${selectAccount?.toJson()}');
    var result = await startLoginWithKey();
    LOG('--> loginAuto result : $result');
    if (result != true) {
      return false;
    }
    notifyListeners();
    return true;
  }

  setAccountName(AddressModel account) async {
    if (isLogin) {
      if (await setUserNickId(STR(account.accountName))) {
        // nickId 가 변경될경우 jwt 값이 바뀌는 이유로 재로그인 필요..
        disableLockScreen();
        var result = await startLoginWithKey();
        LOG('--> loginAuto result : $result');
        enableLockScreen();
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
          LOG('--> setLocalAccountName : ${account.toJson()} / ${accountList.length}');
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
    try {
      passOrg ??= userPass;
      var keyData = tmpKeyStr ?? selectAccount?.keyPair;
      LOG('--> getAccountKey : [$passOrg] / $keyData');
      if (passOrg != null && STR(keyData).isNotEmpty) {
        var keyStr = await decryptData(passOrg, keyData!);
        LOG('--> getAccountKey : $keyStr');
        if (keyStr != 'fail') {
          var keyPair = EccKeyPair.fromJson(jsonDecode(keyStr));
          return keyPair;
        } else {
          setUserPass('');
        }
      }
    } catch (e) {
      LOG('--> getAccountKey error : $e');
    }
    return null;
  }

  Future<bool> checkUserHasLocalInfo(String email) async {
    return await UserHelper().checkWallet(email);
  }

  decryptData(String passOrg, String data) async {
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    var result = await AesManager().decrypt(pass, data);
    return result;
  }

  encryptData(String passOrg, String data) async {
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    var result = await AesManager().encrypt(pass, data);
    return result;
  }

  createSign(String msg) async {
    try {
      var privateKey = await getAccountKey();
      LOG('---> createSign : $privateKey');
      if (privateKey != null) {
        var signature = await EccManager().signingEx(privateKey.d, msg);
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

  get isNickCheckReady {
    return nickStep == NickCheckStep.ready;
  }

  get isNickCheckDone {
    return nickStep == NickCheckStep.complete;
  }

  nickInput(String nickId) {
    nickStep = NickCheckStep.none;
    if (nickId.length < NICK_LENGTH_MIN) {
      return '$NICK_LENGTH_MIN 자 이상 입력해 주세요.';
    }
    inputNick = nickId;
    nickStep = NickCheckStep.ready;
    return null;
  }

  emailInput(String email) {
    inputEmail = email;
    emailStep  = EmailValidator.validate(email) ?
      EmailSignUpStep.ready : EmailSignUpStep.none;
    LOG('---> emailInput [$inputEmail] : $emailStep');
    notifyListeners();
  }

  emailSend(Function(LoginErrorType) onError) async {
    var result = await _api.checkEmail(inputEmail);
    LOG('---> checkEmail result : $result');
    if (result) {
      var vfCode = await startEmailSend(inputEmail, onError);
      if (STR(vfCode).isNotEmpty) {
        var sendResult = await _api.sendEmailVfCode(inputEmail, vfCode!);
        if (sendResult) {
          emailStep = EmailSignUpStep.send;
          emailVfCode = vfCode;
          await UserHelper().setUser(vfCode: vfCode);
          notifyListeners();
          return true;
        } else {
          onError(LoginErrorType.mailSendServer);
        }
      }
    } else {
      onError(LoginErrorType.mailDuplicate);
    }
    return false;
  }

  Future<bool> inputEmailDupCheck() async {
    return await emailDupCheck(inputEmail);
  }

  Future<bool> emailDupCheck(String checkMail) async {
    return !await _api.checkEmail(checkMail);
  }

  Future<bool> emailVfCheck({Function(LoginErrorType)? onError}) async {
    emailVfCode ??= await UserHelper().get_vfCode();
    if (STR(emailVfCode).isNotEmpty) {
      var result = await _api.checkEmailVfComplete(emailVfCode!);
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

  Future<bool?> checkNickId(
    {Function(LoginErrorType)? onError, String? nickId}) async {
    if (nickId != null) {
      inputNick = nickId;
    }
    var result = await _api.checkNickname(inputNick);
    if (result == true) {
      nickStep = NickCheckStep.complete;
      notifyListeners();
    } else if (onError != null) {
      onError(LoginErrorType.nickDuplicate);
    }
    return result;
  }

  Future<bool> checkNickDup(String? nickId) async {
    if (STR(nickId).isEmpty) {
      return false;
    }
    inputNick = nickId!;
    var result = await _api.checkNickname(inputNick);
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

  logoutWithRemoveNickId() async {
    LOG('--> logoutWithRemoveNickId : ${userInfo?.addressList?.length}');
    if (userInfo?.addressList != null) {
      var addrListJson = [];
      for (AddressModel item in userInfo!.addressList!) {
        item.accountName = '';
        addrListJson.add(item.toJson());
      }
      await UserHelper().setUser(addressList: jsonEncode(addrListJson));
    }
    if (isLogin) {
      await logout();
    }
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

  Future<UserModel?> updateUserInfo() async {
    LOG('-------> _updateUserInfo()');
    var tmpUserInfo = await getUserInfo();
    if (tmpUserInfo?.addressList != null) {
      var accountCount = INT(userInfo?.addressList?.length);
      var pass = crypto.sha256.convert(utf8.encode(userPass)).toString();
      var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
      // crate empty keypair..
      for (var i = 0; i < tmpUserInfo!.addressList!.length; i++) {
        var item = tmpUserInfo.addressList![i];
        if (i >= accountCount) {
          LOG('--> addKeyPair [$i] : ${item.accountName}');
          await eccImpl.addKeyPair(pass, nickId: item.accountName);
        }
      }
      // refresh account..
      await _refreshAccountList();
      // update account list..
      var addrListJson = [];
      for (var item in tmpUserInfo.addressList!) {
        var newItem = _computeAccount(item);
        if (newItem != null) {
          addrListJson.add(newItem.toJson());
        }
      }
      LOG('--> addrListJson : $addrListJson');
      userInfo!.certUpdt = tmpUserInfo.certUpdt;
      await UserHelper().setUser(addressList: jsonEncode(addrListJson));
      // LOG('--> _setAccountListFromServer result : ${userInfo?.toJson()}');
      return userInfo;
    }
    return null;
  }

  AddressModel? _computeAccount(AddressModel newItem) {
    for (var item in userInfo!.addressList!) {
      if (item.address == newItem.address) {
        LOG('--> _computeAccount item [${newItem.address}] :'
          ' ${newItem.image} / ${item.toJson()}');
        return item.copyWithInfo(newItem);
      }
    }
    return null;
  }

  bool checkHasAccount(AddressModel newItem) {
    for (var item in userInfo!.addressList!) {
      if (item.address == newItem.address) {
        return true;
      }
    }
    return false;
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

  //////////////////////////////////////////////////////////////////////////////

  late PromptInfo _prompt;

  setPrompt(String title, String subtitle) {
    _prompt = PromptInfo(
      iosPromptInfo: IosPromptInfo(
        saveTitle: title,
        accessTitle: subtitle,
      ),
      androidPromptInfo: AndroidPromptInfo(
        title: title,
        description: subtitle,
      )
    );
  }

  Future<bool?> setBioIdentity(BuildContext context, String title,
      {Function(String)? onError}) async {
    // final auth = LocalAuthentication();
    try {
      setPrompt(title, TR(context, '본인 확인을 위해 생체인증을 사용합니다.'));
      var value = await AesManager().encryptWithDeviceId(userPass);
      var result = await writeBioStorage(BIO_USER_PASS_KEY, value);
      LOG('--> setBioIdentity localPass : $value');
      if (result == true) {
        setUserBioIdentity(true);
      }
      return result;
      // var iosStrings = IOSAuthMessages(
      //   // cancelButton: '취소',
      //   // goToSettingsButton: '설정',
      //   // goToSettingsDescription: '생체인증 설정을 해주세요.',
      //   // lockOut: 'Please reenable your Touch ID',
      //   // localizedFallbackTitle: '암호입력',
      // );
      // var androidStrings = AndroidAuthMessages(
      //   signInTitle: title,
      //   biometricHint: '지문',
      //   cancelButton: '취소',
      // );
      // result = await auth.authenticate(
      //   localizedReason: TR(context, '본인 확인을 위해 생체인증을 사용합니다.'),
      //   authMessages: <AuthMessages>[
      //     androidStrings,
      //     iosStrings,
      //   ],
      //   options: AuthenticationOptions(
      //     stickyAuth: true,
      //     biometricOnly: true,
      //     useErrorDialogs: false,
      //   ),
      // );
    } on PlatformException catch (e) {
      LOG('--> showBioIdentity error : $e');
      if (onError != null) onError(e.toString());
    }
    return false;
  }

  Future<bool?> getBioIdentity(BuildContext context, String title,
      {Function(String)? onError}) async {
    try {
      setPrompt(title, TR(context, '본인 확인을 위해 생체인증을 사용합니다.'));
      var localPass = await readBioStorage(BIO_USER_PASS_KEY);
      LOG('--> getBioIdentity localPass : $localPass');
      if (STR(localPass).isNotEmpty) {
        var passOrg = await AesManager().decryptWithDeviceId(localPass!);
        LOG('--> getBioIdentity result : $passOrg');
        if (await checkWalletPass(passOrg)) {
          setUserPass(passOrg);
          return true;
        }
      }
    } on PlatformException catch (e) {
      LOG('--> getBioIdentity error : $e');
      if (onError != null) onError(e.toString());
    }
    return false;
  }

  Future<String?> readBioStorage(String key) async {
    var encEmail = crypto.sha256.convert(utf8.encode(userEmail)).toString();
    var name = '${key}-${encEmail}';
    var storage = await BiometricStorage().getStorage(name, promptInfo: _prompt);
    var value = await storage.read();
    LOG('--> readBioStorage : $name -> $value');
    return value;
  }

  Future<bool?> writeBioStorage(String key, [String? value]) async {
    var encEmail = crypto.sha256.convert(utf8.encode(userEmail)).toString();
    var name = '${key}-${encEmail}';
    try {
      if (value != null) {
        final storage = await BiometricStorage().getStorage(
          name, promptInfo: _prompt);
        await storage.write(value);
        LOG('--> writeBioStorage : $name ($userEmail) -> $value');
      } else {
        return await BiometricStorage().delete(name, _prompt);
      }
    } catch (e) {
      LOG('--> writeBioStorage error : $e');
      return false;
    }
    return true;
  }
}
