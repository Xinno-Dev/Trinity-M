import 'package:larba_00/common/provider/login_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../common/const/constants.dart';
import '../../common/const/utils/convertHelper.dart';
import 'address_model.dart';

part 'login_model.g.dart';

@JsonSerializable(
    explicitToJson: true,
    includeIfNull: false
)
class LoginModel {
  String?     ID;             // UUID
  int?        status;         // status 1: active, 0: disable
  LoginType?  loginType;      // login type ['kakao', 'email'..]
  String? userId;         // id / nickName
  String? userPass;       // user password ??
  String? userName;       // real name
  String? email;          // login email
  String? mobile;         // mobile number
  String? country;        // user country (from mobile)
  String? imageURL;       // profile image
  String? thumbURL;       // thumbnail image
  String? deviceId;       // device uuid
  String? deviceType;     // device type ['android', 'ios'...]

  Map<String,AddressModel>? accountData; // sub account list..

  DateTime? createTime;
  DateTime? loginTime;
  DateTime? logoutTime;

  LoginModel({
    this.ID,
    this.status,
    this.loginType,
    this.userId,
    this.userPass,
    this.userName,
    this.email,
    this.mobile,
    this.country,
    this.imageURL,
    this.thumbURL,
    this.deviceId,
    this.deviceType,
    this.accountData,

    this.createTime,
    this.loginTime,
    this.logoutTime,
  });

  static createFromKakao(user) {
    LOG('--> createFromKakao : ${user.id}');
    return LoginModel(
      ID:         'kakao${user.id}', // 임시 ID 생성..
      status:     1,
      loginType:  LoginType.kakao,
      email:      user.kakaoAccount?.email,
      userId:     user.kakaoAccount?.profile?.nickname,
      imageURL:   user.kakaoAccount?.profile?.profileImageUrl,
      thumbURL:   user.kakaoAccount?.profile?.thumbnailImageUrl,
    );
  }

  static createFromGoogle(User user) {
    LOG('--> createFromGoogle : ${user.uid}');
    return LoginModel(
      ID:         'google${user.uid}', // 임시 ID 생성..
      status:     1,
      loginType:  LoginType.google,
      email:      user.email,
      userId:     user.displayName,
      imageURL:   user.photoURL,
    );
  }

  static createFromEmail(String uid, String email, String accountName) {
    LOG('--> createFromEmail : $uid / $email');
    return LoginModel(
      ID:         'email$uid', // 임시 ID 생성..
      status:     1,
      loginType:  LoginType.email,
      email:      email,
      userId:     accountName,
    );
  }

  addAccount({
    required String address,
    required String accountName,
  }) {
    final newAccount = AddressModel(
      address: address,
      accountName: accountName,
    );
    this.accountData ??= {};
    this.accountData![address] = newAccount;
  }

  factory LoginModel.fromJson(JSON json) => _$LoginModelFromJson(json);
  JSON toJson() => _$LoginModelToJson(this);
}
