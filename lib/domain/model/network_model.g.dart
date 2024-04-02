// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetworkModel _$NetworkModelFromJson(Map<String, dynamic> json) => NetworkModel(
      index: json['index'] as int,
      name: json['name'] as String,
      url: json['url'] as String,
      httpUrl: json['httpUrl'] as String,
      chainId: json['chainId'] as String,
      id: json['id'] as String?,
      channel: json['channel'] as String?,
      symbol: json['symbol'] as String?,
      exploreUrl: json['exploreUrl'] as String?,
      networkType: json['networkType'] as int?,
      chainList: json['chainList'] as List<dynamic>?,
      nameOrg: json['nameOrg'] as String?,
    );

Map<String, dynamic> _$NetworkModelToJson(NetworkModel instance) {
  final val = <String, dynamic>{
    'index': instance.index,
    'name': instance.name,
    'url': instance.url,
    'httpUrl': instance.httpUrl,
    'chainId': instance.chainId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('channel', instance.channel);
  writeNotNull('symbol', instance.symbol);
  writeNotNull('exploreUrl', instance.exploreUrl);
  writeNotNull('networkType', instance.networkType);
  writeNotNull('chainList', instance.chainList);
  writeNotNull('nameOrg', instance.nameOrg);
  return val;
}
