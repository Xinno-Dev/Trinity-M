import 'package:flutter/material.dart';
import 'package:iamport_flutter/iamport_payment.dart';
import 'package:iamport_flutter/model/payment_data.dart';
import 'package:trinity_m_00/common/const/utils/uihelper.dart';
import 'package:trinity_m_00/common/const/widget/dialog_utils.dart';
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

  _showFailMessage() {
    showToast(TR('결제에 실패했습니다.'));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    return IamportPayment(
      appBar: defaultAppBar(TR('결제하기'),
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
              Text(TR('잠시만 기다려주세요...'), style: typo18semibold),
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
            showLoadingDialog(context, TR('결제 검증중입니다.'));
            prov.checkCount = 0;
            prov.checkPurchase(result).then((checkResult) {
              LOG('--> checkResult : $checkResult');
              hideLoadingDialog();
              if (checkResult) {
                showToast(TR('결제에 성공했습니다.'));
                context.pushReplacementNamed(PaymentDoneScreen.routeName);
              } else {
                _showFailMessage();
              }
            });
          } else {
            prov.updatePurchaseInfo(result);
            context.pushReplacementNamed(PaymentDoneScreen.routeName);
          }
        } else {
          _showFailMessage();
        }
      },
    );
  }
}