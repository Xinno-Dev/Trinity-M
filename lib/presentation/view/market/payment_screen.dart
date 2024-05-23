import 'package:flutter/material.dart';
import 'package:iamport_flutter/iamport_payment.dart';
import 'package:iamport_flutter/model/payment_data.dart';
import 'package:trinity_m_00/common/const/utils/uihelper.dart';
import 'package:trinity_m_00/common/provider/market_provider.dart';
import 'package:trinity_m_00/presentation/view/market/payment_done_screen.dart';
import 'package:trinity_m_00/presentation/view/market/product_detail_screen.dart';
import '../../../common/common_package.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  PaymentScreen(this.userCode, this.data);
  String userCode;
  PaymentData data;
  static String get routeName => 'paymentScreen';

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final controller  = ScrollController();

  _showFailMessage(BuildContext context) {
    showToast(TR(context, '결제에 실패했습니다.'));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    return IamportPayment(
      appBar: AppBar(
        title: Text('결제하기'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          color: Colors.white,
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: context.pop,
        ),
      ),
      initialChild: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showLoadingFull(60),
              SizedBox(height: 40),
              Text(TR(context, '잠시만 기다려주세요...'), style: typo18semibold),
            ],
          ),
        ),
      ),
      userCode: widget.userCode,
      data: widget.data,
      callback: (Map<String, String> result) {
        LOG('--> show payment result : $result');
        if (BOL(result['success'])) {
          if (IS_PAYMENT_ON) {
            prov.checkPurchase(result).then((checkResult) {
              LOG('--> checkResult : $checkResult');
              if (checkResult) {
                showToast(TR(context, '결제에 성공했습니다.'));
                context.pushReplacementNamed(PaymentDoneScreen.routeName);
              } else {
                _showFailMessage(context);
              }
            });
          } else {
            prov.updatePurchaseInfo(result);
            context.pushReplacementNamed(PaymentDoneScreen.routeName);
          }
        } else {
          _showFailMessage(context);
        }
      },
    );
  }
}