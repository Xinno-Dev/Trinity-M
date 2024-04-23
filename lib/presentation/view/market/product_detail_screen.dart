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

class ProductDetailScreen extends ConsumerStatefulWidget {
  ProductDetailScreen({super.key});
  static String get routeName => 'productDetailScreen';

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(TR(context, '상품 정보')),
          centerTitle: true,
          titleTextStyle: typo16bold,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: ListView(
          shrinkWrap: true,
          children: [
            prov.showProductDetail(),
            prov.showProductInfo(),
          ]
        ),
        bottomNavigationBar: IS_DEV_MODE ?
        OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration: Duration(milliseconds: 400),
          closedBuilder: (context, builder) {
            return PrimaryButton(
              text: TR(context, '구매하기'),
              round: 0,
            );
          },
          openBuilder: (context, builder) {
            return ProductBuyScreen();
          },
        ) : DisabledButton(
          text: TR(context, '구매하기'),
        )
      ),
    );
  }
}
