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
    _viewModel = ProfileViewModel();
    _marketViewModel = MarketViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    return prov.isScreenLocked ? prov.lockScreen(context) :
      SafeArea(
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
                      _marketViewModel.showUserProductList(
                        TR(context, 'Market'),
                        prov.accountAddress,
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
