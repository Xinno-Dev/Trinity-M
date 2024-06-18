import 'dart:convert';

import '../../../common/const/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../common/const/utils/md5Helper.dart';
import '../../../common/rlp/hash.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'aesManager.dart';
import 'convertHelper.dart';

class UserHelper {
  static final UserHelper _singleton = UserHelper._internal();
  factory UserHelper() {
    return _singleton;
  }
  UserHelper._internal();
  final storage = FlutterSecureStorage();

  var userKeyMail = ''; // for Dev..
  var userKey = '';
  var privateKey = '';
  var publicKey = '';
  var rwf = '';
  
  setUserKey(String email) {
    userKeyMail = email;
    userKey = crypto.sha256.convert(utf8.encode(email)).toString();
    LOG('---------> setUserKey : $email => $userKey');
    return userKey;
  }

  setJwt(String jwt) async {
    var pass   = await AesManager().deviceIdPass;
    var jwtEnc = await AesManager().encrypt(pass, jwt);
    return await setUser(jwt: jwtEnc);
  }

  ////////////////////////////////////////////////////////////////////////////
  //
  // public user info..
  //

  checkWallet(String email) async {
    var userKeyTmp = crypto.sha256.convert(utf8.encode(email)).toString();
    var result = await get_mnemonic(userKeyTmp: userKeyTmp);
    LOG('--> checkWallet : $userKeyTmp($email) => $result');
    return result != 'NOT_MNEMONIC';
  }

  logoutUser() async {
    LOG('--> logoutUser');
    await setUserKey('');
    await setUser(
      loginInfo: '',
      token: '',
      jwt: '',
      uid: '',
    );
    userKey = '';
    return true;
  }

  removeUser() async {
    LOG('--> removeUser : $userKey');
    await setUser(
      rwf: '',
      address: '',
      addressList: '',
      mnemonic: '',
    );
    await logoutUser();
  }

  Future<void> setUser({
    String? rwf,
    String? jwt,
    String? token,
    String? loginInfo,
    String? loginKey,
    String? vfCode,
    String? address,
    String? uid,
    String? bioIdentity,
    String? mnemonic,

    String userID = '',
    String publickey = '',
    String fcmToken = '',
    String key = '',
    String coinList = '',
    String selectedCoin = '',
    String selectedMainNetId = '',
    String loginDate = '',
    String localAuth = '',
    String trash = '',
    String registDate = '',
    String rootKey = '',
    String checkMnemonic = '',
    String networkList = '',
    String addressList = '',
  }) async {

    ////////////////////////////////////////////////////////////////////////////
    //
    // public user info..
    //

    if (token != null) {
      if (token.isNotEmpty) {
        await storage.write(key: TOKEN_KEY, value: token);
      } else {
        await storage.delete(key: TOKEN_KEY);
      }
    };

    if (jwt != null) {
      if (jwt.isNotEmpty) {
        await storage.write(key: JWT_KEY, value: jwt);
      } else {
        await storage.delete(key: JWT_KEY);
      }
    }

    if (uid != null) {
      if (uid.isNotEmpty) {
        await storage.write(key: UID_KEY, value: uid);
      } else {
        await storage.delete(key: UID_KEY);
      }
    }

    if (loginInfo != null) {
      if (loginInfo.isNotEmpty) {
        await storage.write(key: LOGIN_INFO_KEY, value: loginInfo);
      } else {
        await storage.delete(key: LOGIN_INFO_KEY);
      }
    }

    if (loginKey != null) {
      if (loginKey.isNotEmpty) {
        await storage.write(key: LOGIN_KEY, value: loginKey);
      } else {
        await storage.delete(key: LOGIN_KEY);
      }
    }

    if (bioIdentity != null) {
      if (bioIdentity.isNotEmpty) {
        await storage.write(key: BIO_IDENTITY_KEY, value: bioIdentity);
      } else {
        await storage.delete(key: BIO_IDENTITY_KEY);
      }
    }

    ////////////////////////////////////////////////////////////////////////////
    //
    // private user info..
    //

    if (rwf != null) {
      if (rwf.isNotEmpty) {
        await storage.write(key: RWF_KEY + userKey, value: rwf);
      } else {
        await storage.delete(key: RWF_KEY + userKey);
      }
    }

    if (vfCode != null) {
      if (vfCode.isNotEmpty) {
        await storage.write(key: VFCODE_KEY + userKey, value: vfCode);
      } else {
        await storage.delete(key: VFCODE_KEY + userKey);
      }
    };

    if (address != null) {
      if (address.isNotEmpty) {
        await storage.write(key: ADDRESS_KEY + userKey, value: address);
      } else {
        await storage.delete(key: ADDRESS_KEY + userKey);
      }
    };

    if (mnemonic != null) {
      if (mnemonic.isNotEmpty) {
        await storage.write(key: MNEMONIC_KEY + userKey, value: mnemonic);
      } else {
        await storage.delete(key: MNEMONIC_KEY + userKey);
      }
    };


    ////////////////////////////////////////////////////////////////////////////
    //
    // deprecated for new wallet....
    //

    if (userID != '') await storage.write(key: USERID_KEY + userKey, value: userID);

    if (publickey != '') await storage.write(key: PUB_KEY + userKey, value: publickey);

    if (fcmToken != '') await storage.write(key: FCM_KEY + userKey, value: fcmToken);

    if (key != '') await storage.write(key: KEYPAIR_KEY + userKey, value: key);

    if (coinList != '') await storage.write(key: COIN_LIST_KEY + userKey, value: coinList);

    if (selectedCoin != '') await storage.write(key: SELECTED_COIN_KEY + userKey, value: selectedCoin);

    if (selectedMainNetId != '') await storage.write(key: SELECTED_MAINNET_KEY + userKey, value: selectedMainNetId);

    if (localAuth != '')
      await storage.write(key: USELOCALAUTH_KEY + userKey, value: localAuth);

    if (trash != '') await storage.write(key: TRASH_KEY + userKey, value: trash);

    if (registDate != '')
      await storage.write(key: REGISTDATE_KEY + userKey, value: registDate);

    if (loginDate != '')
      await storage.write(key: LOGINDATE_KEY + userKey, value: loginDate);

    if (rootKey != '') await storage.write(key: ROOT_KEY + userKey, value: rootKey);

    if (checkMnemonic != '')
      await storage.write(key: CHECK_MNEMONIC_KEY + userKey, value: checkMnemonic);

    if (addressList != '') {
      await storage.write(key: ADDRESSLIST_KEY + userKey, value: addressList);
    }

    if (networkList != '')
      await storage.write(key: NETWORKLIST_KEY + userKey, value: networkList);
  }

  ////////////////////////////////////////////////////////////////////////////
  //
  // public user info..
  //

  Future<String?> get_loginInfo() async {
    return await storage.read(key: LOGIN_INFO_KEY);
  }

  Future<String?> get_loginKey() async {
    return await storage.read(key: LOGIN_KEY);
  }

  Future<String?> get_token() async {
    return await storage.read(key: TOKEN_KEY);
  }

  Future<String?> get_jwt() async {
    return await storage.read(key: JWT_KEY);
  }

  Future<String?> get_uid() async {
    return await storage.read(key: UID_KEY);
  }

  Future<String?> get_identity() async {
    return await storage.read(key: IDENTITY_KEY);
  }

  Future<String?> get_bioIdentity() async {
    return await storage.read(key: BIO_IDENTITY_KEY);
  }

  Future<bool> get_bioIdentityYN() async {
    return BOL(await get_bioIdentity());
  }

  ////////////////////////////////////////////////////////////////////////////
  //
  // private user info..
  //

  Future<String?> get_rwf() async {
    return await storage.read(key: RWF_KEY + userKey);
  }

  Future<String?> get_vfCode() async {
    return await storage.read(key: VFCODE_KEY + userKey);
  }

  ////////////////////////////////////////////////////////////////////////////
  //
  // deprecated for new wallet....
  //

  Future<String> get_userID({String? userKeyTmp}) async {
    return await storage.read(key: USERID_KEY + (userKeyTmp ?? userKey)) ?? 'NOT_USERID';
  }

  Future<String> get_publickey() async {
    return await storage.read(key: PUB_KEY + userKey) ?? 'NOT_PUBKEY';
  }

  Future<String> get_fcmToken() async {
    return await storage.read(key: FCM_KEY + userKey) ?? 'NOT_TOKEN';
  }

  Future<String> get_key({String? userKeyTmp, String? address}) async {
    return await storage.read(key: KEYPAIR_KEY + (userKeyTmp ?? userKey) + (address ?? '')) ?? 'NOT_KEY';
  }

  Future<String> get_address() async {
    return await storage.read(key: ADDRESS_KEY + userKey) ?? 'NOT_ADDRESS';
  }

  Future<String> get_networkList() async {
    return await storage.read(key: NETWORKLIST_KEY + userKey) ?? 'NOT_NETWORK_LIST';
  }

  Future<String> get_coinList() async {
    return await storage.read(key: COIN_LIST_KEY + userKey) ?? 'NOT_COIN_LIST';
  }

  Future<String> get_selectedCoin() async {
    return await storage.read(key: SELECTED_COIN_KEY + userKey) ?? 'NOT_SELECTED_COIN';
  }

  Future<String> get_selectedMainNetId() async {
    return await storage.read(key: SELECTED_MAINNET_KEY + userKey) ?? 'NOT_SELECTED_MAIN';
  }

  Future<String> get_trash() async {
    return await storage.read(key: TRASH_KEY + userKey) ?? 'NOT_TRASH';
  }

  Future<String> get_registDate() async {
    return await storage.read(key: REGISTDATE_KEY + userKey) ?? 'NOT_REGISTDATE';
  }

  Future<String> get_useLocalAuth() async {
    return await storage.read(key: USELOCALAUTH_KEY + userKey) ?? 'NOT_USELOCALAUTH';
  }

  Future<String> get_rootKey() async {
    return await storage.read(key: ROOT_KEY + userKey) ?? 'NOT_ROOTKEY';
  }

  Future<String> get_mnemonic({String? userKeyTmp}) async {
    return await storage.read(key: MNEMONIC_KEY + (userKeyTmp ?? userKey)) ?? 'NOT_MNEMONIC';
  }

  Future<String> get_check_mnemonic({String? userKeyTmp}) async {
    return await storage.read(key: CHECK_MNEMONIC_KEY + (userKeyTmp ?? userKey)) ?? 'NOT_CHECK_MNEMONIC';
  }

  Future<String> get_addressList() async {
    return await storage.read(key: ADDRESSLIST_KEY + userKey) ?? 'NOT_ADDRESSLIST';
  }

  Future<bool> get_loginDate() async {
    String loginDateStr = await storage.read(key: LOGINDATE_KEY + userKey) ?? 'NOT_LOGIN';
    if (loginDateStr == 'NOT_LOGIN') {
      return false;
    } else {
      DateTime loginDate = DateTime.parse(loginDateStr);
      DateTime nowDate = DateTime.now();
      if (nowDate.difference(loginDate).inDays <= 15) {
        return true;
      } else {
        UserHelper().clearLoginDate();
        return false;
      }
    }
  }

  Future<void> clearAllUser() async {
    userKey = '';
    await storage.deleteAll();
  }

  Future<void> clearUser() async {
    await storage.delete(key: USERID_KEY + userKey);
    await storage.delete(key: UID_KEY + userKey);
    await storage.delete(key: PUB_KEY + userKey);
    await storage.delete(key: FCM_KEY + userKey);
    await storage.delete(key: KEYPAIR_KEY + userKey);
    await storage.delete(key: NETWORKLIST_KEY + userKey);
    await storage.delete(key: COIN_LIST_KEY + userKey);
    await storage.delete(key: SELECTED_COIN_KEY + userKey);
    await storage.delete(key: ROOT_KEY + userKey);
    await storage.delete(key: MNEMONIC_KEY + userKey);
    await storage.delete(key: ADDRESSLIST_KEY + userKey);
    await storage.delete(key: ADDRESS_KEY + userKey);
    userKey = '';
  }

  Future<void> clearKey() async {
    await storage.delete(key: KEYPAIR_KEY);
  }

  Future<void> clearLoginDate() async {
    await storage.delete(key: LOGINDATE_KEY);
  }
}
