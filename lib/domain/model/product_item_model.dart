import 'package:json_annotation/json_annotation.dart';
import '../../common/const/utils/convertHelper.dart';

part 'product_item_model.g.dart';

enum CD_ITEM_ST {
  live,
  deleted,
}

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ProductItemModel {
  String      id;
  CD_ITEM_ST  status;       // 아이템 상태
  String      contAddr;     // contract 주소
  String      tokenId;      // token id
  String      pic;          // 이미지(메인)
  String?     picThumb;     // 이미지(리스트)
  int         amount;       // token amount
  int?        index;
  String      ownerAddr;    // 현 소유자 주소
  String?     originItemId; // 거래체결, 전송 등으로 상품이 새로 생성된 경우, 삭제된 이전 상품ID
  String?     txHash;       // 생성 transaction hash
  DateTime?   createTime;
  DateTime?   updateTime;

  ProductItemModel({
    required this.id,
    required this.status,
    required this.contAddr,
    required this.tokenId,
    required this.pic,
    required this.amount,
    required this.ownerAddr,
    this.index,
    this.picThumb,
    this.originItemId,
    this.txHash,
    this.createTime,
    this.updateTime,
  });

  factory ProductItemModel.fromJson(JSON json) => _$ProductItemModelFromJson(json);
  JSON toJson() => _$ProductItemModelToJson(this);
}
