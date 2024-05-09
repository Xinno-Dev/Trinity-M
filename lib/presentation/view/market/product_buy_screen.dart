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
import '../../../domain/viewModel/market_view_model.dart';
import 'payment_screen.dart';
import 'pg/payment_test.dart';

class ProductBuyScreen extends ConsumerStatefulWidget {
  ProductBuyScreen({super.key});
  static String get routeName => 'productBuyScreen';

  @override
  ConsumerState<ProductBuyScreen> createState() => _ProductBuyScreenState();
}

class _ProductBuyScreenState extends ConsumerState<ProductBuyScreen> {
  final controller  = ScrollController();
  late MarketViewModel _viewModel;
  var selectTab = 0;

  @override
  void initState() {
    final prov = ref.read(marketProvider);
    _viewModel = MarketViewModel(prov);
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(TR(context, '구매하기')),
          centerTitle: true,
          titleTextStyle: typo16bold,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: context.pop,
            icon: Icon(Icons.close),
          ),
        ),
        backgroundColor: Colors.white,
        body: ListView(
          shrinkWrap: true,
          children: [
            _viewModel.showBuyBox(),
          ]
        ),
        bottomNavigationBar: IS_DEV_MODE
            ? PrimaryButton(
          text: TR(context, '결제하기'),
          round: 0,
          onTap: () {
            Navigator.of(context).push(createAniRoute(PaymentTest()));
          },
        ) : DisabledButton(
          text: TR(context, '결제하기'),
        )
      ),
    );
  }
}
