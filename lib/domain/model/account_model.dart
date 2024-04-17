
import 'package:json_annotation/json_annotation.dart';

import '../../common/const/utils/convertHelper.dart';

part 'account_model.g.dart';

@JsonSerializable(
    includeIfNull: false
)
class AccountModel {
  String?   address;
  int?      status;
  String?   nickId;
  String?   subTitle;
  String?   description;
  DateTime? createTime;

  AccountModel({
    this.address,
    this.status,
    this.nickId,
    this.subTitle,
    this.description,
    this.createTime,
  });

  static create({
      required String nickId,
      required String address,
      int status = 1,
    }) {
    return AccountModel(
      address: address,
      status: status,
      nickId: nickId,
      subTitle: '',
      description: '',
      createTime: DateTime.now(),
    );
  }

  factory AccountModel.fromJson(JSON json) => _$AccountModelFromJson(json);
  JSON toJson() => _$AccountModelToJson(this);
}
