
import 'package:json_annotation/json_annotation.dart';

import '../../common/const/utils/convertHelper.dart';

part 'address_model.g.dart';

@JsonSerializable(
  includeIfNull: false
)
class AddressModel {
  // for Larba..
  String? nickId;
  String? subTitle;
  String? description;
  int?    status;

  // for Byffin..
  String? address;
  String? keyPair;
  String? publicKey;
  String? accountName;
  bool?   hasMnemonic;
  int?    orderIndex;

  String? imageURL;
  String? thumbURL;
  DateTime? createTime;

  AddressModel({
    this.nickId,
    this.subTitle,
    this.description,
    this.status,

    this.keyPair,
    this.publicKey,
    this.accountName,
    this.hasMnemonic,
    this.orderIndex,
    this.address,

    this.imageURL,
    this.thumbURL,
    this.createTime,
  });

  factory AddressModel.fromJson(JSON json) => _$AddressModelFromJson(json);
  JSON toJson() => _$AddressModelToJson(this);
}
