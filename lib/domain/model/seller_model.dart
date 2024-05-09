
import 'package:json_annotation/json_annotation.dart';
import 'package:larba_00/domain/model/product_item_model.dart';
import '../../common/const/utils/convertHelper.dart';

part 'seller_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class SellerModel {
  String? address;      // 판매자 주소
  String? nickId;
  String? subTitle;
  String? pfImg;
  String? desc;

  int?  follower;
  int?  following;

  DateTime?   createTime;
  DateTime?   updateTime;

  SellerModel({
    this.address,
    this.nickId,
    this.subTitle,
    this.pfImg,
    this.desc,

    this.follower,
    this.following,

    this.createTime,
    this.updateTime,
  });

  factory SellerModel.fromJson(JSON json) => _$SellerModelFromJson(json);
  JSON toJson() => _$SellerModelToJson(this);
}
