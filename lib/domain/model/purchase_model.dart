
import 'package:json_annotation/json_annotation.dart';
import '../../../../domain/model/product_item_model.dart';
import '../../../../domain/model/seller_model.dart';
import '../../common/const/utils/convertHelper.dart';

part 'purchase_model.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class PurchaseModel {
  String?   purchaseId;   // 구매 ID
  String?   prodSaleId;   // 판매상품 ID
  String?   merchantUid;  // 주문번호
  String?   itemType;     // 아이템 종류. mk_item.CD_ITEM_TYPE 값
  String?   name;         // 상품이름
  String?   itemId;       // 상품 옵션 id
  String?   itemImg;      // 상품에 이미지 Url

  // 구매 정보..
  String?   price;        // 서버에서 회신된 가격
  String?   buyPrice;     // 구매 가격
  String?   payPrice;     // 상품 가격
  String?   priceUnit;
  String?   txDateTime;
  String?   payType;
  String?   cardType;
  String?   cardNum;
  String?   status;       // 상품 상태 CD_PAY_ST

  // 판매자 정보..
  SellerModel? seller;

  DateTime?   createTime;
  DateTime?   updateTime;

  PurchaseModel({
    this.purchaseId,
    this.prodSaleId,
    this.merchantUid,
    this.itemType,
    this.name,
    this.itemId,
    this.itemImg,

    this.price,
    this.buyPrice,
    this.payPrice,
    this.priceUnit,
    this.txDateTime,
    this.payType,
    this.cardType,
    this.cardNum,
    this.status,

    this.seller,
    this.createTime,
    this.updateTime,
  });

  get priceText {
    return '${CommaIntText(buyPrice)} $priceUnit';
  }

  get payText {
    return '${CommaIntText(payPrice)} $priceUnit';
  }

  get sellerImage {
    return STR(seller?.pfImg);
  }

  get sellerName {
    return STR(seller?.nickId);
  }

  get sellerSubtitle {
    return STR(seller?.subTitle);
  }

  get sellerFollower {
    return INT(seller?.follower);
  }

  get sellerFollowing {
    return INT(seller?.following);
  }

  get sellerDesc {
    return STR(seller?.desc);
  }

  factory PurchaseModel.fromJson(JSON json) => _$PurchaseModelFromJson(json);
  JSON toJson() => _$PurchaseModelToJson(this);
}
