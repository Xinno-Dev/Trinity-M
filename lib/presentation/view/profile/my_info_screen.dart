import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../common/common_package.dart';
import '../../../../common/const/constants.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../domain/viewModel/market_view_model.dart';
import '../../../../domain/viewModel/profile_view_model.dart';
import '../../../../presentation/view/main_screen.dart';
import '../../../../presentation/view/signup/login_screen.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/provider/market_provider.dart';
import '../../../domain/model/address_model.dart';
import '../signup/login_pass_screen.dart';
import '../signup/signup_bio_screen.dart';
import '../signup/signup_mnemonic_screen.dart';
import 'profile_Identity_screen.dart';

class MyInfoScreen extends ConsumerStatefulWidget {
  MyInfoScreen({super.key});
  static String get routeName => 'myInfoScreen';

  @override
  ConsumerState<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends ConsumerState<MyInfoScreen> {
  late ProfileViewModel _viewModel;
  late MarketViewModel _marketViewModel;

  @override
  void initState() {
    _viewModel = ProfileViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    _viewModel.context = context;
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: defaultAppBar(TR(context, '내 정보')),
        body: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 30),
                children: [
                  SizedBox(height: 10.h),
                  _viewModel.myInfoEditItem('이메일',
                    [[prov.userEmail,'']]),
                  grayDivider(),
                  _viewModel.myInfoEditItem('ID(닉네임)',
                    [[prov.userId,'변경']], onEdit: () {
                      _viewModel.showEditAccountName();
                    }),
                  grayDivider(),
                  _viewModel.myInfoEditItem('사용자 이름',
                    [[prov.userName,'변경']], onEdit: () {
                      _viewModel.showEditSubTitle();
                    }),
                  grayDivider(),
                  _viewModel.myInfoEditItem('본인인증',
                    [[prov.userIdentityYN ? '인증완료' : '미완료',
                      prov.userIdentityYN ? '' : '인증']], onEdit: () {
                        Navigator.of(context).push(
                          createAniRoute(ProfileIdentityScreen())).then((result) {
                          prov.userInfo!.identityYN = result;
                          prov.refresh();
                        });
                    }),
                  grayDivider(),
                  _viewModel.myInfoEditItem('계정',
                    [['계정 복구 단어 보기','보기']], onEdit: _showMnemonic),
                  grayDivider(),
                  _viewModel.myInfoEditItem('인증',
                    [['생체 인증 사용', prov.userBioYN ? 'on' : 'off']], onToggle: (value) {
                      if (value) {
                        Navigator.of(context).push(
                          createAniRoute(SignUpBioScreen(isShowNext: false))).then((result) {
                            LOG('--> SignUpBioScreen result : $result');
                            if (BOL(result)) {
                              prov.setBioIdentity(true);
                            }
                        });
                      } else {
                        prov.setBioIdentity(false);
                      }
                    }),
                ]
              ),
            ]
          )
        ),
      )
    );
  }

  _showMnemonic() {
    Navigator.of(context).push(
      createAniRoute(LoginPassScreen())).then((passOrg) {
      if (STR(passOrg).isNotEmpty) {
        final prov = ref.read(loginProvider);
        Navigator.of(context).push(
          createAniRoute(SignUpMnemonicScreen(isShowNext: false))).
          then((result) {
            prov.refresh();
          });
      }
    });
  }
}
