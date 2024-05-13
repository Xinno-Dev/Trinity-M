
import 'package:json_annotation/json_annotation.dart';
import 'package:larba_00/domain/model/product_item_model.dart';
import 'package:larba_00/domain/model/seller_model.dart';
import '../../common/const/utils/convertHelper.dart';

part 'product_model.g.dart';

enum CD_PROD_TYPE {
  main,
  option,
}

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
  String?   saleProdId;   // 판매상품 ID
  String?   type;         // 상품종류. CD_PROD_TYPE 값
  String?   name;         // 상품이름

  // 목록 정보..
  String?   repImg;       // 상품 목록 이미지
  int?      totalAmount;  // 현재 상품의 전체 아이템 개수
  int?      remainAmount; // 현재 상품의 잔여(미판매) 아이템 개수
  String?   itemPrice;    // 아이템 개당 가격
  String?   priceUnit;    // 가격 단위
  String?   status;       // CD_SALE_ST

  // 상세 정보..
  String?   repDetailImg; // 상품 디테일 이미지
  String?   desc;         // 상품 내용
  String?   desc2;        // 상품 내용 2
  String?   externUrl;    // 상품에 대한 추가정보 Url

  // 판매자 정보..
  SellerModel? seller;

  // 옵션 정보..
  List<ProductItemModel>? optionList;

  int?        showIndex;    // 상품 순서
  DateTime?   createTime;
  DateTime?   updateTime;

  ProductModel({
    this.saleProdId,
    this.type,
    this.name,

    this.repImg,
    this.totalAmount,
    this.remainAmount,
    this.itemPrice,
    this.priceUnit,
    this.status,

    this.repDetailImg,
    this.desc,
    this.desc2,
    this.externUrl,

    this.seller,
    this.optionList,
    this.showIndex,
    this.createTime,
    this.updateTime,
  });
  
  get amountText {
    return '${CommaIntText(remainAmount)}${INT(totalAmount) > 0 ? ' / ${CommaIntText(totalAmount)}' : ''}';
  }

  get priceText {
    return '${CommaIntText(itemPrice)} $priceUnit';
  }

  get description {
    return STR(desc);
  }

  get description2 {
    return STR(desc2);
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

  factory ProductModel.fromJson(JSON json) => _$ProductModelFromJson(json);
  JSON toJson() => _$ProductModelToJson(this);
}
