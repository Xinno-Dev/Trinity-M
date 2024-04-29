
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
import '../const/utils/appVersionHelper.dart';
import '../const/utils/convertHelper.dart';
import '../const/utils/eccManager.dart';
import '../const/utils/languageHelper.dart';
import '../const/utils/walletHelper.dart';
import '../const/widget/dialog_utils.dart';
import '../const/widget/primary_button.dart';

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

enum LoginErrorType {
  text,
  network,
  mailDuplicate,
  mailSend,
  mailSendServer,
  mailNotVerified,
  nickDuplicate,
  kakaoFail,
  signupFail,
  loginFail,
  none;

  get errorText {
    switch (this) {
      case network:
        return '서버에 접속할 수 없습니다.';
      case mailDuplicate:
        return '중복된 이메일주소입니다.';
      case mailSend:
        return '메일전송에 실패했습니다.';
      case mailSendServer:
        return '메일확인에 실패했습니다.';
      case mailNotVerified:
        return '인증이 완료되지않았습니다.\n(받은 이메일을 확인해 주세요)';
      case nickDuplicate:
        return '중복된 닉네임입니다.';
      case kakaoFail:
        return '카카오 로그인에 실패했습니다.';
      default:
        return '';
    }
  }
}

final testEmail = 'jubal2000@hanmail.net';

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

  late BuildContext context;

  var isLoginCheckDone = false;
  var isSignUpMode = false;
  var isShowMask = false;
  var mainPageIndex = 0;
  var mainPageIndexOrg = 0;
  var profileSize = 120;

  var emailStep   = EmailSignUpStep.none;
  var nickStep    = NickCheckStep.none;
  var recoverStep = RecoverPassStep.none;

  var inputNick   = 'jubal2000';
  var inputEmail  = testEmail; // for test..
  var inputPass   = List.generate(2, (index) => 'testpass00');
  var recoverPass = List.generate(2, (index) => 'recoverpass00');

  String? localLoginType;
  String? userName;
  String? socialId;
  String? emailVfCode;

  AddressModel? get account {
    selectAccount ??= userInfo?.addressList?.first;
    return selectAccount;
  }

  get userPass {
    return inputPass.first;
  }

  refresh() {
    notifyListeners();
  }

  initLogin() {
    selectAccount = null;
    userInfo = null;
    userName = null;
    socialId = null;
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
        LOG('--> _refreshAccountList address : ${address.address}');
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
    var startLoginType = await UserHelper().get_loginType();
    LOG('-----------> checkLogin local : $startLoginType');
    // kakao login..
    if (startLoginType == LoginType.kakao.name) {
      if (await checkKakaoLogin()) {
        await loginKakao();
        // kakao.User? user = await getKakaoUserInfo();
        // userName = user?.kakaoAccount?.name;
        // socialId = user?.id.toString();
        // LOG('--> kakao login done ${userInfo?.socialToken}');
        // try {
        //   var token = await UserHelper().get_token();
        //   LOG('--> kakao local token $token');
        //   kakao.User? user;
        //   if (token != null) {
        //     user = await getKakaoUserInfo();
        //   } else {
        //     // 토큰이 없을 경우 다시 로그인..
        //     user = await startKakaoLogin();
        //   }
        //   if (user != null) {
        //     userName = user.kakaoAccount?.name;
        //     socialId = user.id.toString();
        //     // userInfo = UserModel.createFromKakao(user);
        //   }
        // } catch (error) {
        //   LOG('--> kakao 로그인 실패 $error');
        // }
      }
    }
    // google login..
    if (startLoginType == LoginType.google.name) {
      if (await checkGoogleLogin()) {
        await loginGoogle();
        // User? user = await getGoogleUserInfo();
        // if (user != null) {
        //   userName = user.displayName;
        //   socialId = user.uid;
        //   // userInfo = UserModel.createFromGoogle(user);
        // }
      }
    }
    // email login..
    if (startLoginType == LoginType.email.name) {
      var infoStr = await UserHelper().get_loginInfo();
      if (infoStr != null) {
        await loginEmail();
        // final user = await getEmailUserInfo(testEmail);
        // if (user != null) {
        //   // userInfo = UserModel.createFromEmail(user.ID!, user.email!);
        // }
      }
    }
    LOG('-----------------------------');
    if (!isLogin) {
      // clear login record..
      await UserHelper().setUser(
        loginInfo: '',
        token: ''
      );
    } else {
      await UserHelper().setUserKey(userInfo!.email!);
      Fluttertoast.showToast(
          msg: "${account?.accountName} 로그인 완료");
    }
    isLoginCheckDone = true;
    notifyListeners();
    return isLogin;
  }

  get isLogin {
    return userInfo != null;
  }

  get isCanLogin {
    return localLoginType != null;
  }

  get accountPic {
    if (account?.pic != null) {
      LOG('---> account?.pic : ${account?.pic}');
      if (account!.pic!.contains('https:')) {
        return CachedNetworkImage(imageUrl: account!.pic!, width: profileSize.r, height: profileSize.r);
      }
      return Image.asset(account!.pic!, width: profileSize.r, height: profileSize.r);
    }
    if (userInfo?.pic != null) {
      LOG('---> userInfo?.pic : ${userInfo?.pic}');
      if (userInfo!.pic!.contains('https:')) {
        return CachedNetworkImage(imageUrl: userInfo!.pic!, width: profileSize.r, height: profileSize.r);
      }
      return Image.asset(userInfo!.pic!, width: profileSize.r, height: profileSize.r);
    }
    if (userInfo?.picThumb != null) {
      LOG('---> userInfo?.picThumb : ${userInfo?.picThumb}');
      if (userInfo!.picThumb!.contains('https:')) {
        return CachedNetworkImage(imageUrl: userInfo!.picThumb!, width: profileSize.r, height: profileSize.r);
      }
      return userInfo!.picThumb;
    }
    return Icon(Icons.account_circle, size: profileSize.r.r, color: GRAY_30);
  }

  get accountName {
    if (account?.accountName != null) {
      return account?.accountName;
    }
    return '-';
  }

  get walletAddress {
    if (account?.address != null) {
      return account?.address;
    }
    return '-';
  }

  setMainPageIndex(index) {
    mainPageIndex = index;
    LOG('---> setMainPageIndex : $index');
    refresh();
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

  checkCanLogin() async {
    localLoginType = await UserHelper().get_loginType();
    return localLoginType != null;
  }

  Future<bool?> loginEmail() async {
    initLogin();
    await UserHelper().setUserKey(inputEmail);
    var user = await UserHelper().get_loginInfo();
    LOG('----> loginEmail user : $user');
    if (user != null) {
      userInfo = await UserModel.createFromEmail(user);
      LOG('----> loginEmail userInfo : ${userInfo?.toJson()}');
      if (userInfo != null) {
        userInfo!.email       = inputEmail;
        userInfo!.loginType   = LoginType.email;
        userInfo!.socialToken = '';
        var result = await startLogin(onError: _showResultDialog);
        if (result != true) {
          userInfo = null;
          return false;
        }
        return true;
      }
    } else {
      // TODO: get nickId from server..
    }
    return false;
  }

  Future<bool?> loginKakao() async {
    initLogin();
    final user = await startKakaoLogin();
    LOG('----> loginKakao user : $user');
    if (user != null) {
      userInfo = await UserModel.createFromKakao(user);
      LOG('----> loginKakao userInfo : ${userInfo?.toJson()}');
      if (userInfo != null) {
        userInfo!.loginType = LoginType.kakao;
        userInfo!.socialToken = await UserHelper().get_token();
        var result = await startLogin(onError: _showResultDialog);
        if (result != true) {
          userInfo = null;
          return false;
        }
        return true;
      }
    } else {
      _showResultDialog(LoginErrorType.kakaoFail, null);
    }
    return null;
  }

  Future<bool?> signUpKakao({Function(LoginErrorType, [String?])? onError}) async {
    initLogin();
    final user = await startKakaoLogin();
    LOG('----> loginKakao user : $user');
    if (user != null) {
      userInfo = await UserModel.createFromKakao(user);
      LOG('----> loginKakao userInfo : ${userInfo?.toJson()}');
      if (STR(userInfo?.email).isNotEmpty) {
        apiService.checkEmail(userInfo!.email!).then((result) {
          LOG('---> checkEmail result : $result');
          if (result == true) {
            // TODO: sign up user..
            return true;
          } else {
            if (onError != null) onError(LoginErrorType.mailDuplicate);
          }
        });
      }
    } else {
      if (onError != null) onError(LoginErrorType.kakaoFail);
    }
    return null;
  }

  Future<bool?> loginGoogle() async {
    initLogin();
    var result = await startGoogleLogin();
    if (result != null) {
      final user = result.runtimeType == User ? result : result?.user;
      userInfo = UserModel.createFromGoogle(user);
      if (userInfo != null) {
        userInfo!.loginType   = LoginType.google;
        userInfo!.socialToken = await UserHelper().get_token();
        var result = await startLogin(onError: _showResultDialog);
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

  Future<UserModel?> createNewUser() async {
    // set user key..
    userInfo ??= _createEmailUser();
    await UserHelper().setUserKey(userInfo!.email!);
    var userPass  = inputPass.first;
    var result    = await createNewAccount(userPass);
    var address   = account?.address ?? '';
    var type      = userInfo?.loginType?.name ?? '';
    // create user info..
    if (result && address.isNotEmpty) {
      var token = userInfo!.socialToken ?? '';
      LOG('----> createNewUser token : $token');
      if (userInfo!.loginType == LoginType.email) {
        emailVfCode ??= await UserHelper().get_vfCode();
        LOG('----> createNewUser emailVfCode : $emailVfCode');
        token = emailVfCode ?? '';
      }
      if (token.isNotEmpty) {
        // signing..
        var sig = await createSign(
            userPass, inputEmail + inputNick + address + token);
        LOG('----> createNewUser : $result <- '
            '$loginType / $userPass / $address / $sig');
        // create user from server..
        var error = await apiService.createUser(
            userName ?? '',
            socialId ?? '',
            inputEmail,
            inputNick,
            '',
            '',
            address,
            type,
            sig
        );
        LOG('----> createNewUser result : $error');
        if (error == null) {
          var userEnc = await userInfo?.encryptAes;
          await UserHelper().setUser(loginInfo: userEnc);
          LOG('---> loginUser success : ${userInfo!.email} / $userEnc');
          var loginResult = await startLogin(onError: _showResultDialog);
          if (loginResult == true) {
            return userInfo;
          }
        }
      }
    }
    userInfo = null;
    return null;
  }

  Future<UserModel?> recoverUser(String mnemonic) async {
    userInfo ??= _createEmailUser();
    var userPass  = inputPass.first;
    var result    = await createNewAccount(userPass, mnemonic: mnemonic);
    var address   = account?.address ?? '';
    // create user info..
    if (result && address.isNotEmpty) {
      emailVfCode ??= await UserHelper().get_vfCode();
      LOG('----> recoverUser emailVfCode : $emailVfCode / $mnemonic');
      if (STR(emailVfCode).isNotEmpty) {
        // signing..
        var sig = await createSign(
            userPass, inputEmail + inputNick + address + emailVfCode!);
        LOG('----> createNewUser : $result <- '
            '$loginType / $userPass / $address / $sig');
        // TODO: get nickId list from server..
        // var error = await apiService.createUser(
        //     userName ?? '',
        //     socialId ?? '',
        //     inputEmail,
        //     inputNick, '', '',
        //     address,
        //     sig
        // );
        // LOG('----> createNewUser result : $error');
        // if (error != null) {
        //   // var loginResult = await loginUser();
        //   // if (loginResult != true) {
        //   //   userInfo = null;
        //   // }
        //   userInfo = null;
        // }
      }
    }
    return userInfo;
  }

  Future<bool?> startLogin({Function(LoginErrorType, String?)? onError}) async {
    LOG('------> loginUser : ${userInfo?.email} / ${userInfo?.loginType}');
    if (STR(userInfo?.email).isNotEmpty) {
      // TODO: need nickId from server..
      _refreshAccountList();
      var nickId  = account?.accountName ?? '';
      var type    = userInfo?.loginType?.name ?? '';
      var email   = userInfo?.email ?? '';
      var token   = userInfo?.socialToken ?? '';
      if (type == 'email') {
        var privKey  = await getPrivateKey(userPass);
        var pubKey   = await getPublicKey(privKey.d);
        var shareKey = formatBytesAsHexString(pubKey.Q!.getEncoded());
        LOG('----> keyPair [$userPass]: $shareKey');
        var secretKey = await LarbaApiService().getSecretKey(nickId, shareKey);
        if (secretKey != null) {
          var curve  = getS256();
          var pKey = PublicKey.fromHex(curve, secretKey);
          LOG('---> pubKey : $pKey');
          var signKey = computeSecretHex(PrivateKey.fromHex(curve, privKey.d), pKey);
          var message = email + nickId + signKey;
          LOG('---> signKey : $signKey / $message');
          var sign = await createSign(userPass, message);
          token = sign;
        } else {
          if (onError != null) onError(LoginErrorType.loginFail, 'key error');
        }
      }
      LOG('---> token : $token');
      return await apiService.loginUser(nickId, type, email, token, onError: onError);
    }
    return null;
  }

  // add new wallet & account..
  Future<bool> createNewAccount(String passOrg, {String? mnemonic}) async {
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    var result = await eccImpl.generateKeyPair(
        pass, nickId: inputNick, mnemonic: mnemonic);
    LOG('--> createNewAccount : $passOrg => $result');
    if (result) {
      await _refreshAccountList();
    }
    return result;
  }

  // add new account..
  Future<bool> addNewAccount(String passOrg) async {
    var pass = crypto.sha256.convert(utf8.encode(passOrg)).toString();
    var eccImpl = EccUseCaseImpl(EccRepositoryImpl());
    var result = await eccImpl.addKeyPair(pass, nickId: inputNick);
    LOG('--> addNewAccount : $inputNick / $passOrg => $result');
    if (result) {
      await _refreshAccountList();
      notifyListeners();
    }
    return result;
  }

  changeAccount(AddressModel select) async {
    selectAccount = select;
    hideProfileSelectBox();
    await UserHelper().setUser(address: select.address ?? '');
    _refreshSelectAccount(select.address);
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

  startWallet(BuildContext context) {
    mainPageIndexOrg = 0;
    context.pushReplacementNamed(
        MainScreen.routeName, queryParams: {'selectedPage': '1'});
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

  showProfile() {
    if (userInfo != null) {
      return Column(
        children: [
          _profileTopBar(),
          _profileDescription(padding: EdgeInsets.symmetric(vertical: 25)),
          _profileButtonBox(),
        ],
      );
    } else {
      return Center(
        child: Text('No profile info..'),
      );
    }
  }

  hideProfileSelectBox([BuildContext? context]) {
    isShowMask = false;
    ScaffoldMessenger.of(context ?? this.context).hideCurrentMaterialBanner();
    notifyListeners();
  }

  showProfileSelectBox(BuildContext context, {Function(AddressModel)? onSelect, Function()? onAdd}) {
    isShowMask = true;
    this.context = context;
    LOG('---> userInfo : $userInfo');
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        elevation: 10,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        content: Container(
          constraints: BoxConstraints(
            maxHeight: 500,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: [
              ...userInfo!.addressList!.map((e) => _profileItem(e, () {
                if (onSelect != null) onSelect(e);
              })).toList(),
              SizedBox(height: 10),
              Ink(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GRAY_50, width: 1),
                    color: Colors.white
                ),
                child: InkWell(
                  onTap: () {
                    LOG('---> account add');
                    if (onAdd != null) onAdd();
                  },
                  borderRadius: BorderRadius.circular(10),
                  // splashColor: PRIMARY_100,
                  child: Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GRAY_20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 30, weight: 1, color: GRAY_30),
                        SizedBox(width: 10),
                        Text(TR(context, '계정 추가'), style: typo14bold),
                      ],
                    ),
                  ),
                ),
              ),
            ]
          ),
        ),
        actions: [
          Container()
          // SnackBarAction(
          //   label: 'Close',
          //   onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
          // ),
        ]
      ),
    );
    notifyListeners();
  }

  Widget _profileItem(AddressModel item, Function() onSelect) {
    final iconSize = 40.0.r;
    final color = item.address == selectAccount?.address ? PRIMARY_100 : GRAY_50;
    return InkWell(
      onTap: onSelect,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(iconSize),
                child: item.pic != null ? Image.asset(item.pic!) :
                Icon(Icons.account_circle, size: iconSize, color: GRAY_40),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(STR(item.accountName),
                      style: typo16semibold.copyWith(color: color)),
                  Text(ADDR(item.address),
                      style: typo11normal.copyWith(color: GRAY_40))
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  _profileTopBar({EdgeInsets? padding}) {
    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(profileSize.r),
              border: Border.all(width: 2, color: GRAY_20)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(profileSize.r),
              child: accountPic,
            ),
          ),
          // SizedBox(width: 20),
          // Expanded(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       _profileFollowBox(TR(context, '팔로워'), STR(account?.follower ?? '0')),
          //       _profileFollowBox(TR(context, '팔로잉'), STR(account?.following ?? '0')),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  _profileFollowBox(String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(title, style: typo14normal),
        Text(value, style: typo14bold),
      ],
    );
  }

  _profileDescription({EdgeInsets? padding}) {
    return Container(
      padding: padding,
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      child: Text(STR(account?.description ??
        '이국적 풍치의 이탈리아 투스카니 스타일 클럽하우스와 '
        '대저택 컨셉의 최고급 호텔 시설로 휴양과 메이저급 골프코스의 다이나믹을 함께 즐길 수'
        ' 있는 태안반도에 위치한 휴양형 고급 골프 리조트입니다.'),
        style: typo14medium, textAlign: TextAlign.center),
    );
  }


  _profileButtonBox() {
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            color: GRAY_20,
            textStyle: typo14semibold,
            isSmallButton: true,
            onTap: () {

            },
            text: TR(context, '프로필 편집'),
          )
        ),
        SizedBox(width: 10),
        Expanded(
          child: PrimaryButton(
            color: GRAY_20,
            textStyle: typo14semibold,
            isSmallButton: true,
            onTap: () {

            },
            text: TR(context, '보유 상품'),
          )
        ),
      ],
    );
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
      if (result == true) {
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
      } else if (result == false) {
        onError(LoginErrorType.mailDuplicate);
      } else {
        onError(LoginErrorType.network);
      }
    });
  }

  emailCheck(Function(LoginErrorType) onError) async {
    emailVfCode ??= await UserHelper().get_vfCode();
    if (STR(emailVfCode).isNotEmpty) {
      var result = await apiService.checkEmailVfComplete(emailVfCode!);
      if (result != null) {
        if (result) {
          emailStep = EmailSignUpStep.complete;
          notifyListeners();
        }
        return result;
      }
      onError(LoginErrorType.network);
    }
    return false;
  }

  checkNickId(Function(LoginErrorType) onError) async {
    var result = await apiService.checkNickname(inputNick);
    if (result != null) {
      if (result) {
        nickStep = NickCheckStep.complete;
        notifyListeners();
      }
      return result;
    }
    onError(LoginErrorType.network);
    return null;
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
    await UserHelper().setLoginType('');
    notifyListeners();
  }

  _showResultDialog(LoginErrorType type, String? text) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
        AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          content: Container(
            constraints: BoxConstraints(
              minWidth: 400.w,
            ),
            alignment: Alignment.center,
            height: 300.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SvgPicture.asset(
                    'assets/svg/icon_warning.svg',
                    width: 30.r, height: 30.r),
                SizedBox(height: 10.h),
                Text(type.errorText,
                    style: typo16dialog,
                    textAlign: TextAlign.center),
                if (text != null)...[
                  SizedBox(height: 10.h),
                  Text(text,
                    style: typo14normal,
                    textAlign: TextAlign.center),
                ]
              ],
            ),
          ),
          contentPadding: EdgeInsets.only(top: 20.h),
          actionsPadding: EdgeInsets.fromLTRB(30.w, 10.h, 20.w, 30.h),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            Container(
              width: 127.w,
              height: 40.h,
              child: OutlinedButton(
                onPressed: context.pop,
                child: Text(
                  TR(context, '닫기'),
                  style: typo12semibold100,
                ),
                style: darkBorderButtonStyle,
              )
            )
          ],
        ),
    );
  }
}
