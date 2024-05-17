import 'dart:convert';
import 'dart:math';

import '../../../../domain/model/product_item_model.dart';
import '../../../../domain/model/product_model.dart';
import '../../../../domain/model/seller_model.dart';
import 'package:uuid/uuid.dart';

import '../../common/const/utils/convertHelper.dart';
import '../../services/api_service.dart';
import '../model/category_model.dart';

class MarketRepository {
  static final _apiService = ApiService();

  Map<String, ProductModel> productData = {};
  Map<String, ProductItemModel> optionData = {};
  List<ProductModel> productList = [];
  List<CategoryModel> categoryList = [];

  var titleN      = ['주말 1박 2일 36홀 (4인) 조식, 숙박, 카트 무료 지원','고메 겟어웨이','제주 봄 미식 프로모션','연박 특가 프로모션','연간 회원권 2024',];
  var sellerN     = ['GoldenBAY Golf & Resort','PARK HYATT Seoul','PARNAS HOTEL JEJU','PARK HYATT Seoul','PARNAS HOTEL JEJU'];
  var sellerSubN  = ['골든베이 골프 & 리조트','파크 하얏트 서울','파르나스 호텔 제주','파크 하얏트 서울','파르나스 호텔 제주'];
  var sellerPicN  = ['0','1','2','1','2'];
  var contentImgN = List.generate(6, (index) => 'banner_0$index.png');

  var pageCount = 0;
  var lastId = -1;
  var checkLastId = -2;
  var checkDetailId = '';
  var isLastPage = false;

  init() {
    productData = {}; // product cache data..
    optionData  = {}; // product item cache data..
    productList = [];

    // // add sample products..
    // for (var title in titleN) {
    //   var index = titleN.indexOf(title);
    //   var seller = SellerModel(
    //     address:    'sellerAddr00000001',
    //     nickId:     sellerN[index],
    //     subTitle:   sellerSubN[index],
    //     pfImg:      'seller_pic_0${sellerPicN[index]}.png',
    //     desc: '이국적 풍치의 이탈리아 투스카니 스타일 클럽하우스와 대저택 컨셉의 최고급 호텔 '
    //           '시설로 휴양과 메이저급 골프코스의 다이나믹을 함께 즐길 수 있는 '
    //           '태안반도에 위치한 휴양형 고급 골프 리조트입니다.'
    //   );
    //   var newItem = ProductModel(
    //     showIndex:    index,
    //     saleProdId:   titleN.indexOf(title).toString(),
    //     name:         title,
    //     seller:       seller,
    //     repImg:       'assets/samples/banner_0$index.png',
    //     totalAmount:  2000,
    //     remainAmount: 1000,
    //     itemPrice:    '1000',
    //     priceUnit:    'KRW',
    //     status:       '1',
    //     repDetailImg: 'main_00.png',
    //     externUrl:    'detail_00.png',
    //     desc: '이용권 1매 + 무료 증정 NFT Art 1개 (옵션 선택)',
    //     desc2:'주말 4인 기준\n'
    //           '총 36홀 : 1일차 18홀, 2일차 18홀\n'
    //           '2일차 조식 무료\n'
    //           '1일차, 2일차 카트 무료',
    //   );
    //   // add sample options..
    //   for (var i=0; i<3; i++) {
    //     for (var j=0; j<12; j++) {
    //       var pic = 'item_${j > 9 ? j : '0$j'}.png';
    //       var newOpt = ProductItemModel(
    //         itemId:     Uuid().v4(),
    //         img:        pic,
    //         name:       title,
    //         issuer:     seller,
    //         itemType:   '1',
    //         address:    'contAddr0000000001',
    //         desc:       'Ticket No.${(i * 12) + j}',
    //         desc2:      '티켓 번호 선택',
    //         tokenId:    '1',
    //         chainId:    'mainnet@rigo',
    //         type:       'ERC721',
    //         totalSupply:'2000',
    //       );
    //       optionData[newOpt.itemId!] = newOpt;
    //       newItem.optionList ??= [];
    //       newItem.optionList!.add(newOpt);
    //     }
    //   }
    //   productData[newItem.saleProdId!] = newItem;
    //   productList.add(newItem);
    // }
  }

  getStartData() async {
    categoryList = [
      CategoryModel(
        tagId: 0,
        value: '전체',
      )
    ];
    try {
      var categoryData = await _apiService.getCategory();
      if (categoryData != null) {
        for (var item in categoryData) {
          var addItem = CategoryModel.fromJson(item);
          categoryList.add(addItem);
        }
      }
    } catch (e) {
      LOG('--> getStartData error : $e');
    }
    LOG('--> getStartData result : ${categoryList.length}');
    return true;
  }

  getProductList({int tagId = 0}) async {
    LOG('--> getProductList : $tagId / $lastId($checkLastId) / $isLastPage / ${categoryList.length}');
    try {
      final jsonData = await _apiService.getProductList(
        tagId: tagId,
        lastId: lastId,
        pageCnt: 3
      );
      if (jsonData != null && LIST_NOT_EMPTY(jsonData['data'])) {
        isLastPage  = BOL(jsonData['isLast']);
        lastId      = INT(jsonData['lastId']);
        for (var item in jsonData['data']) {
          var newItem = ProductModel.fromJson(item);
          var isAdd = true;
          // checking duplicate..
          for (var orgItem in productList) {
            if (orgItem.saleProdId == newItem.saleProdId) {
              var index = productList.indexOf(orgItem);
              var tmp = ProductModel.fromJson(orgItem.toJson());
              newItem.repDetailImg  = tmp.repDetailImg;
              newItem.desc          = tmp.desc;
              newItem.desc2         = tmp.desc2;
              newItem.externUrl     = tmp.externUrl;
              productList[index]    = newItem;
              isAdd = false;
              LOG('--> getProductList update : ${newItem.saleProdId} / ${newItem.tagId}');
              break;
            }
          }
          if (isAdd) {
            LOG('--> getProductList add : ${newItem.saleProdId} / ${newItem.tagId}');
            productList.add(newItem);
          }
        }
      }
      LOG('--> getProductList result : '
          '${productList.length} ==> lastId: $lastId / $isLastPage');
    } catch (e) {
      LOG('--> getProductList error : $e');
    }
    return productList;
  }

  Future<ProductModel?> getProductDetail(ProductModel prod) async {
    try {
      var jsonData = await _apiService.getProductDetail(STR(prod.saleProdId));
      if (jsonData != null) {
        prod.itemType     = STR(jsonData['itemType']);
        prod.desc         = STR(jsonData['desc']);
        prod.desc2        = STR(jsonData['desc2']);
        prod.externUrl    = STR(jsonData['externUrl']);
        prod.repDetailImg = STR(jsonData['repDetailImg']);
        // update option items..
        prod = await getProductImageItemList(prod);
        prod = setProductListItem(prod);
        LOG('--> getProductDetail result : ${prod.toJson()}');
      }
    } catch (e) {
      LOG('--> getProductList error : $e');
    }
    return prod;
  }

  Future<ProductModel> getProductItemList(ProductModel prod) async {
    try {
      var jsonData = await _apiService.getProductItems(STR(prod.saleProdId),
        type: int.parse(STR(prod.itemType)), lastId: INT(prod.itemLastId));
      if (jsonData != null && LIST_NOT_EMPTY(jsonData['data'])) {
        prod.isLastItem     = BOL(jsonData['isLast']);
        prod.itemLastId     = INT(jsonData['lastId'], defaultValue: -99);
        prod.itemCountMax   = INT(jsonData['count']);
        prod.itemList       ??= [];
        for (var item in jsonData['data']) {
          var newItem = ProductItemModel.fromJson(item);
          prod.updateItem(newItem);
        }
        if (prod.itemLastId == -99 && LIST_NOT_EMPTY(prod.itemList)) {
          prod.itemLastId = int.parse(STR(prod.itemList!.last.itemId));
        }
        LOG('--> getProductItemList result [${prod.itemLastId}] : ${prod.toJson()}');
      }
    } catch (e) {
      LOG('--> getProductItemList error : $e');
    }
    return prod;
  }

  Future<ProductModel> getProductImageItemList(ProductModel prod) async {
    try {
      var lastId = INT(prod.itemLastId, defaultValue: -1);
      LOG('--> getProductImageItemList : ${prod.saleProdId} / $lastId');
      var jsonData = await _apiService.getProductImageItems(
        STR(prod.saleProdId), lastId: lastId);
      if (jsonData != null && LIST_NOT_EMPTY(jsonData['data'])) {
        prod.isLastItem     = BOL(jsonData['isLast']);
        prod.itemLastId     = INT(jsonData['lastId']);
        prod.itemList       ??= [];
        for (var item in jsonData['data']) {
          var newItem = ProductItemModel();
          newItem.itemId  = STR(item['imgId']);
          newItem.img     = STR(item['img'  ]);
          prod.updateItem(newItem);
        }
        LOG('--> getProductImageItemList result [${prod.itemLastId}] : ${prod.toJson()}');
      }
    } catch (e) {
      LOG('--> getProductImageItemList error : $e');
    }
    return prod;
  }

  setProductListItem(ProductModel newItem) {
    for (var item in productList) {
      if (item.saleProdId == newItem.saleProdId) {
        var index = productList.indexOf(item);
        productList[index] = ProductModel.fromJson(newItem.toJson());
        return productList[index];
      }
    }
    return null;
  }
}