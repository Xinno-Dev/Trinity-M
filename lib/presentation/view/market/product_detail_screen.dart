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
import '../../../domain/viewModel/profile_view_model.dart';
import 'product_buy_screen.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  ProductDetailScreen({super.key, this.isShowSeller = true, this.isCanBuy = true});
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
    prov.clearCheckDetailId();
    _viewModel = MarketViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    final loginProv = ref.watch(loginProvider);
    return loginProv.isScreenLocked ?
      ProfileViewModel().lockScreen(context) : SafeArea(
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
                  if (prov.isShowDetailTab)
                    _viewModel.showProductInfoTab(ref),
                ]
              );
            } else {
              return showLoadingFull();
            }
          }
        ),
        bottomNavigationBar:
          (widget.isCanBuy && loginProv.isLogin) ?
          OpenContainer(
            transitionType: ContainerTransitionType.fadeThrough,
            closedBuilder: (context, builder) {
              return PrimaryButton(
                text: TR(context, '구매하기'),
                round: 0,
              );
            },
            openBuilder: (context, builder) {
              return ProductBuyScreen();
            },
          ) : PrimaryButton(
            onTap: () {
              Navigator.of(context).push(
                createAniRoute(LoginScreen(
                isAppStart: false, isWillReturn: true)))
                .then((result) {
                  if (BOL(result)) {
                    prov.refresh();
                    Navigator.of(context).push(
                      createAniRoute(ProductBuyScreen()));
                  }
              });
            },
            text: TR(context, '구매하기'),
            round: 0,
          )
      ),
    );
  }
}
