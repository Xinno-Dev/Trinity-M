import 'dart:convert';
import 'dart:math';

import 'package:trinity_m_00/common/const/utils/userHelper.dart';
import 'package:trinity_m_00/common/provider/login_provider.dart';
import 'package:trinity_m_00/domain/model/purchase_model.dart';

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
  Map<String, SellerModel> sellerData = {};
  List<ProductModel>  productList = [];
  List<ProductModel>  userProductList = [];
  List<CategoryModel> categoryList = [];
  List<PurchaseModel> purchaseList = [];  // 구매 목록 (구매완료, 취소)
  Map<String, List<ProductItemModel>> userItemData = {};  // 구매한 아이템 목록

  var titleN      = ['주말 1박 2일 36홀 (4인) 조식, 숙박, 카트 무료 지원','고메 겟어웨이','제주 봄 미식 프로모션','연박 특가 프로모션','연간 회원권 2024',];
  var sellerN     = ['GoldenBAY Golf & Resort','PARK HYATT Seoul','PARNAS HOTEL JEJU','PARK HYATT Seoul','PARNAS HOTEL JEJU'];
  var sellerSubN  = ['골든베이 골프 & 리조트','파크 하얏트 서울','파르나스 호텔 제주','파크 하얏트 서울','파르나스 호텔 제주'];
  var sellerPicN  = ['0','1','2','1','2'];
  var contentImgN = List.generate(6, (index) => 'banner_0$index.png');

  var pageCount = 0;
  var lastId = -1;
  var checkLastId = -2;
  var checkDetailId = '';
  var checkUserAddr = '';
  var isLastPage = false;

  init() {
    productData = {}; // product cache data..
    optionData  = {}; // product item cache data..
    productList = [];
    userItemData = {};
    userProductList = [];
    purchaseList = [];

    pageCount = 0;
    lastId = -1;
    checkLastId = -2;
    checkDetailId = '';
    checkUserAddr = '';
    isLastPage = false;

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
    //     prodSaleId:   titleN.indexOf(title).toString(),
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
    //   productData[newItem.prodSaleId!] = newItem;
    //   productList.add(newItem);
    // }
  }

  getProductFromData(String itemId) {
    for (var p in productList) {
      for (var item in p.itemList ?? []) {
        if (item.itemId == itemId) {
          return p;
        }
      }
    }
    return null;
  }

  getProductImgFromData(String itemId) {
    ProductModel? p = getProductFromData(itemId);
    return p?.repImg ?? p?.repDetailImg ?? p?.itemImg;
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
    LOG('--> getProductList : $tagId / '
        '$lastId($checkLastId) / $isLastPage / ${categoryList.length}');
    try {
      final jsonData = await _apiService.getProductList(
        tagId: tagId,
        lastId: lastId,
      );
      if (jsonData != null && LIST_NOT_EMPTY(jsonData['data'])) {
        isLastPage  = BOL(jsonData['isLast']);
        lastId      = INT(jsonData['lastId']);
        for (var item in jsonData['data']) {
          var newItem = ProductModel.fromJson(item);
          var isAdd = true;
          // checking duplicate..
          for (var orgItem in productList) {
            if (orgItem.prodSaleId == newItem.prodSaleId) {
              var index = productList.indexOf(orgItem);
              var tmp = ProductModel.fromJson(orgItem.toJson());
              newItem.repDetailImg = tmp.repDetailImg;
              newItem.desc = tmp.desc;
              newItem.desc2 = tmp.desc2;
              newItem.externUrl = tmp.externUrl;
              productList[index] = newItem;
              isAdd = false;
              // LOG('--> getProductList update : ${newItem
              //     .prodSaleId} / ${newItem.tagId}');
              break;
            }
          }
          if (isAdd) {
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


  getUserProductList(String ownerAddr) async {
    LOG('--> getUserProductList : $ownerAddr');
    checkUserAddr = ownerAddr;
    userProductList.clear();
    try {
      final jsonData = await _apiService.getProductList(
        ownerAddr: ownerAddr,
      );
      if (jsonData != null && LIST_NOT_EMPTY(jsonData['data'])) {
        for (var item in jsonData['data']) {
          var newItem = ProductModel.fromJson(item);
          var isAdd = true;
          LOG('--> getUserProductList add : ${newItem.prodSaleId}');
          for (var orgItem in userProductList) {
            if (orgItem.prodSaleId == newItem.prodSaleId) {
              isAdd = false;
              break;
            }
          }
          if (isAdd) {
            userProductList.add(newItem);
          }
        }
      }
      LOG('--> getUserProductList result : '
          '${userProductList.length} ==> lastId: $lastId / $isLastPage');
    } catch (e) {
      LOG('--> getUserProductList error : $e');
    }
    return userProductList;
  }

  Future<ProductModel?> getProductDetail(ProductModel prod) async {
    try {
      var jsonData = await _apiService.getProductDetail(STR(prod.prodSaleId));
      if (jsonData != null) {
        prod.itemType     = STR(jsonData['itemType']);
        prod.desc         = STR(jsonData['desc']);
        prod.desc2        = STR(jsonData['desc2']);
        prod.externUrl    = STR(jsonData['externUrl']);
        prod.repDetailImg = STR(jsonData['repDetailImg']);
        prod.totalAmount  = INT(jsonData['totalAmount']);
        prod.remainAmount = INT(jsonData['remainAmount']);
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

  Future<ProductModel?> getProductDetailFromId(String prodSaleId) async {
    var prod = ProductModel();
    try {
      var result = await _apiService.getProductDetail(prodSaleId);
      if (result != null) {
        prod = ProductModel.fromJson(result);
        // reset option item refresh..
        prod.isLastItem = null;
        prod.itemLastId = null;
        // update option items..
        prod = await getProductImageItemList(prod);
        prod = setProductListItem(prod);
        LOG('--> getProductDetailFromId result : ${prod.toJson()}');
      }
    } catch (e) {
      LOG('--> getProductDetailFromId error : $e');
    }
    return prod;
  }

  Future<ProductModel> getProductItemList(ProductModel prod) async {
    try {
      var jsonData = await _apiService.getProductItems(STR(prod.prodSaleId),
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
        LOG('--> getProductItemList result [${prod.itemLastId}] :'
          ' ${prod.toJson()}');
      }
    } catch (e) {
      LOG('--> getProductItemList error : $e');
    }
    return prod;
  }

  Future<ProductModel> getProductImageItemList(ProductModel prod) async {
    if (BOL(prod.isLastItem)) {
      return prod;
    }
    try {
      var lastId = INT(prod.itemLastId, defaultValue: -1);
      LOG('--> getProductImageItemList : '
          '${prod.prodSaleId} / ${prod.itemLastId} => $lastId');
      var jsonData = await _apiService.getProductImageItems(
        STR(prod.prodSaleId), lastId: lastId);
      if (jsonData != null && LIST_NOT_EMPTY(jsonData['data'])) {
        prod.isLastItem = BOL(jsonData['isLast']);
        prod.itemLastId = INT(jsonData['lastId']);
        prod.itemList   ??= [];
        for (var item in jsonData['data']) {
          var newItem = ProductItemModel.fromJson(item);
          prod.updateItem(newItem);
        }
        LOG('--> getProductImageItemList result [${prod.itemLastId}] :'
          ' ${prod.toJson()}');
      }
    } catch (e) {
      LOG('--> getProductImageItemList error : $e');
    }
    return prod;
  }

  Future<List<PurchaseModel>> getPurchaseList(
    address, {String? startDate, String? endDate}) async {
    LOG('--> getPurchaseList : $startDate ~ $endDate');
    purchaseList.clear();
    var info = await _apiService.getPurchasesList(address, startDate, endDate);
    if (info != null) {
      var data = info['data'];
      for (var item in data) {
        var newItem = PurchaseModel.fromJson(item);
        var isAdd = true;
        for (var orgItem in purchaseList) {
          if (orgItem.purchaseId == newItem.purchaseId) {
            isAdd = false;
            purchaseList[purchaseList.indexOf(orgItem)] = newItem;
            break;
          }
        }
        if (isAdd) {
          purchaseList.add(newItem);
        }
      }
    }
    return purchaseList;
  }

  Future<List<ProductItemModel>> getUserItemList(String ownerAddr) async {
    var jsonData = await _apiService.getUserItemList(ownerAddr);
    if (jsonData != null) {
      var data = jsonData['data'];
      var userItemList = userItemData[ownerAddr] ?? [];
      for (var item in data) {
        var newItem = ProductItemModel.fromJson(item);
        var isAdd = true;
        for (var orgItem in userItemList) {
          if (orgItem.itemId == newItem.itemId) {
            isAdd = false;
            userItemList[userItemList.indexOf(orgItem)] = newItem;
            break;
          }
        }
        if (isAdd) {
          userItemList.add(newItem);
        }
      }
      userItemData[ownerAddr] = userItemList;
      return userItemList;
    }
    return [];
  }

  setProductListItem(ProductModel newItem) {
    for (var item in productList) {
      if (item.prodSaleId == newItem.prodSaleId) {
        var index = productList.indexOf(item);
        productList[index] = ProductModel.fromJson(newItem.toJson());
        return productList[index];
      }
    }
    return null;
  }

  Future<PurchaseModel?> requestPurchase(
    String  prodSaleId,
    String? itemId,
    String? imgId,
    {Function(String)? onError}) async {
    if (STR(prodSaleId).isNotEmpty) {
      var payData = await _apiService.requestPurchase(
          prodSaleId, itemId, imgId);
      if (payData != null) {
        if (payData['err'] != null) {
          if (onError != null) onError(STR(payData['err']['code']));
          return null;
        }
        var result = PurchaseModel.fromJson(payData);
        result.itemId = itemId ?? imgId;
        return result;
      }
    }
    return null;
  }

  Future<JSON?> checkPurchase(String purchaseId) async {
    return await _apiService.checkPurchase(purchaseId);
  }

  Future<SellerModel?> getSellerInfo(String address) async {
    if (sellerData.containsKey(address)) {
      return sellerData[address];
    }
    var result = await _apiService.getSellerInfo(address);
    if (result != null) {
      var seller = SellerModel.fromJson(result);
      seller.updateTime = DateTime.now();
      sellerData[address] = seller;
      return seller;
    }
    return null;
  }

  setSellerInfo(String address, {
    String? nickId,
    String? subTitle,
    String? pfImg,
  }) {
    if (sellerData.containsKey(address)) {
      if (nickId   != null) sellerData[address]!.nickId   = nickId;
      if (subTitle != null) sellerData[address]!.subTitle = subTitle;
      if (pfImg    != null) sellerData[address]!.pfImg    = pfImg;
      return sellerData[address];
    }
    return null;
  }
}