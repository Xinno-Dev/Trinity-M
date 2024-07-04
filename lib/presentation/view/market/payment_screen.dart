import 'dart:convert';
import 'dart:io';

import 'package:cp949_codec/cp949_codec.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_store/open_store.dart';
import 'package:trinity_m_00/common/const/utils/uihelper.dart';
import 'package:trinity_m_00/common/provider/market_provider.dart';
import 'package:trinity_m_00/presentation/view/market/payment_done_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../common/common_package.dart';
import '../../../common/const/cd_enum_const.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/openUrlHelper.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../domain/model/purchase_model.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  PaymentScreen(this.data);
  PurchaseModel data;
  static String get routeName => 'paymentScreen';

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _channel = MethodChannel('com.xinno.trinity_m_00.android');
  final _host = IS_DEV_MODE ? CP_HOST_DEV : CP_HOST;
  late final _url = '${_host}/card/ready';
  late OpenUrl _openUrl;

  get _bodyData {
    LOG('--> widget.data : ${widget.data.itemType} / ${widget.data.itemId}');
    var cur = getCurrencyType(widget.data.priceUnit);
    return Uint8List.fromList(utf8.encode(
      'purchaseId=${widget.data.purchaseId}&'
      'type=${IS_PAYMENT_ON ? widget.data.itemType : '99'}&'
      'imgId=${widget.data.itemId}&'
      'itemName=${P_STR(widget.data.name)}&'
      'orderId=${widget.data.merchantUid}&'
      'userName=${P_STR(widget.data.buyerName)}&'
      'userId=${P_STR(widget.data.buyerId)}&'
      'userEmail=${widget.data.buyerEmail}&'
      'currency=${cur.code}&'
      'amount=100&'
      'userAgent=WM'
    ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar('결제하기'),
      backgroundColor: WHITE,
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(_url),
          method: 'POST',
          body: _bodyData,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
            // 'Content-Type': 'application/json',
          },
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptCanOpenWindowsAutomatically: true,
            javaScriptEnabled: true,
            useShouldOverrideUrlLoading: true,
            useOnDownloadStart: true,
            useOnLoadResource: true,
            mediaPlaybackRequiresUserGesture: true,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            verticalScrollBarEnabled: true,
          ),
          android: AndroidInAppWebViewOptions(
            useHybridComposition: true,
            allowContentAccess: true,
            builtInZoomControls: true,
            thirdPartyCookiesEnabled: true,
            allowFileAccess: true,
            supportMultipleWindows: true,
            useShouldInterceptRequest: true,
          ),
          ios: IOSInAppWebViewOptions(
            allowsInlineMediaPlayback: true,
            allowsBackForwardNavigationGestures: true,
          ),
        ),
        onConsoleMessage: (controller, msg) {
          LOG('--> onConsoleMessage : ${msg.message}');
        },
        onLoadResourceCustomScheme: (controller, url) async {
          LOG('--> onLoadResourceCustomScheme : $url');
          await controller.stopLoading();
          return null;
        },
        onWebViewCreated: (controller) {
          LOG('--------> onWebViewCreated : $_url');
          controller.addJavaScriptHandler(
            handlerName: 'pg_message', callback: (msg) {
              LOG('--> pg_message : $msg');
              msg.forEach((e) => LOG('-- $e'));
              if (msg.isNotEmpty) {
                var result = msg.first;
                if (result == 'success') {
                  _paymentSuccess(widget.data.purchaseId);
                } else if (result == 'error') {
                  var error = msg.length > 1 ? msg[1] : null;
                  _showFailMessage(error);
                } else if (result == 'cancel') {
                  _showCancelMessage();
                }
              }
          });
        },
        onCreateWindow: _onCreateWindow,
        shouldOverrideUrlLoading: _shouldOverrideUrlLoading
      )
    );
  }

  Future<bool> _onCreateWindow(
      InAppWebViewController controller, CreateWindowAction action) async {
    var uri = action.request.url;
    LOG('--> _onCreateWindow : $uri');
    if (uri == null) {
      return false;
    }
    final uriString = uri.toString();
    _openUrl = OpenUrl(uriString);
    if (!_openUrl.isAppLink()) {
      return true;
    } else {
      launchUrlString(uriString);
      return false;
    }
  }

  Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
      InAppWebViewController controller,
      NavigationAction navigationAction) async {
    var uri = navigationAction.request.url;
    LOG('--> _shouldOverrideUrlLoading : $uri');
    if (uri == null) {
      return NavigationActionPolicy.CANCEL;
    }
    final uriString = uri.toString();
    if (uriString.contains('Cancel.php')) {
      LOG('--> cancel : $uriString');
      _showCancelMessage();
      return NavigationActionPolicy.CANCEL;
    }
    _openUrl = OpenUrl(uriString);
    if (!_openUrl.isAppLink()) {
      return NavigationActionPolicy.ALLOW;
    }
    if (Platform.isAndroid) {
      if (!navigationAction.isForMainFrame) {
        await controller.stopLoading();
      }
    }
    await _openUrl.launchApp();
    return NavigationActionPolicy.CANCEL;
  }

  // Future<NavigationActionPolicy> _shouldOverrideUrlLoading(
  //     InAppWebViewController controller,
  //     NavigationAction navigationAction) async {
  //   var uri = navigationAction.request.url;
  //   LOG('--> _shouldOverrideUrlLoading : $uri');
  //   if (STR(uri).isEmpty) {
  //     // controller.goBack();
  //     return NavigationActionPolicy.CANCEL;
  //   }
  //   final uriString = uri.toString();
  //   if (uriString.contains('Cancel.php')) {
  //     LOG('--> cancel : $uriString');
  //     _showCancelMessage();
  //     return NavigationActionPolicy.CANCEL;
  //   }
  //   if (['http', 'https', 'about', 'data'].any(uriString.startsWith)) {
  //     LOG('--> skip..');
  //     return NavigationActionPolicy.ALLOW;
  //   } else {
  //     // controller.goBack();
  //     if (Platform.isAndroid) {
  //       if (!navigationAction.isForMainFrame) {
  //         await controller.stopLoading();
  //       }
  //     }
  //     LOG('--> launchUrlString : $uriString');
  //     _startLaunchUrl(uriString);
  //     return NavigationActionPolicy.CANCEL;
  //   }
  // }
  //
  // _startLaunchUrl(String? url) async {
  //   LOG('--> _startLaunchUrl : $url');
  //   if (url != null) {
  //     if (Platform.isAndroid) {
  //       try {
  //         var finalUrl = await _convertIntentToAppUrl(url);
  //         LOG('--> _startLaunchUrl open app : $finalUrl');
  //         await launchUrlString(finalUrl);
  //       } catch (e) {
  //         var finalUrl = await _convertIntentToMarketUrl(url);
  //         LOG('--> _startLaunchUrl market : $finalUrl');
  //         await launchUrlString(finalUrl);
  //       }
  //     } else if (Platform.isIOS) {
  //       if (await canLaunchUrlString(url)) {
  //         await launchUrlString(url);
  //       } else {
  //         var appStoreId = _convertIntentToAppId(url);
  //         LOG('--> _startLaunchUrl ios market : $appStoreId');
  //         await OpenStore.instance.open(
  //           appStoreId: appStoreId
  //         );
  //       }
  //     }
  //   }
  // }

  _paymentSuccess(purchaseId) {
    showLoadingDialog(context, TR('결제 확인중입니다.'));
    final prov = ref.read(marketProvider);
    prov.checkCount = 0;
    prov.checkPurchase(purchaseId).then((checkResult) {
      LOG('--> _paymentSuccess result : $checkResult');
      hideLoadingDialog();
      if (checkResult) {
        _showDoneMessage();
      } else {
        _showFailMessage();
      }
    });
  }

  _showDoneMessage([var goNext = true]) {
    showToast(TR('결제에 성공했습니다.'));
    if (goNext) {
      context.pushReplacementNamed(PaymentDoneScreen.routeName);
    } else {
      context.pop();
    }
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

  String _convertIntentToAppId(String url) {
    return url.split('tid=').last;
  }
}