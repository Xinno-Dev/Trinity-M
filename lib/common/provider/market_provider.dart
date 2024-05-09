import 'package:animations/animations.dart';
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
  var optionIndex = 0;

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
    return selectProduct?.optionList?[optionIndex].img;
  }

  get optionDesc {
    return selectProduct?.optionList?[optionIndex].desc;
  }

  get optionDesc2 {
    return selectProduct?.optionList?[optionIndex].desc2;
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

  Future<List<ProductModel>> getProductList() async {
    return await _repo.getProductList(tagId: selectCategory);
  }
}