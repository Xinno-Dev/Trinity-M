import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:trinity_m_00/common/const/utils/uihelper.dart';
import 'package:trinity_m_00/common/const/utils/userHelper.dart';
import 'package:trinity_m_00/services/api_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../common/common_package.dart';
import '../../../../common/const/constants.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../domain/viewModel/profile_view_model.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/openUrlHelper.dart';
import '../../../services/iamport_service.dart';

class ProfileIdentityScreen extends ConsumerStatefulWidget {
  ProfileIdentityScreen({super.key});
  static String get routeName => 'profileScreen';

  @override
  ConsumerState<ProfileIdentityScreen> createState() => _ProfileIdentityScreenState();
}

class _ProfileIdentityScreenState extends ConsumerState<ProfileIdentityScreen> {
  late ProfileViewModel _viewModel;
  final _host = IS_DEV_MODE ? CP_HOST_DEV : CP_HOST;
  late final _url = '${_host}/cert/ready';

  @override
  void initState() {
    _viewModel = ProfileViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    LOG('--> ProfileIdentityScreen');
    return Scaffold(
      appBar: defaultAppBar('본인인증'),
      backgroundColor: WHITE,
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(_url),
          method: 'POST'
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
            allowContentAccess: true,
            allowFileAccess: true,
            builtInZoomControls: true,
            thirdPartyCookiesEnabled: true,
            supportMultipleWindows: true,
            useHybridComposition: true,
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
            handlerName: 'iden_message', callback: (msg) {
            LOG('--> iden_message : $msg');
            msg.forEach((e) => LOG('--> iden_message value: $e'));
            if (msg.isNotEmpty) {
              var result = msg.first;
              if (result == 'success') {
                var tid = msg[1];
                _identitySuccess(tid);
              } else if (result == 'error') {
                var error = msg.length > 1 ? msg[1] : null;
                _identityFail(error);
              } else if (result == 'cancel') {
                _identityCancel();
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
    var _openUrl = OpenUrl(uriString);
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
      _identityCancel();
      return NavigationActionPolicy.CANCEL;
    }
    var _openUrl = OpenUrl(uriString);
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

  // return IamportCertification(
  //   appBar: defaultAppBar(TR('본인 인증')),
  //   /* 웹뷰 로딩 컴포넌트 */
  //   initialChild: Container(
  //     child: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           // Image.asset('assets/images/iamport-logo.png'),
  //           // Padding(padding: EdgeInsets.symmetric(vertical: 15)),
  //           Text(TR('잠시만 기다려주세요...'), style: TextStyle(fontSize: 20)),
  //         ],
  //       ),
  //     ),
  //   ),
  //   /* [필수입력] 가맹점 식별코드 */
  //   userCode: PORTONE_IMP_CODE,
  //   /* [필수입력] 본인인증 데이터 */
  //   data: CertificationData(
  //     pg: IDENTITY_PG, // PG사
  //     merchantUid: STR(prov.userEmail), // 주문번호
  //     mRedirectUrl: '', // 본인인증 후 이동할 URL
  //     // name: '김주현',
  //     // phone: '010-2656-2896',
  //     // carrier: '19740911',
  //   ),
  //   /* [필수입력] 콜백 함수 */
  //   callback: (Map<String, String> result) {
  //     LOG('--> IamportCertification result : $result');
  //     if (BOL(result['success']) && STR(result['imp_uid']).isNotEmpty) {
  //       var uid = STR(result['imp_uid']);
  //       ApiService().setIdentity(uid, onError: (code) {
  //         _identityAlreadyFail();
  //       }).then((result2) {
  //         LOG('--> checkCert result : $result2');
  //         if (result2 == true) {
  //           _identitySuccess();
  //         } else if (result2 == false) {
  //           _identityFail();
  //         }
  //       });
  //     } else {
  //       _identityFail();
  //     }
  //   },
  // );

  _identitySuccess(String? tId) {
    if (STR(tId).isNotEmpty) {
      // ApiService().setIdentity(tId!, onError: (code) {
      //   _identityAlreadyFail();
      // }).then((result2) {
      //   LOG('--> checkCert result : $result2');
      //   if (result2 == true) {
          showToast(TR('본인인증 성공'));
          context.pop(true);
      //   } else if (result2 == false) {
      //     _identityFail();
      //   }
      // });
    } else {
      _identityFail();
    }
  }

  _identityFail([String? msg ]) {
    showToast(TR('본인인증 실패') + ((STR(msg).isNotEmpty ? '\n${STR(msg)}' : '')));
    context.pop();
  }

  _identityCancel() {
    showToast(TR('본인인증 취소'));
    context.pop();
  }

  _identityAlreadyFail() {
    showToast(TR('이미 본인인증을 완료했습니다.'));
    context.pop();
  }
}
