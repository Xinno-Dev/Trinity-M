import 'package:animations/animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:larba_00/common/const/utils/convertHelper.dart';
import 'package:larba_00/common/const/widget/primary_button.dart';
import 'package:larba_00/domain/model/product_model.dart';
import 'package:larba_00/domain/repository/market_repository.dart';
import 'package:larba_00/presentation/view/market/seller_detail_screen.dart';
import 'package:larba_00/services/api_service.dart';

import '../../domain/model/category_model.dart';
import '../../domain/model/product_item_model.dart';
import '../../presentation/view/market/product_detail_screen.dart';
import '../common_package.dart';
import '../const/utils/languageHelper.dart';
import '../const/utils/uihelper.dart';

final marketProvider = ChangeNotifierProvider<MarketProvider>((_) {
  return MarketProvider();
});

class MarketProvider extends ChangeNotifier {
  static final _singleton  = MarketProvider._internal();
  static final _repo = MarketRepository();

  factory MarketProvider() {
    _repo.init();
    return _singleton;
  }
  MarketProvider._internal();

  ProductModel? selectProduct;

  var selectCategory = 0;
  var selectDetailTab = 0;
  var optionIndex = -1;
  var isStartDataDone = false;

  get marketRepo {
    return _repo;
  }

  get detailPic {
    return selectProduct?.repDetailImg;
  }

  get externalPic {
    return selectProduct?.externUrl;
  }

  get optionPic {
    if (optionIndex < 0) return null;
    return selectProduct?.itemList?[optionIndex].img;
  }

  get optionDesc {
    if (optionIndex < 0) return null;
    return selectProduct?.itemList?[optionIndex].desc;
  }

  get optionDesc2 {
    if (optionIndex < 0) return null;
    return selectProduct?.itemList?[optionIndex].desc2;
  }

  get isLastPage {
    return _repo.isLastPage;
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
    await _repo.getProductList(tagId: selectCategory);
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

  getProductOptionList() async {
    if (BOL(selectProduct?.isLastItem)) {
      return false;
    }
    selectProduct = await _repo.getProductImageItemList(selectProduct!);
    notifyListeners();
    return true;
  }

  refreshProductList(BuildContext context, String? prodId) async {
    if (prodId == _repo.lastId.toString() &&
        prodId != _repo.checkLastId.toString()) {
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
}