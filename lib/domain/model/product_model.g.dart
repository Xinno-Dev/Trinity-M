// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      prodSaleId: json['prodSaleId'] as String?,
      itemType: json['itemType'] as String?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      tagId: (json['tagId'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      repImg: json['repImg'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toInt(),
      remainAmount: (json['remainAmount'] as num?)?.toInt(),
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
      itemList: (json['itemList'] as List<dynamic>?)
          ?.map((e) => ProductItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      showIndex: (json['showIndex'] as num?)?.toInt(),
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
      isLastItem: json['isLastItem'] as bool?,
      itemLastId: (json['itemLastId'] as num?)?.toInt(),
      itemCountMax: (json['itemCountMax'] as num?)?.toInt(),
      itemCheckId: (json['itemCheckId'] as num?)?.toInt(),
      itemImg: json['itemImg'] as String?,
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('prodSaleId', instance.prodSaleId);
  writeNotNull('itemType', instance.itemType);
  writeNotNull('type', instance.type);
  writeNotNull('name', instance.name);
  writeNotNull('tagId', instance.tagId);
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
  writeNotNull('showIndex', instance.showIndex);
  writeNotNull('createTime', instance.createTime?.toIso8601String());
  writeNotNull('updateTime', instance.updateTime?.toIso8601String());
  writeNotNull('itemList', instance.itemList?.map((e) => e.toJson()).toList());
  writeNotNull('isLastItem', instance.isLastItem);
  writeNotNull('itemLastId', instance.itemLastId);
  writeNotNull('itemCountMax', instance.itemCountMax);
  writeNotNull('itemCheckId', instance.itemCheckId);
  writeNotNull('itemImg', instance.itemImg);
  return val;
}
