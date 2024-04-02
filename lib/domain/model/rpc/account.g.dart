// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
      address: json['address'] as String?,
      name: json['name'] as String?,
      url: json['url'] as String?,
      nonce: json['nonce'] as String?,
      balance: json['balance'] as String?,
    );

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'address': instance.address,
      'name': instance.name,
      'url': instance.url,
      'nonce': instance.nonce,
      'balance': instance.balance,
    };
