// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinModel _$CoinModelFromJson(Map<String, dynamic> json) => CoinModel(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      mainNetChainId: json['mainNetChainId'] as String,
      walletAddress: json['walletAddress'] as String,
      contract: json['contract'] as String?,
      channel: json['channel'] as String?,
      chainCode: json['chainCode'] as String?,
      decimal: json['decimal'] as String?,
      balance: json['balance'] as String?,
      logo: json['logo'] as String?,
      logo_flat: json['logo_flat'] as String?,
      logo_hash: json['logo_hash'] as String?,
      color: json['color'] as String?,
      hideToken: json['hideToken'] as bool?,
      networkType: json['networkType'] as int?,
      balanceUpdateTime: json['balanceUpdateTime'] == null
          ? null
          : DateTime.parse(json['balanceUpdateTime'] as String),
    );

Map<String, dynamic> _$CoinModelToJson(CoinModel instance) {
  final val = <String, dynamic>{
    'symbol': instance.symbol,
    'name': instance.name,
    'mainNetChainId': instance.mainNetChainId,
    'walletAddress': instance.walletAddress,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('contract', instance.contract);
  writeNotNull('decimal', instance.decimal);
  writeNotNull('channel', instance.channel);
  writeNotNull('chainCode', instance.chainCode);
  writeNotNull('balance', instance.balance);
  writeNotNull('logo', instance.logo);
  writeNotNull('logo_flat', instance.logo_flat);
  writeNotNull('logo_hash', instance.logo_hash);
  writeNotNull('color', instance.color);
  writeNotNull('hideToken', instance.hideToken);
  writeNotNull('networkType', instance.networkType);
  writeNotNull(
      'balanceUpdateTime', instance.balanceUpdateTime?.toIso8601String());
  return val;
}
