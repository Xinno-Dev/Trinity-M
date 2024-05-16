
import 'package:json_annotation/json_annotation.dart';
import '../../../../domain/model/product_item_model.dart';
import '../../../../domain/model/seller_model.dart';
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
  String?   itemType;     // 아이템 종류. mk_item.CD_ITEM_TYPE 값
  String?   type;         // 상품종류. mk_prod.CD_PROD_TYPE 값
  String?   name;         // 상품이름
  int?      tagId;        // 상품타입 CD_TAG 값

  // 목록 정보..
  String?   repImg;       // 상품 목록 이미지
  int?      totalAmount;  // 현재 상품의 전체 아이템 개수
  int?      remainAmount; // 현재 상품의 잔여(미판매) 아이템 개수
  String?   itemPrice;    // 아이템 개당 가격
  String?   priceUnit;    // 가격 단위
  String?   status;       // CD_SALE_ST 값

  // 상세 정보..
  String?   repDetailImg; // 상품 디테일 이미지
  String?   desc;         // 상품 내용
  String?   desc2;        // 상품 내용 2
  String?   externUrl;    // 상품에 대한 추가정보 Url

  // 판매자 정보..
  SellerModel? seller;

  int?        showIndex;    // 상품 순서
  DateTime?   createTime;
  DateTime?   updateTime;

  // 옵션 정보..
  List<ProductItemModel>? itemList;
  bool? isLastItem;
  int?  itemLastId;     // 아이템 목록 마지막 ID
  int?  itemCountMax;   // 아이템 전체 갯수
  int?  itemCheckId;    // 아이템 목록 조회 마지막 ID

  ProductModel({
    this.saleProdId,
    this.itemType,
    this.type,
    this.name,
    this.tagId,

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
    this.itemList,
    this.showIndex,
    this.createTime,
    this.updateTime,

    this.isLastItem,
    this.itemLastId,
    this.itemCountMax,
    this.itemCheckId,
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

  updateItem(ProductItemModel newItem) {
    var isAdd = true;
    itemList ??= [];
    for (var orgItem in itemList!) {
      if (orgItem.itemId == newItem.itemId) {
        var index = itemList!.indexOf(orgItem);
        itemList![index] = newItem;
        isAdd = false;
        break;
      }
    }
    if (isAdd) {
      itemList!.add(newItem);
    }
    return itemList;
  }

  factory ProductModel.fromJson(JSON json) => _$ProductModelFromJson(json);
  JSON toJson() => _$ProductModelToJson(this);
}
