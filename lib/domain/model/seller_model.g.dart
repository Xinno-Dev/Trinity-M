// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellerModel _$SellerModelFromJson(Map<String, dynamic> json) => SellerModel(
      address: json['address'] as String?,
      nickId: json['nickId'] as String?,
      subTitle: json['subTitle'] as String?,
      pfImg: json['pfImg'] as String?,
      description: json['description'] as String?,
      follower: (json['follower'] as num?)?.toInt(),
      following: (json['following'] as num?)?.toInt(),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
    );

Map<String, dynamic> _$SellerModelToJson(SellerModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('address', instance.address);
  writeNotNull('nickId', instance.nickId);
  writeNotNull('subTitle', instance.subTitle);
  writeNotNull('pfImg', instance.pfImg);
  writeNotNull('description', instance.description);
  writeNotNull('follower', instance.follower);
  writeNotNull('following', instance.following);
  writeNotNull('updateTime', instance.updateTime?.toIso8601String());
  return val;
}
