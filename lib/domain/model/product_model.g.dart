// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      title: json['title'] as String,
      pic: json['pic'] as String,
      productId: json['productId'] as String,
      sellerAddr: json['sellerAddr'] as String,
      sellerName: json['sellerName'] as String,
      amount: json['amount'] as int,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      status: $enumDecode(_$CD_SALE_STEnumMap, json['status']),
      picThumb: json['picThumb'] as String?,
      showIndex: json['showIndex'] as int?,
      edition: json['edition'] as String?,
      description: json['description'] as String?,
      externUrl: json['externUrl'] as String?,
      amountMax: json['amountMax'] as int?,
      sellerNameEx: json['sellerNameEx'] as String?,
      sellerPic: json['sellerPic'] as String?,
      sellerDesc: json['sellerDesc'] as String?,
      sellerFollower: json['sellerFollower'] as int?,
      sellerFollowing: json['sellerFollowing'] as int?,
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
      optionList: (json['optionList'] as List<dynamic>?)
          ?.map((e) => ProductItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'title': instance.title,
    'pic': instance.pic,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('picThumb', instance.picThumb);
  writeNotNull('edition', instance.edition);
  writeNotNull('description', instance.description);
  writeNotNull('externUrl', instance.externUrl);
  writeNotNull('showIndex', instance.showIndex);
  val['productId'] = instance.productId;
  val['amount'] = instance.amount;
  writeNotNull('amountMax', instance.amountMax);
  val['price'] = instance.price;
  val['currency'] = instance.currency;
  val['status'] = _$CD_SALE_STEnumMap[instance.status]!;
  writeNotNull('startTime', instance.startTime?.toIso8601String());
  writeNotNull('endTime', instance.endTime?.toIso8601String());
  val['sellerAddr'] = instance.sellerAddr;
  val['sellerName'] = instance.sellerName;
  writeNotNull('sellerNameEx', instance.sellerNameEx);
  writeNotNull('sellerPic', instance.sellerPic);
  writeNotNull('sellerDesc', instance.sellerDesc);
  writeNotNull('sellerFollower', instance.sellerFollower);
  writeNotNull('sellerFollowing', instance.sellerFollowing);
  writeNotNull('createTime', instance.createTime?.toIso8601String());
  writeNotNull('updateTime', instance.updateTime?.toIso8601String());
  writeNotNull(
      'optionList', instance.optionList?.map((e) => e.toJson()).toList());
  return val;
}

const _$CD_SALE_STEnumMap = {
  CD_SALE_ST.sale: 'sale',
  CD_SALE_ST.close: 'close',
  CD_SALE_ST.cancel: 'cancel',
  CD_SALE_ST.cancelEx: 'cancelEx',
};
