// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecckeypair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EccKeyPairImpl _$$EccKeyPairImplFromJson(Map<String, dynamic> json) =>
    _$EccKeyPairImpl(
      publicKey: json['publicKey'] as String,
      d: json['d'] as String,
    );

Map<String, dynamic> _$$EccKeyPairImplToJson(_$EccKeyPairImpl instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'd': instance.d,
    };
