// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductItemModel _$ProductItemModelFromJson(Map<String, dynamic> json) =>
    ProductItemModel(
      itemId: json['itemId'] as String?,
      itemType: json['itemType'] as String?,
      address: json['address'] as String?,
      img: json['img'] as String?,
      name: json['name'] as String?,
      desc: json['desc'] as String?,
      desc2: json['desc2'] as String?,
      tokenId: json['tokenId'] as String?,
      chainId: json['chainId'] as String?,
      type: json['type'] as String?,
      symbol: json['symbol'] as String?,
      totalSupply: json['totalSupply'] as String?,
      issuer: json['issuer'] == null
          ? null
          : SellerModel.fromJson(json['issuer'] as Map<String, dynamic>),
      externalUrl: json['externalUrl'] as String?,
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
    );

Map<String, dynamic> _$ProductItemModelToJson(ProductItemModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('itemId', instance.itemId);
  writeNotNull('itemType', instance.itemType);
  writeNotNull('address', instance.address);
  writeNotNull('img', instance.img);
  writeNotNull('name', instance.name);
  writeNotNull('desc', instance.desc);
  writeNotNull('desc2', instance.desc2);
  writeNotNull('tokenId', instance.tokenId);
  writeNotNull('chainId', instance.chainId);
  writeNotNull('type', instance.type);
  writeNotNull('symbol', instance.symbol);
  writeNotNull('totalSupply', instance.totalSupply);
  writeNotNull('externalUrl', instance.externalUrl);
  writeNotNull('issuer', instance.issuer?.toJson());
  writeNotNull('createTime', instance.createTime?.toIso8601String());
  writeNotNull('updateTime', instance.updateTime?.toIso8601String());
  return val;
}
