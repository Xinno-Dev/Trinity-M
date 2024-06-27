import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trinity_m_00/common/const/utils/uihelper.dart';
import 'package:trinity_m_00/common/const/utils/userHelper.dart';
import 'package:trinity_m_00/services/api_service.dart';

import '../../../../common/common_package.dart';
import '../../../../common/const/constants.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../domain/viewModel/profile_view_model.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../services/iamport_service.dart';

class ProfileIdentityScreen extends ConsumerStatefulWidget {
  ProfileIdentityScreen({super.key});
  static String get routeName => 'profileScreen';

  @override
  ConsumerState<ProfileIdentityScreen> createState() => _ProfileIdentityScreenState();
}

class _ProfileIdentityScreenState extends ConsumerState<ProfileIdentityScreen> {
  late ProfileViewModel _viewModel;

  @override
  void initState() {
    _viewModel = ProfileViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    LOG('--> ProfileIdentityScreen');
    return Container();
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
  }

  _identitySuccess() {
    showToast(TR('본인인증 성공'));
    context.pop(true);
  }

  _identityFail() {
    showToast(TR('본인인증 실패'));
    context.pop();
  }

  _identityAlreadyFail() {
    showToast(TR('이미 본인인증을 완료했습니다.'));
    context.pop();
  }
}
