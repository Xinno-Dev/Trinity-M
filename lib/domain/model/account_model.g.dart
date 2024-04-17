// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountModel _$AccountModelFromJson(Map<String, dynamic> json) => AccountModel(
      address: json['address'] as String?,
      status: json['status'] as int?,
      nickId: json['nickId'] as String?,
      subTitle: json['subTitle'] as String?,
      description: json['description'] as String?,
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
    );

Map<String, dynamic> _$AccountModelToJson(AccountModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('address', instance.address);
  writeNotNull('status', instance.status);
  writeNotNull('nickId', instance.nickId);
  writeNotNull('subTitle', instance.subTitle);
  writeNotNull('description', instance.description);
  writeNotNull('createTime', instance.createTime?.toIso8601String());
  return val;
}
