import 'package:larba_00/common/provider/login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:larba_00/domain/model/ecckeypair.dart';
import 'package:uuid/uuid.dart';
import '../../common/const/constants.dart';
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

  static createFromEmail(String uid, String email) {
    LOG('--> createFromEmail : $uid / $email');
    return UserModel(
      ID:         'email$uid', // 임시 ID 생성..
      status:     1,
      loginType:  LoginType.email,
      email:      email,
    );
  }

  factory UserModel.fromJson(JSON json) => _$UserModelFromJson(json);
  JSON toJson() => _$UserModelToJson(this);
}
