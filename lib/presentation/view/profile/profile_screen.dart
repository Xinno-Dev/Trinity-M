import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/provider/login_provider.dart';

import '../../../common/const/utils/languageHelper.dart';
import '../../../common/provider/market_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  ProfileScreen({super.key});
  static String get routeName => 'profileScreen';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    prov.context = context;
    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                    },
                    icon: SvgPicture.asset('assets/svg/icon_ham.svg'),
                  ),
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: InkWell(
                      onTap: () {
                        prov.showProfileSelectBox();
                      },
                      child: Container(
                        height: kToolbarHeight,
                        color: Colors.transparent,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(TR(context, prov.accountName)),
                            Icon(Icons.arrow_drop_down_sharp),
                          ],
                        )
                      )
                    ),
                  )
                )
              ]
            ),
            centerTitle: true,
            titleSpacing: 0,
            titleTextStyle: typo16bold,
            backgroundColor: Colors.white,
          ),
          backgroundColor: Colors.white,
          body: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [
              prov.showProfile(),
              MarketProvider().showStoreProductList(context, isShowSeller: false, isCanBuy: false),
            ]
          ),
        ),
      )
    );
  }
}
