// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mdl_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MDLHistoryModel _$MDLHistoryModelFromJson(Map<String, dynamic> json) =>
    MDLHistoryModel(
      txId: json['txId'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      value: json['value'] as String,
      time: json['time'] as String,
    );

Map<String, dynamic> _$MDLHistoryModelToJson(MDLHistoryModel instance) =>
    <String, dynamic>{
      'txId': instance.txId,
      'from': instance.from,
      'to': instance.to,
      'value': instance.value,
      'time': instance.time,
    };
