import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/const/utils/convertHelper.dart';

part 'mdl_history_model.g.dart';

@JsonSerializable()
class MDLHistoryModel {
  String txId;
  String from;
  String to;
  String value;
  String time;
  MDLHistoryModel({
    required this.txId,
    required this.from,
    required this.to,
    required this.value,
    required this.time,
  });

  factory MDLHistoryModel.fromJson(JSON json) => _$MDLHistoryModelFromJson(json);
  JSON toJson() => _$MDLHistoryModelToJson(this);
}
