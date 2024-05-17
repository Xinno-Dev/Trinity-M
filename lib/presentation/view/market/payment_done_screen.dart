import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trinity_m_00/presentation/view/main_screen.dart';
import 'package:trinity_m_00/presentation/view/market/payment_list_screen.dart';
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

class PaymentDoneScreen extends ConsumerStatefulWidget {
  PaymentDoneScreen({super.key});
  static String get routeName => 'paymentDoneScreen';

  @override
  ConsumerState<PaymentDoneScreen> createState() => _PaymentDoneScreenState();
}

class _PaymentDoneScreenState extends ConsumerState<PaymentDoneScreen> {
  late MarketViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MarketViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    var info = prov.purchaseInfo;
    return SafeArea(
      top: false,
      child: Scaffold(
          appBar: AppBar(
            title: Text(TR(context, '구매 완료')),
            centerTitle: true,
            titleTextStyle: typo16bold,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
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
              _viewModel.showPurchaseResult(context),
              Divider(height: 50),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(TR(context, '결제 금액'), style: typo18bold),
                    Spacer(),
                    Text(STR(info?.priceText), style: typo18bold),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(TR(context, '상품 금액'), style: typo16medium),
                    Spacer(),
                    Text(prov.selectProduct!.priceText, style: typo16medium),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Row(
                  children: [
                    Text(TR(context, '거래 일시'), style: typo16medium),
                    Spacer(),
                    Text(STR(info?.txDateTime), style: typo16medium),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(TR(context, '결제 수단'), style: typo18bold),
                    Spacer(),
                    Text(TR(context, '신용카드 결제'), style: typo18bold),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Row(
                  children: [
                    Text(TR(context, STR(info?.cardType)), style: typo16medium),
                    Spacer(),
                    Text(TR(context, STR(info?.cardNum)), style: typo16medium),
                  ],
                ),
              ),
              PrimaryButton(
                onTap: () {
                  Navigator.of(context).push(createAniRoute(PaymentListScreen()));
                },
                text: TR(context, '구매 내역'),
                isBorderShow: true,
                color: WHITE,
                textStyle: typo18semibold
              ),
            ]
          ),
        bottomNavigationBar: PrimaryButton(
          text: TR(context, '확인'),
          round: 0,
          onTap: () {
            context.pushReplacementNamed(MainScreen.routeName);
          },
        ),
      ),
    );
  }
}
