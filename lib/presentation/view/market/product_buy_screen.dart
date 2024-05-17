import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trinity_m_00/common/provider/login_provider.dart';
import 'package:trinity_m_00/presentation/view/market/payment_done_screen.dart';
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

  @override
  void initState() {
    _viewModel = MarketViewModel();
    final prov = ref.read(marketProvider);
    prov.optionIndex = -1;
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
        body: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  _viewModel.showBuyBox(),
                ]
              ),
            ),
            if (!prov.purchaseReady)
              Padding(padding: EdgeInsets.all(10),
              child: Text(TR(context, '* 옵션을 선택해 주세요.'),
                style: typo12bold.copyWith(color: Colors.red))),
          ],
        ),
        bottomNavigationBar: prov.purchaseReady ?
          PrimaryButton(
            text: TR(context, '결제하기'),
            round: 0,
            onTap: () {
              prov.createPurchaseInfo();
              var data = prov.createPurchaseData(
                userInfo: ref.read(loginProvider).userInfo!);
              if (data != null) {
                Navigator.of(context).push(
                  createAniRoute(PaymentScreen(PORTONE_IMP_CODE, data)));
              }
            },
          ) : DisabledButton(
            text: TR(context, '결제하기'),
          )
      ),
    );
  }
}
