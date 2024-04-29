import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:larba_00/common/provider/coin_provider.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/common/provider/temp_provider.dart';
import 'package:larba_00/domain/model/coin_model.dart';
import 'package:larba_00/presentation/view/settings/settings_screen.dart';
import 'package:larba_00/presentation/view/staking/staking_main_screen.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart' as provider;

import '../../common/common_package.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../common/const/utils/languageHelper.dart';
import 'asset/asset_screen.dart';
import 'market/market_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  MainScreen({Key? key, this.selectedPage = 0}) : super(key: key);
  static String get routeName => 'mainScreen';
  int selectedPage;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final _pageController = PageController();

  List<Widget> _mainPages = <Widget>[
    MarketScreen(),
    ProfileScreen(),
  ];

  _selectPage(index) {
    final prov = ref.read(loginProvider);
    prov.setMainPageIndex(index);
    prov.hideProfileSelectBox(context);
    _pageController.animateToPage(prov.mainPageIndex,
        duration: Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  movePage() {
    final prov = ref.read(loginProvider);
    LOG('---> movePage : ${prov.mainPageIndexOrg} => ${prov.mainPageIndex}');
    if (prov.mainPageIndexOrg != prov.mainPageIndex) {
      prov.mainPageIndexOrg = prov.mainPageIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.animateToPage(prov.mainPageIndex,
            duration: Duration(milliseconds: 200), curve: Curves.easeOut);
      });
    }
  }

  @override
  void initState() {
    ref.read(loginProvider).mainPageIndex = widget.selectedPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    movePage();
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: _selectPage,
              children: _mainPages,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: kToolbarHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft:  Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _selectPage(0);
                        },
                        child: Center(
                          child: Text(TR(context, 'Market'),
                            style: prov.mainPageIndex == 0 ?
                            typo16bold.copyWith(color: PRIMARY_100) : typo16regular),
                        ),
                      )
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _selectPage(1);
                        },
                        child: Center(
                          child: SvgPicture.asset('assets/svg/'
                            'icon_profile_0${prov.mainPageIndex == 1 ? '1' : '0'}.svg'),
                        ),
                      ),
                    ),
                  ]
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
      )
    );
  }
}
