import 'package:json_annotation/json_annotation.dart';
import '../../../../domain/model/seller_model.dart';
import '../../common/const/utils/convertHelper.dart';

part 'product_item_model.g.dart';

enum CD_ITEM_ST {
  live,
  deleted,
}

enum CD_ITEM_TYPE {
  ticket,
  art,
}

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ProductItemModel {
  String?   itemId;
  String?   itemType;     // CD_ITEM_TYPE
  String?   address;
  String?   img;          // 부가상품 이미지
  String?   name;
  String?   desc;         // 거래체결, 전송 등으로 상품이 새로 생성된 경우, 삭제된 이전 상품ID
  String?   desc2;        // 생성 transaction hash
  String?   tokenId;      // 토큰 ID
  String?   chainId;
  String?   type;
  String?   symbol;
  String?   totalSupply;  // 총 발행량
  String?   externalUrl;

  SellerModel?  issuer;

  DateTime? createTime;
  DateTime? updateTime;

  ProductItemModel({
    this.itemId,
    this.itemType,
    this.address,
    this.img,
    this.name,
    this.desc,
    this.desc2,
    this.tokenId,
    this.chainId,
    this.type,
    this.symbol,
    this.totalSupply,
    this.issuer,
    this.externalUrl,

    this.createTime,
    this.updateTime,
  });

  factory ProductItemModel.fromJson(JSON json) => _$ProductItemModelFromJson(json);
  JSON toJson() => _$ProductItemModelToJson(this);
}
