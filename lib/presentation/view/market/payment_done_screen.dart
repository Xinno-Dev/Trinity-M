import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trinity_m_00/common/provider/login_provider.dart';
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
import '../../../domain/model/purchase_model.dart';
import '../../../domain/viewModel/market_view_model.dart';
import '../../../domain/viewModel/profile_view_model.dart';
import 'product_buy_screen.dart';

class PaymentDoneScreen extends ConsumerStatefulWidget {
  PaymentDoneScreen({super.key});
  static String get routeName => 'paymentDoneScreen';

  @override
  ConsumerState createState() => _PaymentDoneScreenState(false, null);
}

class PaymentDetailScreen extends ConsumerStatefulWidget {
  PaymentDetailScreen({super.key, this.title});
  static String get routeName => 'paymentDetailScreen';
  String? title;

  @override
  ConsumerState createState() => _PaymentDoneScreenState(true, title);
}

class _PaymentDoneScreenState extends ConsumerState {
  _PaymentDoneScreenState(this.isDetailMode, this.title);
  late MarketViewModel _viewModel;
  bool isDetailMode;
  String? title;

  @override
  void initState() {
    _viewModel = MarketViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    final loginProv = ref.watch(loginProvider);
    var info = prov.purchaseInfo;
    return loginProv.isScreenLocked ? lockScreen(context) :
      SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title ?? TR(context, '구매 완료')),
            centerTitle: true,
            titleTextStyle: typo16bold,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: isDetailMode,
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
              _viewModel.showPurchaseResult(),
              Divider(height: 50),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(TR(context, '결제 금액'), style: typo16bold),
                    Spacer(),
                    Text(STR(info?.payText), style: typo16bold),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(TR(context, '상품 금액'), style: typo14medium),
                    Spacer(),
                    Text(STR(info?.priceText), style: typo14medium),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Row(
                  children: [
                    Text(TR(context, '거래 일시'), style: typo14medium),
                    Spacer(),
                    Text(SERVER_TIME_STR(info?.txDateTime), style: typo14medium),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(TR(context, '결제 수단'), style: typo14bold),
                    Spacer(),
                    Text(TR(context, '신용카드 결제'), style: typo14bold),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Row(
                  children: [
                    Text(TR(context, STR(info?.cardType)), style: typo14medium),
                    Spacer(),
                    Text(TR(context, STR(info?.cardNum)), style: typo14medium),
                  ],
                ),
              ),
              if (!isDetailMode)
                PrimaryButton(
                  onTap: () {
                    Navigator.of(context).push(createAniRoute(PaymentListScreen()));
                  },
                  text: TR(context, '구매 내역'),
                  isBorderShow: true,
                  color: WHITE,
                  textStyle: typo16semibold
                ),
            ]
          ),
        bottomNavigationBar: !isDetailMode ? PrimaryButton(
          text: TR(context, '확인'),
          round: 0,
          onTap: () {
            loginProv.enableLockScreen();
            context.pushReplacementNamed(MainScreen.routeName);
          },
        ) : null,
      ),
    );
  }
}
