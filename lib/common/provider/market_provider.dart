import 'package:fluttertoast/fluttertoast.dart';
import 'package:iamport_flutter/model/payment_data.dart';
import 'package:intl/intl.dart';
import 'package:trinity_m_00/common/const/utils/userHelper.dart';
import 'package:trinity_m_00/domain/model/user_model.dart';
import 'package:trinity_m_00/domain/viewModel/market_view_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../domain/model/product_model.dart';
import '../../../../domain/repository/market_repository.dart';
import '../../presentation/view/profile/profile_target_screen.dart';
import '../../../../services/api_service.dart';

import '../../domain/model/category_model.dart';
import '../../domain/model/product_item_model.dart';
import '../../domain/model/purchase_model.dart';
import '../../presentation/view/market/product_detail_screen.dart';
import '../common_package.dart';
import '../const/constants.dart';
import '../const/utils/languageHelper.dart';
import '../const/utils/uihelper.dart';

var isPadMode = false;

final marketProvider = ChangeNotifierProvider<MarketProvider>((_) {
  return MarketProvider();
});

class MarketProvider extends ChangeNotifier {
  factory MarketProvider() {
    _singleton.purchaseStartDate = DateTime.now().subtract(Duration(days: 10));
    _singleton.purchaseEndDate = DateTime.now();
    return _singleton;
  }
  MarketProvider._internal();
  static final _singleton = MarketProvider._internal();
  static final _repo = MarketRepository();

  ProductModel?  selectProduct;
  PurchaseModel? purchaseInfo;
  PurchaseModel? selectPurchaseItem;
  ProductItemModel? selectUserProductItem;

  List<ProductModel> showList = [];
  List<ProductModel> userShowList = [];

  late DateTime purchaseStartDate;
  late DateTime purchaseEndDate;
  late PaymentData payData;

  var checkCount = 0;
  var selectCategory = 0;
  var selectDetailTab = 0;
  var optionIndex = -1;
  var isStartDataDone = false;
  var userItemShowGrid = false;
  var userItemShowQR = false;
  var isBuying = false;

  initRepo() {
    _repo.init();
  }

  get marketRepo {
    return _repo;
  }

  get marketList {
    showList.clear();
    for (var item in _repo.productList) {
      if (selectCategory == 0 ||
        (item.tagId != null && item.tagId!.contains(selectCategory))) {
        var newItem = ProductModel.fromJson(item.toJson());
        showList.add(newItem);
      }
    }
    // LOG('---> marketList : $selectCategory / ${_repo.productList.length}');
    return showList;
  }

  get userMarketList {
    userShowList.clear();
    for (var item in _repo.userProductList) {
      var newItem = ProductModel.fromJson(item.toJson());
      userShowList.add(newItem);
    }
    // LOG('---> userMarketList : $selectCategory / ${_repo.productList.length}');
    return userShowList;
  }

  get hasOption {
    return INT(selectProduct?.itemList?.length) > 0;
  }

  get canOptionSelect {
    return INT(selectProduct?.itemList?.length) > 1;
  }

  get catShowExternalPic {
    return STR(externalPic).isNotEmpty;
  }

  get isShowDetailTab {
    return canOptionSelect || catShowExternalPic;
  }

  get purchaseReady {
    return !canOptionSelect || optionIndex >= 0;
  }

  checkLastProduct(String? prodSaleId) {
    if (showList.isEmpty || STR(prodSaleId).isEmpty) return true;
    var result = STR(showList.last.prodSaleId) == prodSaleId;
    return result;
  }

  get detailPic {
    return selectProduct?.itemImg ?? selectProduct?.repDetailImg;
  }

  get externalPic {
    return selectProduct?.externUrl;
  }

  ProductItemModel? get optionItem {
    if (optionIndex < 0) return null;
    return selectProduct?.itemList?[optionIndex];
  }

  get optionId {
    return optionItem?.itemId;
  }

  get optionPic {
    return optionItem?.img;
  }

  get optionDesc {
    return optionItem?.desc;
  }

  get optionDesc2 {
    return optionItem?.desc2;
  }

  get isLastPage {
    return _repo.isLastPage;
  }

  get purchaseSearchDate {
    var format   = DateFormat('yyyy-MM-dd');
    var startStr = format.format(purchaseStartDate).toString();
    var endStr   = format.format(purchaseEndDate).toString();
    return '$startStr ~ $endStr';
  }

  refresh() {
    notifyListeners();
  }

  List<CategoryModel> get categoryList {
    return _repo.categoryList;
  }

  List<ProductModel> get productList {
    return _repo.productList;
  }

  setOptionIndex(int index) {
    optionIndex = index;
    notifyListeners();
  }

  setCategory(int index) {
    selectCategory = index;
    notifyListeners();
  }

  Future<bool> getStartData() async {
    return await _repo.getStartData();
  }

  getProductList({String? ownerAddr}) async {
    // LOG('--> getProductList check : $ownerAddr / ${_repo.checkUserAddr}');
    if (STR(ownerAddr).isNotEmpty) {
      if (_repo.checkUserAddr != STR(ownerAddr)) {
        await _repo.getUserProductList(ownerAddr!);
      }
    } else {
      if (_repo.isLastPage) {
        return false;
      }
      await _repo.getProductList();
      notifyListeners();
    }
    return true;
  }

  clearCheckDetailId() {
    _repo.checkDetailId = '';
  }

  getProductDetail() async {
    if (_repo.checkDetailId != STR(selectProduct?.prodSaleId)) {
      _repo.checkDetailId = STR(selectProduct?.prodSaleId);
      selectProduct = await _repo.getProductDetail(selectProduct!);
    }
    return selectProduct;
  }

  getProductDetailFromId(String prodSaleId) async {
    selectProduct = await _repo.getProductDetailFromId(prodSaleId);
    return selectProduct;
  }

  getPurchaseProductInfo() async {
    return await _repo.getProductDetailFromId(STR(selectPurchaseItem!.prodSaleId));
  }

  getProductOptionList() async {
    if (BOL(selectProduct?.isLastItem)) {
      return false;
    }
    selectProduct = await _repo.getProductImageItemList(selectProduct!);
    notifyListeners();
    return true;
  }

  getPurchaseList() async {
    var address   = await UserHelper().get_address();
    var format    = DateFormat('yyyy-MM-dd');
    var startStr  = format.format(purchaseStartDate.toUtc()).toString();
    var endStr    = format.format(purchaseEndDate.toUtc()).toString();
    return await _repo.getPurchaseList(address, startDate: startStr, endDate: endStr);
  }

  getUserItemList(String ownerAddr) async {
    return await _repo.getUserItemList(ownerAddr);
  }

  List<PurchaseModel> get purchaseList {
    return _repo.purchaseList;
  }

  List<ProductItemModel> userItemList(String ownerAddr) {
    return _repo.userItemData[ownerAddr] ?? [];
  }

  refreshProductList(BuildContext context, String? prodId) async {
    if (((selectCategory == 0 && prodId == _repo.lastId.toString()) ||
        checkLastProduct(prodId)) && prodId != _repo.checkLastId.toString()) {
      LOG('-------> update product list!! : $prodId');
      _repo.checkLastId = int.parse(STR(prodId, defaultValue: '0'));
      if (!await getProductList()) {
        showToast(TR('상품 목록 마지막입니다.'));
        return false;
      }
    }
    return true;
  }

  refreshProductItemList(BuildContext context, String? itemId) async {
    if (itemId == INT(selectProduct?.itemLastId).toString() &&
        itemId != INT(selectProduct?.itemCheckId).toString()) {
      LOG('-------> update product item list!! : $itemId');
      selectProduct?.itemCheckId = int.parse(STR(itemId));
      if (!await getProductOptionList()) {
        showToast(TR('옵션 목록 마지막입니다.'));
        return true;
      }
    }
    return false;
  }

  createPurchaseInfo() {
    if (selectProduct != null) {
      purchaseInfo = PurchaseModel(
        purchaseId: Uuid().v4(),
        prodSaleId: selectProduct!.prodSaleId,
        itemType:   selectProduct!.itemType,
        name:       selectProduct!.name,
        itemId:     optionId,
        itemImg:    optionPic,
        buyPrice:   '100',
        // buyPrice:   selectProduct!.itemPrice,
        priceUnit:  selectProduct!.priceUnit,
        txDateTime: DateTime.now().toString(),
        payType:    '1',
        // for test..
        payPrice:   '',
        cardType:   'TEST CARD',
        cardNum:    '1234-****-****-5678',
        seller:     selectProduct!.seller,
      );
    }
  }

  createPurchaseData(
    {
      required UserModel userInfo,
      String payMethod = 'card', // 결제수단
      String cardQuota = '0', // 할부개월수
    } // 구매자 이메일
  ) {
    if (purchaseInfo != null) {
      var name    = P_STR(purchaseInfo?.name);
      var amount  = num.parse(STR(purchaseInfo?.buyPrice));
      payData = PaymentData(
        pg: PAYMENT_PG,
        merchantUid: '', // 추후 기입..
        payMethod: payMethod,
        name: name,
        amount: amount,
        buyerName:  userInfo.userName,
        buyerEmail: userInfo.email,
        buyerTel:   STR(userInfo.mobile),
        appScheme: 'iamport_payment',
        niceMobileV2: true,
        escrow: false,
        popup: false,
        // period: {
        //   'from': '20240101',
        //   'to': '20241231',
        // }
      );
      // 할부개월 설정..
      LOG('--> createPurchaseData : $name / $amount');
      if (payMethod == 'card' && cardQuota != '0') {
        payData.cardQuota = [];
        if (cardQuota != '1') {
          payData.cardQuota!.add(int.parse(cardQuota));
        }
      }
      return payData;
    }
    return null;
  }


  requestPurchaseWithImageId({Function(String)? onError}) async {
    LOG('--> requestPurchaseWithImageId : ${purchaseInfo?.prodSaleId} '
        '/ ${optionId} / $isBuying');
    if (optionId != null) {
      if (isBuying) {
        return false;
      }
      isBuying = true;
      var result = await _repo.requestPurchase(
          STR(purchaseInfo?.prodSaleId), imgId: optionId, onError: (error) {
        if (error == '__not_found__' && onError != null) {
          onError(TR('이미 판매완료된 옵션 상품입니다.'));
        }
      });
      isBuying = false;
      if (result != null) {
        purchaseInfo!.itemId      = result.itemId;
        purchaseInfo!.merchantUid = result.merchantUid;
        purchaseInfo!.buyPrice    = result.price; // price -> payPrice 로 변환
        purchaseInfo!.priceUnit   = result.priceUnit;
        purchaseInfo!.mid         = result.mid;
        payData.merchantUid       = STR(result.merchantUid);
        LOG('--> requestPurchaseWithImageId result : ${payData.merchantUid} '
            '<= ${purchaseInfo?.toJson()}');
        return purchaseInfo;
      }
    }
    return null;
  }

  Future<bool> checkPurchase(JSON info) async {
    LOG('--> checkPurchase : $info / $checkCount');
    if (checkCount++ > 5) return false;
    var impUid      = STR(info['imp_uid'      ]);
    var status      = STR(info['status'       ]);
    var merchantId  = STR(info['merchant_uid' ]);
    await Future.delayed(Duration(seconds: CHECK_PURCHASE_DELAY)); // 딜레이.. 1초..
    var result = await _repo.checkPurchase(impUid, merchantId, status);
    LOG('--> checkPurchase result : ${STR(result?['status'])}');
    if (result != null) {
      var status = STR(result['status']);
      // 결제 완료..
      if (status == '4') {
        return updatePurchaseInfo(info);
        // 결제 검증중..
      } else if (status == '3' || status == '2') {
        return await checkPurchase(info);
      }
    }
    return false;
  }

  updatePurchaseInfo(JSON info) {
    if (purchaseInfo != null) {
      purchaseInfo!.cardType  = STR(info['card_name'  ]);
      purchaseInfo!.cardNum   = STR(info['card_number']);
      purchaseInfo!.payPrice  = STR(info['paid_amount']);
      purchaseInfo!.priceUnit = STR(info['currency'   ]);
      return true;
    }
    return false;
  }
}