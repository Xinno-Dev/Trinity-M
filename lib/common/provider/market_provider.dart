import 'package:animations/animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iamport_flutter/model/payment_data.dart';
import 'package:intl/intl.dart';
import 'package:trinity_m_00/domain/model/user_model.dart';
import 'package:uuid/uuid.dart';

import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../domain/model/product_model.dart';
import '../../../../domain/repository/market_repository.dart';
import '../../../../presentation/view/market/seller_detail_screen.dart';
import '../../../../services/api_service.dart';

import '../../domain/model/category_model.dart';
import '../../domain/model/product_item_model.dart';
import '../../domain/model/purchase_model.dart';
import '../../presentation/view/market/product_detail_screen.dart';
import '../common_package.dart';
import '../const/constants.dart';
import '../const/utils/languageHelper.dart';
import '../const/utils/uihelper.dart';

final marketProvider = ChangeNotifierProvider<MarketProvider>((_) {
  return MarketProvider();
});

class MarketProvider extends ChangeNotifier {
  static final _singleton = MarketProvider._internal();
  static final _repo = MarketRepository();

  factory MarketProvider() {
    _repo.init();
    _singleton.purchaseStartDate = DateTime.now().subtract(Duration(days: 10));
    _singleton.purchaseEndDate = DateTime.now();
    return _singleton;
  }

  MarketProvider._internal();

  ProductModel? selectProduct;
  PurchaseModel? purchaseInfo;
  PurchaseModel? selectPurchaseItem;

  List<ProductModel> showList = [];
  List<PurchaseModel> purchaseList = [];

  late DateTime purchaseStartDate;
  late DateTime purchaseEndDate;
  late PaymentData payData;

  var selectCategory = 0;
  var selectDetailTab = 0;
  var optionIndex = -1;
  var isStartDataDone = false;

  get marketRepo {
    return _repo;
  }

  get marketList {
    showList.clear();
    for (var item in _repo.productList) {
      if (selectCategory == 0 || item.tagId == selectCategory) {
        var newItem = ProductModel.fromJson(item.toJson());
        showList.add(newItem);
      }
    }
    LOG('---> marketList : $selectCategory / ${_repo.productList.length}');
    return showList;
  }

  get hasOption {
    return INT(selectProduct?.itemList?.length) > 0;
  }

  get purchaseReady {
    return !hasOption || optionIndex >= 0;
  }

  checkLastProduct(String? saleProdId) {
    if (showList.isEmpty || STR(saleProdId).isEmpty) return true;
    var result = STR(showList.last.saleProdId) == saleProdId;
    return result;
  }

  get detailPic {
    return selectProduct?.repDetailImg;
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

  getProductList() async {
    if (_repo.isLastPage) {
      return false;
    }
    await _repo.getProductList();
    notifyListeners();
    return true;
  }

  getProductDetail() async {
    if (_repo.checkDetailId != STR(selectProduct?.saleProdId)) {
      _repo.checkDetailId = STR(selectProduct?.saleProdId);
      selectProduct = await _repo.getProductDetail(selectProduct!);
    }
    return selectProduct ?? [];
  }

  getPurchaseProductInfo() async {
      return await _repo.getProductDetailFromId(STR(selectPurchaseItem!.saleProdId));
  }

  getProductOptionList() async {
    if (BOL(selectProduct?.isLastItem)) {
      return false;
    }
    selectProduct = await _repo.getProductImageItemList(selectProduct!);
    notifyListeners();
    return true;
  }

  refreshProductList(BuildContext context, String? prodId) async {
    if (((selectCategory == 0 && prodId == _repo.lastId.toString()) ||
        checkLastProduct(prodId)) && prodId != _repo.checkLastId.toString()) {
      LOG('-------> update product list!! : $prodId');
      _repo.checkLastId = int.parse(STR(prodId));
      if (!await getProductList()) {
        Fluttertoast.showToast(msg: TR(context, '상품 목록 마지막입니다.'),
            toastLength: Toast.LENGTH_SHORT);
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
        Fluttertoast.showToast(msg: TR(context, '옵션 목록 마지막입니다.'),
            toastLength: Toast.LENGTH_SHORT);
        return true;
      }
    }
    return false;
  }

  createPurchaseInfo() {
    if (selectProduct != null) {
      purchaseInfo = PurchaseModel(
        purchaseId: Uuid().v4(),
        saleProdId: selectProduct!.saleProdId,
        itemType:   selectProduct!.itemType,
        name:       selectProduct!.name,
        itemId:     optionId,
        itemImg:    optionPic,
        buyPrice:   selectProduct!.itemPrice,
        priceUnit:  selectProduct!.priceUnit,
        txDateTime: DateTime.now().toString(),
        payType:    '1',
        // for test..
        payPrice:   '1000',
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
      var name    = STR(purchaseInfo?.name);
      var amount  = num.parse(STR(purchaseInfo?.buyPrice));
      var uId     = STR(purchaseInfo?.purchaseId);
      LOG('--> createPurchaseData : $name / $amount / $uId');
      payData = PaymentData(
        pg: PAYMENT_PG,
        payMethod: payMethod,
        escrow: false,
        name: name,
        amount: amount,
        merchantUid: uId,
        buyerName:  userInfo.userName,
        buyerEmail: userInfo.email,
        buyerTel:   STR(userInfo.mobile),
        appScheme: 'flutterexample',
        niceMobileV2: true,
      );
      // 할부개월 설정..
      if (payMethod == 'card' && cardQuota != '0') {
        payData.cardQuota = [];
        if (cardQuota != '1') {
          payData.cardQuota!.add(int.parse(cardQuota));
        }
      }
      // [이니시스-빌링.나이스.다날] 제공기간 표기
      payData.period = {
        'from': '20240101',
        'to': '20241231',
      };
      payData.popup = false;
      return payData;
    }
    return null;
  }

  updatePurchaseInfo(JSON result) {
    if (purchaseInfo != null) {
      purchaseInfo!.cardType  = STR(result['card_name']);
      purchaseInfo!.cardNum   = STR(result['card_number']);
      purchaseInfo!.payPrice  = STR(result['paid_amount']);
      purchaseInfo!.priceUnit = STR(result['currency']);
      purchaseList.add(purchaseInfo!);
    }
    return purchaseInfo;
  }
}