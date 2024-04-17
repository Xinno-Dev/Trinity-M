// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
      nickId: json['nickId'] as String?,
      subTitle: json['subTitle'] as String?,
      description: json['description'] as String?,
      status: json['status'] as int?,
      keyPair: json['keyPair'] as String?,
      publicKey: json['publicKey'] as String?,
      accountName: json['accountName'] as String?,
      hasMnemonic: json['hasMnemonic'] as bool?,
      orderIndex: json['orderIndex'] as int?,
      address: json['address'] as String?,
      imageURL: json['imageURL'] as String?,
      thumbURL: json['thumbURL'] as String?,
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
    );

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('nickId', instance.nickId);
  writeNotNull('subTitle', instance.subTitle);
  writeNotNull('description', instance.description);
  writeNotNull('status', instance.status);
  writeNotNull('address', instance.address);
  writeNotNull('keyPair', instance.keyPair);
  writeNotNull('publicKey', instance.publicKey);
  writeNotNull('accountName', instance.accountName);
  writeNotNull('hasMnemonic', instance.hasMnemonic);
  writeNotNull('orderIndex', instance.orderIndex);
  writeNotNull('imageURL', instance.imageURL);
  writeNotNull('thumbURL', instance.thumbURL);
  writeNotNull('createTime', instance.createTime?.toIso8601String());
  return val;
}
