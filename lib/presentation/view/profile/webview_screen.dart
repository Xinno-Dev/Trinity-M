import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trinity_m_00/common/common_package.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/provider/login_provider.dart';
import '../../../common/const/utils/uihelper.dart';

class WebviewScreen extends ConsumerStatefulWidget {
  const WebviewScreen({super.key,
    required this.url,
    this.title,
  });

  final String? title;
  final String url;

  @override
  ConsumerState<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends ConsumerState<WebviewScreen> {
  final _controller = WebViewController();

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform = AndroidWebView();
    _controller.setBackgroundColor(WHITE);
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onUrlChange: (info) {
          LOG('--> onUrlChange : ${info.url}');
        }
      )
    );
    _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    return prov.isScreenLocked ? lockScreen(context) :
      Scaffold(
      appBar: AppBar(
        title: widget.title != null ? Text(
          widget.title!,
          style: typo18bold,
        ) : null,
        titleSpacing: 0,
        backgroundColor: WHITE,
        surfaceTintColor: WHITE,
      ),
      backgroundColor: WHITE,
      body: Container(
        padding: EdgeInsets.all(15),
        child: WebViewWidget(
          controller: _controller,
          // initialUrl: widget.url,
          // javascriptMode: JavascriptMode.unrestricted,
          // navigationDelegate: (request) async {
          //   Uri uri = Uri.parse(request.url);
          //   String finalUrl = request.url;
          //   if (uri.scheme == 'http' ||
          //       uri.scheme == 'https' ||
          //       uri.scheme == 'about') {
          //     return NavigationDecision.navigate;
          //   }
          //   if (Platform.isAndroid) {
          //     await _convertIntentToAppUrl(finalUrl, channel).then((value) async {
          //       finalUrl = value;
          //     });
          //     try {
          //       await _launchURL(url: Uri.parse(finalUrl));
          //     } catch (e) {
          //       finalUrl = await _convertIntentToMarketUrl(request.url, channel);
          //       await _launchURL(url: Uri.parse(finalUrl));
          //     }
          //   } else if (Platform.isIOS) {
          //     _launchURL(url: Uri.parse(finalUrl));
          //   }
          //   return NavigationDecision.prevent;
          // },
          // onWebViewCreated: (WebViewController webViewController) {
          //   _controller.complete(webViewController);
          // },
        ),
      )
    );
  }
}
