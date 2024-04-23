import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/provider/market_provider.dart';
import 'package:larba_00/domain/model/product_model.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import 'product_buy_screen.dart';

class ProductStoreScreen extends ConsumerStatefulWidget {
  ProductStoreScreen(this.product, {super.key});
  static String get routeName => 'productStoreScreen';
  final ProductModel product;

  @override
  ConsumerState<ProductStoreScreen> createState() => _ProductStoreScreenState();
}

class _ProductStoreScreenState extends ConsumerState<ProductStoreScreen> {
  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
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
          children: [
            prov.showStoreDetail(widget.product),
            prov.showStoreProductList(widget.product),
          ]
        )
      ),
    );
  }
}
