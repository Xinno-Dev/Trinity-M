import 'dart:convert';

import '../../common/const/utils/aesManager.dart';
import '../../common/provider/login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import '../../domain/model/ecckeypair.dart';
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
  String?     uid;          // user id from login
  int?        status;       // status 1: login done, 0: login not yet..
  LoginType?  loginType;    // login type ['kakao', 'email'..]
  bool?   bioIdentityYN;    // 생체인증 여부

  String? mnemonic;         // main mnemonic
  String? keyPair;          // main wallet keyPair

  String? socialId;         // login user social id
  String? socialToken;      // social login token
  String? userName;         // login user name
  String? email;            // login user email
  String? mobile;           // mobile number
  String? country;          // user country (from mobile)
  String? pic;              // profile image
  String? picThumb;         // thumbnail image
  String? deviceId;         // device uuid
  String? deviceType;       // device type ['android', 'ios'...]

  String? certUpdt;         // 본인인증 시간
  String? withdrawDt;       // 회원탈퇴 시간

  List<AddressModel>? addressList; // Map<address, model> address list..

  UserModel({
    this.uid,
    this.status,
    this.loginType,
    this.bioIdentityYN,

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
    this.certUpdt,
    this.withdrawDt,
  });

  static createFromKakao(kakao.User user) {
    var token = STR(user.properties!['token']);
    LOG('--> createFromKakao : ${user.id} / $token');
    return UserModel(
      status:       1,
      loginType:    LoginType.kakaotalk,
      email:        user.kakaoAccount?.email,
      userName:     user.kakaoAccount?.profile?.nickname,
      pic:          user.kakaoAccount?.profile?.profileImageUrl,
      picThumb:     user.kakaoAccount?.profile?.thumbnailImageUrl,
      socialToken:  token
    );
  }

  static createFromGoogle(User user) {
    LOG('--> createFromGoogle : ${user.uid}');
    return UserModel(
      status:     1,
      loginType:  LoginType.google,
      email:      user.email,
      userName:   user.displayName,
      pic:        user.photoURL,
      picThumb:   user.photoURL,
    );
  }

  static createFromEmail(String email) {
    return UserModel(
      status:     1,
      email:      email,
      loginType:  LoginType.email,
    );
  }

  static createFromInfo(JSON info) {
    LOG('--> createFromInfo : ${info.toString()}');
    List<AddressModel> addr = [];
    var accounts = info['accounts'];
    if (accounts != null) {
      for (var item in accounts) {
        addr.add(AddressModel(
          accountName:  STR(item['nickId']),
          address:      STR(item['address']),
          subTitle:     STR(item['subTitle']),
          description:  STR(item['description']),
          image:        STR(item['image']),
        ));
      }
    }
    return UserModel(
      status:       1,
      uid:          STR(info['uid']),
      email:        STR(info['email']),
      certUpdt:     STR(info['certUpdt']),
      withdrawDt:   STR(info['estimatedWithdrawDt']),
      addressList: addr,
    );
  }

  get encryptAes async {
    var deviceId = await getDeviceId();
    var pass = crypto.sha256.convert(utf8.encode(deviceId)).toString();
    var loginInfo = UserModel(
      uid:       this.uid,
      status:    this.status,
      email:     this.email,
      loginType: this.loginType,
    );
    return await AesManager().encrypt(pass, Uri.encodeFull(jsonEncode(loginInfo.toJson())));
  }

  static Future<UserModel?> createFromLocalEnc(String encUser) async {
    try {
      var deviceId  = await getDeviceId();
      var pass      = crypto.sha256.convert(utf8.encode(deviceId)).toString();
      var encInfo   = await AesManager().decrypt(pass, encUser);
      var jsonInfo  = jsonDecode(Uri.decodeFull(encInfo));
      return UserModel.fromJson(jsonInfo);
    } catch (e) {
      LOG('---> createFromLocal error : $e');
    }
    return null;
  }

  factory UserModel.fromJson(JSON json) => _$UserModelFromJson(json);
  JSON toJson() => _$UserModelToJson(this);
}
