import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/domain/viewModel/market_view_model.dart';
import 'package:larba_00/domain/viewModel/profile_view_model.dart';
import 'package:larba_00/presentation/view/main_screen.dart';
import 'package:larba_00/presentation/view/signup/login_screen.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/provider/market_provider.dart';
import '../../../domain/model/address_model.dart';
import '../signup/login_pass_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  ProfileScreen({super.key});
  static String get routeName => 'profileScreen';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late ProfileViewModel _viewModel;
  late MarketViewModel _marketViewModel;

  @override
  void initState() {
    final prov = ref.read(loginProvider);
    final marketProv = ref.read(marketProvider);
    _viewModel = ProfileViewModel(prov);
    _marketViewModel = MarketViewModel(marketProv);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // final loginProv = ref.read(loginProvider);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!loginProv.isLogin) {
    //     Fluttertoast.showToast(msg: TR(context, '로그인이 필요한 서비스입니다.'));
    //     Navigator.of(context).push(
    //       createAniRoute(LoginScreen(isAppStart: false))).then((result) {
    //         LOG('---> LoginScreen result : $result');
    //         if (result == null) {
    //           Future.delayed(Duration(milliseconds: 100)).then((_) {
    //             loginProv.setMainPageIndex(0);
    //           });
    //         }
    //     });
    //   }
    // });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: _viewModel.hideProfileSelectBox,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
               ListView(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  SizedBox(height: 10.h),
                  if (prov.isLogin)...[
                    _viewModel.showProfile(context),
                    _marketViewModel.showStoreProductList(
                        TR(context, 'Market'),
                        isShowSeller: false, isCanBuy: false),
                  ]
                ]
              ),
              if (prov.isShowMask)
                Container(
                  color: Colors.black38,
                )
            ]
          )
        ),
      )
    );
  }
}
