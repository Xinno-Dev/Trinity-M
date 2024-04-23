import 'dart:math';

import 'package:larba_00/domain/model/product_item_model.dart';
import 'package:larba_00/domain/model/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductRepository {
  Map<String, ProductModel> productData = {};
  Map<String, ProductItemModel> optionData = {};
  List<ProductModel> productList = [];

  var categoryN   = ['전체','골프','F&B','숙박','여행','공연','푸드','기타',];
  var titleN      = ['주말 1박 2일 36홀 (4인) 조식, 숙박, 카트 무료 지원','고메 겟어웨이','제주 봄 미식 프로모션','연박 특가 프로모션','연간 회원권 2024',];
  var sellerN     = ['GoldenBAY Golf & Resort','PARK HYATT Seoul','PARNAS HOTEL JEJU','PARK HYATT Seoul','PARNAS HOTEL JEJU'];
  var sellerSubN  = ['골든베이 골프 & 리조트','파크 하얏트 서울','파르나스 호텔 제주','파크 하얏트 서울','파르나스 호텔 제주'];
  var sellerPicN  = ['0','1','2','1','2'];
  var contentImgN = List.generate(6, (index) => 'banner_0$index.png');

  init() {
    productData = {}; // product cache data..
    optionData  = {}; // product item cache data..
    productList = [];
    // add sample products..
    for (var title in titleN) {
      var index = titleN.indexOf(title);
      var newItem = ProductModel(
        id:           Uuid().v4(),
        productId:    Uuid().v4(),
        title:        title,
        pic:          'main_00.png',
        picThumb:     'banner_0$index.png',
        sellerAddr:   'sellerAddr00000001',
        sellerName:   sellerN[index],
        sellerNameEx: sellerSubN[index],
        sellerPic:    'seller_pic_0${sellerPicN[index]}.png',
        sellerDesc:   '  이국적 풍치의 이탈리아 투스카니 스타일 클럽하우스와 대저택 컨셉의'
            ' 최고급 호텔 시설로 휴양과 메이저급 골프코스의 다이나믹을 함께 즐길 '
            '수 있는 태안반도에 위치한 휴양형 고급 골프 리조트입니다.',
        sellerFollower:  Random().nextInt(999),
        sellerFollowing: Random().nextInt(999),
        amount:       1000,
        amountMax:    2000,
        price:        10000000,
        currency:     '원',
        status:       CD_SALE_ST.sale,
        showIndex:    index,
        externUrl:    'detail_00.png',
        edition:      '2024 주말 1박2일 36홀',
        description:  '이용권 1매 + 무료 증정 NFT Art 1개 (옵션 선택)\n'
                      '주말 4인 기준\n'
                      '총 36홀 : 1일차 18홀, 2일차 18홀\n'
                      '2일차 조식 무료\n'
                      '1일차, 2일차 카트 무료',
      );
      // add sample options..
      for (var i=0; i<3; i++) {
        for (var j=0; j<12; j++) {
          var pic = 'item_${j > 9 ? j : '0$j'}.png';
          var newOpt = ProductItemModel(
            id: Uuid().v4(),
            status: CD_ITEM_ST.live,
            pic: pic,
            picThumb: pic,
            contAddr: 'contAddr0000000001',
            tokenId: 'tokenId000000001',
            ownerAddr: 'ownerAddr0000000001',
            amount: 1,
            index: i * 12 + j,
          );
          optionData[newOpt.id] = newOpt;
          newItem.optionList ??= [];
          newItem.optionList!.add(newOpt);
        }
      }
      productData[newItem.id] = newItem;
      productList.add(newItem);
    }
  }
}