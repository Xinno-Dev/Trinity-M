import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iamport_flutter/iamport_certification.dart';
import 'package:iamport_flutter/model/certification_data.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/domain/viewModel/profile_view_model.dart';

import '../../../common/const/utils/convertHelper.dart';

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
    final prov = ref.read(loginProvider);
    _viewModel = ProfileViewModel(prov);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    LOG('--> ProfileIdentityScreen');
    return IamportCertification(
      appBar: new AppBar(
        title: new Text('본인인증'),
      ),
      /* 웹뷰 로딩 컴포넌트 */
      initialChild: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset('assets/images/iamport-logo.png'),
              // Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
      /* [필수입력] 가맹점 식별코드 */
      userCode: 'iamport',
      /* [필수입력] 본인인증 데이터 */
      data: CertificationData(
        pg: IDENTITY_PG, // PG사
        merchantUid: 'mid_${DateTime.now().millisecondsSinceEpoch}',  // 주문번호
        mRedirectUrl: 'https://example.com',                          // 본인인증 후 이동할 URL
        // name: '김주현',
        // phone: '010-2656-2896',
        // carrier: '19740911',
      ),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) {
        LOG('--> IamportCertification result : $result');
        // Navigator.pushReplacementNamed(
        //   context,
        //   '/result',
        //   arguments: result,
        // );
      },
    );
  }
}
