import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../common/common_package.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/provider/market_provider.dart';
import '../../../../domain/model/product_model.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../domain/viewModel/market_view_model.dart';
import 'product_buy_screen.dart';

class SellerDetailScreen extends ConsumerStatefulWidget {
  SellerDetailScreen(this.product, {super.key});
  static String get routeName => 'sellerDetailScreen';
  final ProductModel product;

  @override
  ConsumerState<SellerDetailScreen> createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends ConsumerState<SellerDetailScreen> {
  late MarketViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MarketViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    _viewModel.context = context;
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(TR(context, widget.product.sellerName)),
          centerTitle: true,
          titleTextStyle: typo16bold,
          backgroundColor: Colors.white,
          // automaticallyImplyLeading: false,
          // leading: IconButton(
          //   onPressed: context.pop,
          //   icon: Icon(Icons.close),
          // ),
        ),
        backgroundColor: Colors.white,
        body: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            _viewModel.showStoreDetail(widget.product),
            _viewModel.showStoreProductList(TR(context, 'Market'),
                isShowSeller: false, isCanBuy: true),
          ]
        )
      ),
    );
  }
}
