import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/style/colors.dart';
import '../../../domain/model/purchase_model.dart';

class PaymentDanalScreen extends StatefulWidget {
  PaymentDanalScreen(this.data, {Key? key});
  PurchaseModel data;

  @override
  _DanalPaymentScreenState createState() => _DanalPaymentScreenState();
}

class _DanalPaymentScreenState extends State<PaymentDanalScreen> {
  final String danalPaymentUrl = "https://pay.danal.co.kr/webapp/pay_mobile.jsp?";
  final String merchantId     = "9810030929";
  final String amount         = "100";
  final String orderNumber    = "your_order_number";
  final String productName    = "your_product_name";
  final String customerName   = "your_customer_name";
  final String customerEmail  = "your_customer_email";
  final String customerPhone  = "your_customer_phone";
  final String returnUrl      = "http://13.209.81.51/purchases/danal/vf";

  final _controller = WebViewController();

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    _controller.setBackgroundColor(WHITE);
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onUrlChange: (info) {
          LOG('--> onUrlChange : ${info.url}');
        }
      )
    );
    LOG('--> generateDanalPaymentUrl() : ${generateDanalPaymentUrl()}');
    _controller.loadRequest(Uri.parse(generateDanalPaymentUrl()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danal 결제'),
      ),
      body: WebViewWidget(
        controller: _controller,
        // initialUrl: generateDanalPaymentUrl(),
        // javascriptMode: JavascriptMode.unrestricted,
        // onWebViewCreated: (WebViewController webViewController) {
        //   _webViewController = webViewController;
        // },
        // navigationDelegate: (NavigationRequest request) {
        //   if (request.url.startsWith(returnUrl)) {
        //     // 결제 완료 후 리턴 URL 처리 로직 추가
        //     return NavigationDecision.prevent;
        //   }
        //   return NavigationDecision.navigate;
        // },
      ),
    );
  }

  String generateDanalPaymentUrl() {
    return "$danalPaymentUrl"
        "mid=$merchantId&"
        "price=$amount&"
        "oid=$orderNumber&"
        "goodname=$productName&"
        "buyername=$customerName&"
        "buyeremail=$customerEmail&"
        "buyertel=$customerPhone&"
        "returnUrl=$returnUrl";
  }
}
