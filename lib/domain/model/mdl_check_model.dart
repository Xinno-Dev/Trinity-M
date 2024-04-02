import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/const/utils/convertHelper.dart';

part 'mdl_check_model.g.dart';

@JsonSerializable()
class MDLCheckModel {
  String id;
  String url;
  String method;
  String params;
  MDLCheckModel({
    required this.id,
    required this.url,
    required this.method,
    required this.params,
  });

  factory MDLCheckModel.fromJson(JSON json) => _$MDLCheckModelFromJson(json);
  JSON toJson() => _$MDLCheckModelToJson(this);
}
