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
import '../../../common/const/utils/userHelper.dart';
import '../../../common/provider/market_provider.dart';
import '../../../common/const/utils/uihelper.dart';
import '../signup/login_pass_screen.dart';
import '../signup/signup_bio_screen.dart';
import '../signup/signup_mnemonic_screen.dart';
import 'profile_Identity_screen.dart';

class ProfileMyInfoScreen extends ConsumerStatefulWidget {
  ProfileMyInfoScreen({super.key});
  static String get routeName => 'profileMyInfoScreen';

  @override
  ConsumerState<ProfileMyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends ConsumerState<ProfileMyInfoScreen> {
  late ProfileViewModel _viewModel;
  late MarketViewModel _marketViewModel;

  @override
  void initState() {
    _viewModel = ProfileViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    _viewModel.context = context;
    return prov.isScreenLocked ? lockScreen(context) :
      Scaffold(
        appBar: defaultAppBar(TR('내 정보')),
        body: Scaffold(
          backgroundColor: Colors.white,
          body: ListView(
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
                [[TR(prov.userIdentityYN ? '인증 완료' : '인증 미완료'),
                  prov.userIdentityYN ? '' : '인증']], onEdit: () {
                    Navigator.of(context).push(
                      createAniRoute(ProfileIdentityScreen())).then((result) {
                      prov.userInfo!.certUpdt = DateTime.now().toString();
                      prov.refresh();
                    });
                }),
              grayDivider(),
              _viewModel.myInfoEditItem('계정',
                [[TR('계정 복구 단어 보기'),'보기']], onEdit: _showMnemonic),
              grayDivider(),
              _viewModel.myInfoEditItem('인증',
                [[TR('생체 인증 사용'), prov.userBioYN ? 'on' : 'off']], onToggle: _showBioIdentity),
              if (IS_WITHDRAWAL_ON)...[
                grayDivider(),
                _viewModel.myInfoEditItem('회원 탈퇴', [[TR('회원 탈퇴 신청'), '신청']], onEdit: () {
                  if (prov.isLogin) {
                    prov.logout().then((_) {
                      context.pop();
                      prov.setMainPageIndex(0);
                      showToast(TR('회원 탈퇴 신청 완료'));
                    });
                  }
                })
              ],
              if (IS_APP_RESET_ON)...[
                grayDivider(),
                _viewModel.myInfoEditItem('앱 초기화', [[TR('로그아웃 & 앱 초기화'), '초기화']], onEdit: () {
                  if (prov.isLogin) {
                    _clearLocalData();
                  }
                })
              ]
            ]
          ),
      )
    );
  }

  _showMnemonic() {
    final prov = ref.read(loginProvider);
    Navigator.of(context).push(
      createAniRoute(LoginPassScreen())).then((passOrg) {
        LOG('--> _showMnemonic : $passOrg');
      if (STR(passOrg).isNotEmpty) {
        prov.setUserPass(passOrg);
        Navigator.of(context).push(
          createAniRoute(SignUpMnemonicScreen(isShowNext: false))).
          then((result) {
            prov.refresh();
          });
      }
    });
  }

  _showBioIdentity(value) {
    final prov = ref.read(loginProvider);
    if (value) {
      Navigator.of(context).push(
        createAniRoute(LoginPassScreen())).then((passOrg) {
        if (STR(passOrg).isNotEmpty) {
          prov.setUserPass(passOrg);
          prov.disableLockScreen();
          Navigator.of(context).push(
            createAniRoute(SignUpBioScreen(isShowNext: false)))
            .then((result) {
              LOG('--> SignUpBioScreen result : $result');
              if (BOL(result)) {
                prov.setUserBioIdentity(true);
              }
              prov.enableLockScreen();
          });
        }
      });
    } else {
      prov.setUserBioIdentity(false);
    }
  }

  _clearLocalData() {
    final prov = ref.read(loginProvider);
    Navigator.of(context).push(
      createAniRoute(LoginPassScreen())).then((passOrg) {
      LOG('--> _showMnemonic : $passOrg');
      if (STR(passOrg).isNotEmpty) {
        prov.setUserPass(passOrg);
        UserHelper().clearAllUser().then((_) {
          prov.logout().then((_) {
            context.pop();
            prov.setMainPageIndex(0);
            showToast(TR('앱 초기화 완료'));
          });
        });
      }
    });
  }
}
