// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) => LoginModel(
      ID: json['ID'] as String?,
      status: json['status'] as int?,
      loginType: $enumDecodeNullable(_$LoginTypeEnumMap, json['loginType']),
      userId: json['userId'] as String?,
      userPass: json['userPass'] as String?,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      country: json['country'] as String?,
      imageURL: json['imageURL'] as String?,
      thumbURL: json['thumbURL'] as String?,
      deviceId: json['deviceId'] as String?,
      deviceType: json['deviceType'] as String?,
      accountData: (json['accountData'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, AddressModel.fromJson(e as Map<String, dynamic>)),
      ),
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      loginTime: json['loginTime'] == null
          ? null
          : DateTime.parse(json['loginTime'] as String),
      logoutTime: json['logoutTime'] == null
          ? null
          : DateTime.parse(json['logoutTime'] as String),
    );

Map<String, dynamic> _$LoginModelToJson(LoginModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('ID', instance.ID);
  writeNotNull('status', instance.status);
  writeNotNull('loginType', _$LoginTypeEnumMap[instance.loginType]);
  writeNotNull('userId', instance.userId);
  writeNotNull('userPass', instance.userPass);
  writeNotNull('userName', instance.userName);
  writeNotNull('email', instance.email);
  writeNotNull('mobile', instance.mobile);
  writeNotNull('country', instance.country);
  writeNotNull('imageURL', instance.imageURL);
  writeNotNull('thumbURL', instance.thumbURL);
  writeNotNull('deviceId', instance.deviceId);
  writeNotNull('deviceType', instance.deviceType);
  writeNotNull('accountData',
      instance.accountData?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull('createTime', instance.createTime?.toIso8601String());
  writeNotNull('loginTime', instance.loginTime?.toIso8601String());
  writeNotNull('logoutTime', instance.logoutTime?.toIso8601String());
  return val;
}

const _$LoginTypeEnumMap = {
  LoginType.kakao: 'kakao',
  LoginType.google: 'google',
  LoginType.email: 'email',
};
