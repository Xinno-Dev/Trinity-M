
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
  String?   prodSaleId;   // 판매상품 ID
  String?   type;         // 상품종류. CD_PROD_TYPE 값
  String?   name;         // 상품이름
  String?   repImg;       // 상품에 대한 대표 이미지
  String?   infoImg;      // 상품에 대한 상세 이미지
  String?   totalAmount;  // 현재 상품의 전체 아이템 개수
  String?   remainAmount; // 현재 상품의 잔여(미판매) 아이템 개수
  String?   itemPrice;    // 아이템 개당 가격
  String?   priceUnit;    // 가격 단위
  String?   status;       // CD_SALE_ST

  SellerModel? seller;
  List<ProductItemModel>? optionList;

  int?        showIndex;    // 상품 순서
  DateTime?   createTime;
  DateTime?   updateTime;

  ProductModel({
    this.prodSaleId,
    this.type,
    this.name,
    this.repImg,
    this.infoImg,
    this.totalAmount,
    this.remainAmount,
    this.itemPrice,
    this.priceUnit,
    this.status,
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

  get detailPic {
    return optionList?.first.img;
  }

  get description {
    return STR(optionList?.first.desc);
  }

  get description2 {
    return STR(optionList?.first.desc2);
  }

  get sellerImage {
    return seller?.pfImg;
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
