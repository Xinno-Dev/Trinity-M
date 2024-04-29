import 'dart:convert';

import 'package:larba_00/common/const/utils/aesManager.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:crypto/crypto.dart' as crypto;

import 'package:larba_00/domain/model/ecckeypair.dart';
import 'package:uuid/uuid.dart';
import '../../common/const/constants.dart';
import '../../common/const/utils/appVersionHelper.dart';
import '../../common/const/utils/convertHelper.dart';
import 'account_model.dart';
import 'address_model.dart';

part 'user_model.g.dart';

@JsonSerializable(
    explicitToJson: true,
    includeIfNull: false
)
class UserModel {
  String?     ID;             // UUID
  int?        status;         // status 1: active, 0: disable
  LoginType?  loginType;      // login type ['kakao', 'email'..]

  String? mnemonic;       // main mnemonic
  String? keyPair;        // main wallet keyPair

  String? socialId;       // login user social id
  String? socialToken;    // social login token
  String? userName;       // login user name
  String? email;          // login user email
  String? mobile;         // mobile number
  String? country;        // user country (from mobile)
  String? pic;            // profile image
  String? picThumb;       // thumbnail image
  String? deviceId;       // device uuid
  String? deviceType;     // device type ['android', 'ios'...]

  DateTime? createTime;
  DateTime? loginTime;
  DateTime? logoutTime;

  List<AddressModel>? addressList; // Map<address, model> address list..

  UserModel({
    this.ID,
    this.status,
    this.loginType,

    this.mnemonic,
    this.keyPair,

    this.socialId,
    this.socialToken,
    this.userName,
    this.email,
    this.mobile,
    this.country,
    this.pic,
    this.picThumb,
    this.deviceId,
    this.deviceType,
    this.addressList,

    this.createTime,
    this.loginTime,
    this.logoutTime,
  });

  static createFromKakao(user) {
    LOG('--> createFromKakao : ${user.id}');
    return UserModel(
      ID:         'kakao${user.id}', // 임시 ID 생성..
      status:     1,
      loginType:  LoginType.kakao,
      email:      user.kakaoAccount?.email,
      userName:   user.kakaoAccount?.profile?.nickname,
      pic:        user.kakaoAccount?.profile?.profileImageUrl,
      picThumb:   user.kakaoAccount?.profile?.thumbnailImageUrl,
    );
  }

  static createFromGoogle(User user) {
    LOG('--> createFromGoogle : ${user.uid}');
    return UserModel(
      ID:         'google${user.uid}', // 임시 ID 생성..
      status:     1,
      loginType:  LoginType.google,
      email:      user.email,
      userName:   user.displayName,
      pic:        user.photoURL,
      picThumb:   user.photoURL,
    );
  }

  get encryptAes async {
    var deviceId = await getDeviceId();
    var pass = crypto.sha256.convert(utf8.encode(deviceId)).toString();
    return await AesManager().encrypt(pass, jsonEncode(this.toJson()));
  }

  static Future<UserModel?> createFromEmail(String encStr) async {
    // try {
      var deviceId = await getDeviceId();
      LOG('---> createFromEmail : $deviceId');
      var pass = crypto.sha256.convert(utf8.encode(deviceId)).toString();
      var encInfo = await AesManager().decrypt(pass, encStr);
      LOG('---> encInfo : $encInfo');
      var jsonInfo = jsonDecode(encInfo);
      LOG('---> jsonInfo : $jsonInfo');
      return UserModel.fromJson(jsonInfo);
    // } catch (e) {
    //   LOG('---> decryptAes error : $e');
    // }
    return null;
  }

  factory UserModel.fromJson(JSON json) => _$UserModelFromJson(json);
  JSON toJson() => _$UserModelToJson(this);
}
