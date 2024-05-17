import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trinity_m_00/common/provider/login_provider.dart';
import 'package:trinity_m_00/presentation/view/signup/login_screen.dart';
import '../../../../common/common_package.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/provider/market_provider.dart';
import '../../../../domain/model/product_model.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../domain/viewModel/market_view_model.dart';
import 'product_buy_screen.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  ProductDetailScreen({super.key, required this.isShowSeller, required this.isCanBuy});
  static String get routeName => 'productDetailScreen';
  final bool isShowSeller;
  final bool isCanBuy;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late MarketViewModel _viewModel;

  @override
  void initState() {
    final prov = ref.read(marketProvider);
    prov.optionIndex = -1;
    prov.selectDetailTab = 0;
    _viewModel = MarketViewModel();
    super.initState();
  }

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
        body: FutureBuilder(
          future: prov.getProductDetail(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                children: [
                  _viewModel.showProductDetail(widget.isShowSeller),
                  _viewModel.showProductInfoTab(ref),
                ]
              );
            } else {
              return showLoadingFull();
            }
          }
        ),
        bottomNavigationBar: widget.isCanBuy ?
        OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          closedBuilder: (context, builder) {
            return PrimaryButton(
              text: TR(context, '구매하기'),
              round: 0,
            );
          },
          openBuilder: (context, builder) {
            if (ref.read(loginProvider).isLogin) {
              return ProductBuyScreen();
            } else {
              return LoginScreen(isAppStart: false);
            }
          },
        ) : DisabledButton(
          text: TR(context, '구매하기'),
        )
      ),
    );
  }
}
