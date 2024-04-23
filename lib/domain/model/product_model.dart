
import 'package:json_annotation/json_annotation.dart';
import 'package:larba_00/domain/model/product_item_model.dart';
import '../../common/const/utils/convertHelper.dart';

part 'product_model.g.dart';

enum CD_SALE_ST {
  sale,     // 판매중
  close,    // 판매완료
  cancel,   // 판매취소(판매자)
  cancelEx, // 판매취소(관리자)
}

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ProductModel {
  String      id;           // mk_item_sell ID
  String      title;        // 상품명
  String      pic;          // 상품 이미지(메인)
  String?     picThumb;     // 상품 이미지(리스트)
  String?     edition;      // 상품 에디션
  String?     description;  // 상품 설명
  String?     externUrl;    // 상품 설명 외부 URL
  int?        showIndex;    // 상품 순서

  // sell..
  String      productId;    // mk_product ID
  int         amount;       // 판매 수량
  int?        amountMax;    // 판매 수량 max
  double      price;        // 판매 가격(개당)
  String      currency;     // 판매 통화
  CD_SALE_ST  status;       // 판매 상태
  DateTime?   startTime;    // 판매 시작 시간
  DateTime?   endTime;      // 판매 종료 시간

  // seller..
  String      sellerAddr;     // 판매자 지갑 주소
  String      sellerName;     // 판매자 명칭
  String?     sellerNameEx;   // 판매자 명칭 ex
  String?     sellerPic;      // 판매자 이미지
  String?     sellerDesc;     // 판매자 설명
  int?        sellerFollower; // 판매자 팔로워
  int?        sellerFollowing;// 판매자 팔로잉

  DateTime?   createTime;
  DateTime?   updateTime;

  // item..
  List<ProductItemModel>? optionList;

  ProductModel({
    required this.id,
    required this.title,
    required this.pic,
    required this.productId,
    required this.sellerAddr,
    required this.sellerName,
    required this.amount,
    required this.price,
    required this.currency,
    required this.status,
    this.picThumb,
    this.showIndex,
    this.edition,
    this.description,
    this.externUrl,
    this.amountMax,
    this.sellerNameEx,
    this.sellerPic,
    this.sellerDesc,
    this.sellerFollower,
    this.sellerFollowing,
    this.startTime,
    this.endTime,
    this.createTime,
    this.updateTime,
    this.optionList,
  });

  get amountText {
    return '${CommaIntText(amount)}${INT(amountMax) > 0 ? ' / ${CommaIntText(amountMax)}' : ''}';
  }

  get priceText {
    return '${CommaIntText(price)} $currency';
  }

  factory ProductModel.fromJson(JSON json) => _$ProductModelFromJson(json);
  JSON toJson() => _$ProductModelToJson(this);
}
