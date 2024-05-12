// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      prodSaleId: json['prodSaleId'] as String?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      repImg: json['repImg'] as String?,
      totalAmount: json['totalAmount'] as String?,
      remainAmount: json['remainAmount'] as String?,
      itemPrice: json['itemPrice'] as String?,
      priceUnit: json['priceUnit'] as String?,
      status: json['status'] as String?,
      repDetailImg: json['repDetailImg'] as String?,
      desc: json['desc'] as String?,
      desc2: json['desc2'] as String?,
      externUrl: json['externUrl'] as String?,
      seller: json['seller'] == null
          ? null
          : SellerModel.fromJson(json['seller'] as Map<String, dynamic>),
      optionList: (json['optionList'] as List<dynamic>?)
          ?.map((e) => ProductItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      showIndex: (json['showIndex'] as num?)?.toInt(),
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('prodSaleId', instance.prodSaleId);
  writeNotNull('type', instance.type);
  writeNotNull('name', instance.name);
  writeNotNull('repImg', instance.repImg);
  writeNotNull('totalAmount', instance.totalAmount);
  writeNotNull('remainAmount', instance.remainAmount);
  writeNotNull('itemPrice', instance.itemPrice);
  writeNotNull('priceUnit', instance.priceUnit);
  writeNotNull('status', instance.status);
  writeNotNull('repDetailImg', instance.repDetailImg);
  writeNotNull('desc', instance.desc);
  writeNotNull('desc2', instance.desc2);
  writeNotNull('externUrl', instance.externUrl);
  writeNotNull('seller', instance.seller?.toJson());
  writeNotNull(
      'optionList', instance.optionList?.map((e) => e.toJson()).toList());
  writeNotNull('showIndex', instance.showIndex);
  writeNotNull('createTime', instance.createTime?.toIso8601String());
  writeNotNull('updateTime', instance.updateTime?.toIso8601String());
  return val;
}
