// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductItemModel _$ProductItemModelFromJson(Map<String, dynamic> json) =>
    ProductItemModel(
      id: json['id'] as String,
      status: $enumDecode(_$CD_ITEM_STEnumMap, json['status']),
      contAddr: json['contAddr'] as String,
      tokenId: json['tokenId'] as String,
      pic: json['pic'] as String,
      amount: json['amount'] as int,
      ownerAddr: json['ownerAddr'] as String,
      index: json['index'] as int?,
      picThumb: json['picThumb'] as String?,
      originItemId: json['originItemId'] as String?,
      txHash: json['txHash'] as String?,
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
    );

Map<String, dynamic> _$ProductItemModelToJson(ProductItemModel instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'status': _$CD_ITEM_STEnumMap[instance.status]!,
    'contAddr': instance.contAddr,
    'tokenId': instance.tokenId,
    'pic': instance.pic,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('picThumb', instance.picThumb);
  val['amount'] = instance.amount;
  writeNotNull('index', instance.index);
  val['ownerAddr'] = instance.ownerAddr;
  writeNotNull('originItemId', instance.originItemId);
  writeNotNull('txHash', instance.txHash);
  writeNotNull('createTime', instance.createTime?.toIso8601String());
  writeNotNull('updateTime', instance.updateTime?.toIso8601String());
  return val;
}

const _$CD_ITEM_STEnumMap = {
  CD_ITEM_ST.live: 'live',
  CD_ITEM_ST.deleted: 'deleted',
};
