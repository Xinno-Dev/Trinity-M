import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trinity_m_00/common/provider/login_provider.dart';
import '../../../../common/common_package.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/provider/market_provider.dart';
import '../../../../domain/model/product_model.dart';

import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../domain/model/seller_model.dart';
import '../../../domain/viewModel/market_view_model.dart';
import '../../../domain/viewModel/profile_view_model.dart';
import '../market/product_buy_screen.dart';

class ProfileTargetScreen extends ConsumerStatefulWidget {
  ProfileTargetScreen(this.seller, {super.key});
  static String get routeName => 'profileTargetScreen';
  final SellerModel seller;

  @override
  ConsumerState<ProfileTargetScreen> createState() => _ProfileTargetScreenState();
}

class _ProfileTargetScreenState extends ConsumerState<ProfileTargetScreen> {
  late MarketViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MarketViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    final loginProv = ref.watch(loginProvider);
    return loginProv.isScreenLocked ? lockScreen(context) :
    SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(TR(context, STR(widget.seller.nickId))),
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
            _viewModel.showStoreDetail(widget.seller),
            _viewModel.showUserProductList(
                TR(context, 'Market'),
                STR(widget.seller.address),
                isShowSeller: false, isCanBuy: true),
          ]
        )
      ),
    );
  }
}
