import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trinity_m_00/common/provider/login_provider.dart';
import 'package:trinity_m_00/presentation/view/main_screen.dart';
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
import '../../../domain/viewModel/profile_view_model.dart';
import 'product_buy_screen.dart';

class PaymentListScreen extends ConsumerStatefulWidget {
  PaymentListScreen({super.key});
  static String get routeName => 'paymentListScreen';

  @override
  ConsumerState<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends ConsumerState<PaymentListScreen> {
  late MarketViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MarketViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    ref.watch(marketProvider);
    return prov.isScreenLocked ? ProfileViewModel().lockScreen(context) :
      SafeArea(
      top: false,
      child: Scaffold(
        appBar: defaultAppBar(TR(context, '구매 내역')),
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            children: [
              _viewModel.showPurchaseList(
                padding: EdgeInsets.symmetric(vertical: 40)),
              _viewModel.showPurchaseDate(),
            ]
          ),
        ),
      ),
    );
  }
}
