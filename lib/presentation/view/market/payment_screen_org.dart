import 'dart:convert';
import 'dart:io';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trinity_m_00/common/const/utils/uihelper.dart';
import 'package:trinity_m_00/common/provider/market_provider.dart';
import 'package:trinity_m_00/presentation/view/market/payment_done_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/common_package.dart';
import '../../../common/const/cd_enum_const.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../domain/model/purchase_model.dart';

class PaymentScreenOrg extends ConsumerStatefulWidget {
  PaymentScreenOrg(this.data);
  PurchaseModel data;
  static String get routeName => 'paymentScreen';

  @override
  ConsumerState<PaymentScreenOrg> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreenOrg> {
  final _controller = WebViewController();
  final _channel = MethodChannel('com.xinno.trinity_m_00.android');
  final _host = IS_DEV_MODE ? CP_HOST_DEV : CP_HOST;
  final _appUrl = [
    'vbv.shinhancard.com',
    'vbv.samsungcard.co.kr',
    'ansimclick.hyundaicard.com',
  ];

  late final _url = '${_host}/Ready.php';

  get _bodyData {
    var cur = getCurrencyType(widget.data.priceUnit);
    return Uint8List.fromList(cp949.encode(
        'amount=${widget.data.buyPrice}&'
        'orderid=${widget.data.merchantUid}&'
        'itemname=${widget.data.name}&'
        'username=${widget.data.buyerName}&'
        'useremail=${widget.data.buyerEmail}&'
        'userid=${widget.data.buyerId}&'
        'useragent=WM&currency=${cur.code}')
    );
    // return Uint8List.fromList(utf8.encode(jsonEncode({
    //   // 'amount=${widget.data.buyPrice}&'
    //     'amount': 100,
    //     'orderid': widget.data.merchantUid,
    //     'itemname': widget.data.name,
    //     'username': widget.data.buyerName,
    //     'useremail': widget.data.buyerEmail,
    //     'userid': widget.data.buyerId,
    //     'useragent': 'WM',
    //     'currency': cur.code}
    // )));

  }

  @override
  void initState() {
    super.initState();
    LOG('--> widget.data [$_url] : ${widget.data.toJson()}');
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setBackgroundColor(WHITE);
    _controller.clearCache();
    _controller.clearLocalStorage();
    _controller.addJavaScriptChannel(
        "callApp",
        onMessageReceived: (message) {
          LOG('--> onMessageReceived : ${message.message}');
          if (message.message.startsWith('pg_success')) {
            var resultArr = message.message.split('/');
            var result = {
              'status': 'paid',
              'imp_uid': resultArr[1],
              'merchant_uid': resultArr[2],
              'amount': resultArr[3],
              'discount': resultArr[4],
            };
            LOG('--> callApp result : ${result.toString()}');
            _paymentSuccess(result);
          } else {
            // _showFailMessage(message.message);
          }
        }
    );
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) async {
          Uri uri = Uri.parse(request.url);
          String finalUrl = request.url;
          LOG('--> onNavigationRequest : $finalUrl');
          if (uri.scheme.startsWith('intent')) {
            if (!request.isMainFrame) {
              LOG('--> request.isMainFrame : fail');
            }
            _startLaunchUrl(finalUrl);
            return NavigationDecision.prevent;
          } else if (finalUrl.contains('Cancel.php')) {
            LOG('--> cancel : $finalUrl');
            _showCancelMessage();
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (url) {
          LOG('--> onPageStarted : $url');
        },
        onHttpAuthRequest: (request) {
          LOG('--> onHttpAuthRequest : ${request.host}');
        },
        onWebResourceError: (err) async {
          LOG('--> onWebResourceError : ${err.description} / ${err.url}');
          // if (err.url != null && err.url!.startsWith('intent')) {
          //   // _controller.loadHtmlString(
          //   // '<html>'
          //   // '<body><h1 style="text-align:center">Waiting...</h1></body>'
          //   // '</html>');
          //   _startLaunchUrl(err.url);
          // }
        },
        onPageFinished: (url) {
          LOG('--> onPageFinished : ${url}');
        },
        onUrlChange: (url) {
          LOG('--> onUrlChange : ${url.url}');
        }
      )
    );
    _controller.loadRequest(
      Uri.parse(_url),
      method: LoadRequestMethod.post,
      body: _bodyData
    );
  }

  _startLaunchUrl(String? url) async {
    LOG('--> _startLaunchUrl : $url');
    var finalUrl = '';
    if (url != null) {
      if (Platform.isAndroid) {
        try {
          finalUrl = await _convertIntentToAppUrl(url);
          await _launchUrl(finalUrl);
        } catch (e) {
          LOG('--> _startLaunchUrl error : $e');
          finalUrl = await _convertIntentToMarketUrl(url);
          await _launchUrl(finalUrl);
        }
      } else if (Platform.isIOS) {
        await _launchUrl(finalUrl);
      }
    }
    return finalUrl;
  }

  _launchUrl(String url) async {
    launchUrlString(url);
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    return Scaffold(
      appBar: defaultAppBar('결제하기'),
      backgroundColor: WHITE,
      body: WebViewWidget(
        controller: _controller,
      )
    );
  }

  _paymentSuccess(result) {
    showLoadingDialog(context, TR('결제 확인중입니다.'));
    final prov = ref.read(marketProvider);
    prov.checkCount = 0;
    prov.checkPurchase(result).then((checkResult) {
      LOG('--> checkResult : $checkResult');
      hideLoadingDialog();
      if (checkResult) {
        _showDoneMessage();
      } else {
        _showFailMessage();
      }
    });
  }

  _showDoneMessage() {
    showToast(TR('결제에 성공했습니다.'));
    context.pushReplacementNamed(PaymentDoneScreen.routeName);
  }

  _showCancelMessage() {
    showToast(TR('결제를 취소했습니다.'));
    context.pop();
  }

  _showFailMessage([String? msg]) {
    showToast(TR('결제에 실패했습니다!' + (STR(msg).isNotEmpty ? '\n${STR(msg)}' : '')));
    context.pop();
  }

  Future<String> _convertIntentToAppUrl(String url) async {
    return await await _channel.invokeMethod('getAppUrl',  <String, Object>{'url': url});
  }

  Future<String> _convertIntentToMarketUrl(String url) async {
    return await _channel.invokeMethod('getMarketUrl',  <String, Object>{'url': url});
  }
}