
import 'package:json_annotation/json_annotation.dart';

import '../../common/const/utils/convertHelper.dart';

part 'address_model.g.dart';

@JsonSerializable(
  includeIfNull: false
)
class AddressModel {
  // for Larba..
  String? subTitle;
  String? description;
  String? image;      // 프로파일 이미지
  int?    follower;   // 팔로워
  int?    following;  // 팔로잉

  // for Byffin..
  String? address;
  String? keyPair;    // encrypted KeyPair
  String? publicKey;
  String? accountName;
  bool?   hasMnemonic;
  int?    orderIndex;

  DateTime? createTime;

  AddressModel({
    this.subTitle,
    this.description,
    this.image,
    this.follower,
    this.following,

    this.keyPair,
    this.publicKey,
    this.accountName,
    this.hasMnemonic,
    this.orderIndex,
    this.address,

    this.createTime,
  });

  copyWithInfo(AddressModel source) {
    this.accountName = source.accountName;
    this.subTitle    = source.subTitle;
    this.description = source.description;
    this.image       = source.image;
    return this;
  }

  factory AddressModel.fromJson(JSON json) => _$AddressModelFromJson(json);
  JSON toJson() => _$AddressModelToJson(this);
}
