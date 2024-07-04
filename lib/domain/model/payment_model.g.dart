// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
      purchaseId: json['purchaseId'] as String?,
      orderId: json['orderId'] as String?,
      imgId: json['imgId'] as String?,
      type: json['type'] as String?,
      itemName: json['itemName'] as String?,
      userId: json['userId'] as String?,
      userEmail: json['userEmail'] as String?,
      amount: json['amount'] as String?,
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('purchaseId', instance.purchaseId);
  writeNotNull('orderId', instance.orderId);
  writeNotNull('imgId', instance.imgId);
  writeNotNull('type', instance.type);
  writeNotNull('itemName', instance.itemName);
  writeNotNull('userId', instance.userId);
  writeNotNull('userEmail', instance.userEmail);
  writeNotNull('amount', instance.amount);
  writeNotNull('currency', instance.currency);
  return val;
}
