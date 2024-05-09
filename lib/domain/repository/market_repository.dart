import 'dart:math';

import 'package:larba_00/domain/model/product_item_model.dart';
import 'package:larba_00/domain/model/product_model.dart';
import 'package:larba_00/domain/model/seller_model.dart';
import 'package:uuid/uuid.dart';

import '../../common/const/utils/convertHelper.dart';
import '../../services/api_service.dart';

class MarketRepository {
  static final _apiService = ApiService();

  Map<String, ProductModel> productData = {};
  Map<String, ProductItemModel> optionData = {};
  List<ProductModel> productList = [];

  var categoryN   = ['전체','골프','F&B','숙박','여행','공연','푸드','기타',];
  var titleN      = ['주말 1박 2일 36홀 (4인) 조식, 숙박, 카트 무료 지원','고메 겟어웨이','제주 봄 미식 프로모션','연박 특가 프로모션','연간 회원권 2024',];
  var sellerN     = ['GoldenBAY Golf & Resort','PARK HYATT Seoul','PARNAS HOTEL JEJU','PARK HYATT Seoul','PARNAS HOTEL JEJU'];
  var sellerSubN  = ['골든베이 골프 & 리조트','파크 하얏트 서울','파르나스 호텔 제주','파크 하얏트 서울','파르나스 호텔 제주'];
  var sellerPicN  = ['0','1','2','1','2'];
  var contentImgN = List.generate(6, (index) => 'banner_0$index.png');

  var pageCount = 0;
  var lastId = 0;
  var isLastPage = false;

  init() {
    productData = {}; // product cache data..
    optionData  = {}; // product item cache data..
    productList = [];

    // add sample products..
    for (var title in titleN) {
      var index = titleN.indexOf(title);
      var seller = SellerModel(
        address:    'sellerAddr00000001',
        nickId:     sellerN[index],
        subTitle:   sellerSubN[index],
        pfImg:      'seller_pic_0${sellerPicN[index]}.png',
        desc: '이국적 풍치의 이탈리아 투스카니 스타일 클럽하우스와 대저택 컨셉의 최고급 호텔 '
              '시설로 휴양과 메이저급 골프코스의 다이나믹을 함께 즐길 수 있는 '
              '태안반도에 위치한 휴양형 고급 골프 리조트입니다.'
      );
      var newItem = ProductModel(
        prodSaleId:   Uuid().v4(),
        name:         title,
        repImg:       'banner_0$index.png',
        infoImg:      'detail_00.png',
        totalAmount:  '2000',
        remainAmount: '1000',
        itemPrice:    '1000',
        priceUnit:    'KRW',
        status:       '1',
        showIndex:    index,
        seller:       seller,
      );
      // add sample options..
      for (var i=0; i<3; i++) {
        for (var j=0; j<12; j++) {
          var pic = 'item_${j > 9 ? j : '0$j'}.png';
          var newOpt = ProductItemModel(
            itemId:   Uuid().v4(),
            itemType: '1',
            address:  'contAddr0000000001',
            img:  pic,
            name: title,
            desc: '이용권 1매 + 무료 증정 NFT Art 1개 (옵션 선택)\n'
                  '주말 4인 기준\n'
                  '총 36홀 : 1일차 18홀, 2일차 18홀\n'
                  '2일차 조식 무료\n'
                  '1일차, 2일차 카트 무료',
            desc2:      '티켓 이미지 옵션 선택',
            tokenId:    '1',
            chainId:    'mainnet@rigo',
            type:       'ERC721',
            totalSupply:'2000',
            issuer:     seller,
          );
          optionData[newOpt.itemId!] = newOpt;
          newItem.optionList ??= [];
          newItem.optionList!.add(newOpt);
        }
      }
      productData[newItem.prodSaleId!] = newItem;
      productList.add(newItem);
    }
  }

  getProductList() async {
    final result = await _apiService.getProductList();
    if (result?['data'] != null) {
      var data = result!['data'];
      LOG('--> getProductList : $data');
      for (var item in data) {
        var product = ProductModel(

        );
      }
    }
  }
}