import 'package:animations/animations.dart';
import 'package:larba_00/common/const/utils/convertHelper.dart';
import 'package:larba_00/common/const/widget/primary_button.dart';
import 'package:larba_00/domain/model/product_model.dart';
import 'package:larba_00/domain/repository/market_repository.dart';
import 'package:larba_00/presentation/view/market/product_store_screen.dart';
import 'package:larba_00/services/api_service.dart';

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
  static final _marketRepo = MarketRepository();

  factory MarketProvider() {
    _marketRepo.init();
    return _singleton;
  }
  MarketProvider._internal();

  ProductModel? selectProduct;

  var selectCategory = 0;
  var selectDetail = 0;
  var optionIndex = 0;

  get marketRepo {
    return _marketRepo;
  }

  get detailPic {
    return selectProduct?.optionList?[optionIndex].img;
  }

  List<String> get categoryList {
    return _marketRepo.categoryN;
  }

  List<ProductModel> get productList {
    return _marketRepo.productList;
  }

  setOptionIndex(int index) {
    optionIndex = index;
    notifyListeners();
  }

  setCategory(int index) {
    selectCategory = index;
    notifyListeners();
  }

}