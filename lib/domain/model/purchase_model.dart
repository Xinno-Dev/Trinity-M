
import 'package:json_annotation/json_annotation.dart';
import '../../../../domain/model/product_item_model.dart';
import '../../../../domain/model/seller_model.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../main.dart';

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
  String?   payPrice;     // 구매 가격
  String?   buyPrice;     // 상품 가격
  String?   priceUnit;
  String?   txDateTime;
  String?   payType;
  String?   cardType;
  String?   cardNum;
  String?   status;       // 상품 상태 CD_PAY_ST
  String?   mid;          // Merchant uID

  // 결제 정보..
  List<String>? availablePayType; // 1:신용카드 2:계좌이체
  JSON?         transferAccount;

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
    this.mid,

    this.availablePayType,
    this.transferAccount,

    this.seller,
    this.createTime,
    this.updateTime,
  });

  get priceUnitText {
    final lang = appLocaleDelegate.appLocale.locale.languageCode;
    var priceUnitStr = priceUnit ?? 'KRW';
    if (priceUnitStr.toLowerCase() == 'krw' && lang == 'ko') {
      priceUnitStr = '원';
    }
    return priceUnitStr;
  }

  get priceText {
    return '${CommaIntText(buyPrice)} $priceUnitText';
  }

  get payText {
    return '${CommaIntText(payPrice)} $priceUnitText';
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
    return STR(seller?.description);
  }

  get bankName {
    return transferAccount?['bank'];
  }

  get bankNumber {
    return transferAccount?['number'];
  }

  get isCardPayOn {
    return availablePayType?.contains('1') ?? false;
  }

  get isBankPayOn {
    return availablePayType?.contains('2') ?? false;
  }

  factory PurchaseModel.fromJson(JSON json) => _$PurchaseModelFromJson(json);
  JSON toJson() => _$PurchaseModelToJson(this);
}
