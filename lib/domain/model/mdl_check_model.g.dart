// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mdl_check_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MDLCheckModel _$MDLCheckModelFromJson(Map<String, dynamic> json) =>
    MDLCheckModel(
      id: json['id'] as String,
      url: json['url'] as String,
      method: json['method'] as String,
      params: json['params'] as String,
    );

Map<String, dynamic> _$MDLCheckModelToJson(MDLCheckModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'method': instance.method,
      'params': instance.params,
    };
