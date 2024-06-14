// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseModel _$PurchaseModelFromJson(Map<String, dynamic> json) =>
    PurchaseModel(
      purchaseId: json['purchaseId'] as String?,
      prodSaleId: json['prodSaleId'] as String?,
      merchantUid: json['merchantUid'] as String?,
      itemType: json['itemType'] as String?,
      name: json['name'] as String?,
      itemId: json['itemId'] as String?,
      itemImg: json['itemImg'] as String?,
      price: json['price'] as String?,
      buyPrice: json['buyPrice'] as String?,
      payPrice: json['payPrice'] as String?,
      priceUnit: json['priceUnit'] as String?,
      txDateTime: json['txDateTime'] as String?,
      payType: json['payType'] as String?,
      cardType: json['cardType'] as String?,
      cardNum: json['cardNum'] as String?,
      status: json['status'] as String?,
      mid: json['mid'] as String?,
      seller: json['seller'] == null
          ? null
          : SellerModel.fromJson(json['seller'] as Map<String, dynamic>),
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
    );

Map<String, dynamic> _$PurchaseModelToJson(PurchaseModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('purchaseId', instance.purchaseId);
  writeNotNull('prodSaleId', instance.prodSaleId);
  writeNotNull('merchantUid', instance.merchantUid);
  writeNotNull('itemType', instance.itemType);
  writeNotNull('name', instance.name);
  writeNotNull('itemId', instance.itemId);
  writeNotNull('itemImg', instance.itemImg);
  writeNotNull('price', instance.price);
  writeNotNull('payPrice', instance.payPrice);
  writeNotNull('buyPrice', instance.buyPrice);
  writeNotNull('priceUnit', instance.priceUnit);
  writeNotNull('txDateTime', instance.txDateTime);
  writeNotNull('payType', instance.payType);
  writeNotNull('cardType', instance.cardType);
  writeNotNull('cardNum', instance.cardNum);
  writeNotNull('status', instance.status);
  writeNotNull('mid', instance.mid);
  writeNotNull('seller', instance.seller?.toJson());
  writeNotNull('createTime', instance.createTime?.toIso8601String());
  writeNotNull('updateTime', instance.updateTime?.toIso8601String());
  return val;
}
