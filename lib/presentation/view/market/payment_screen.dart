import 'package:flutter/material.dart';
import 'package:iamport_flutter/iamport_payment.dart';
import 'package:iamport_flutter/model/payment_data.dart';
import 'package:larba_00/common/common_package.dart';

import '../../../common/const/utils/convertHelper.dart';

class PaymentScreen extends StatelessWidget {
  PaymentScreen(this.userCode, this.data);
  String userCode;
  PaymentData data;

  @override
  Widget build(BuildContext context) {
    // String userCode = Get.arguments['userCode'] as String;
    // PaymentData data = Get.arguments['data'] as PaymentData;

    return IamportPayment(
      appBar: AppBar(
        title: Text('결제'),
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
              // Image.asset('assets/images/iamport-logo.png'),
              // Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20.0)),
            ],
          ),
        ),
      ),
      userCode: userCode,
      data: data,
      callback: (Map<String, String> result) {
        LOG('--> show payment result : $result');
      },
    );
  }
}