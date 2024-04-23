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
import '../../common/const/utils/languageHelper.dart';
import 'asset/asset_screen.dart';
import 'market/market_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key, this.selectedPage = 0}) : super(key: key);
  static String get routeName => 'mainScreen';
  final int selectedPage;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _selectedIndex = widget.selectedPage;

  List<Widget> _widgetOptions = <Widget>[
    MarketScreen(),
    ProfileScreen(),
    // SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomAppBar(
          height: 55.h,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  },
                  child: Center(
                    child: Text(TR(context, 'Market'),
                      style: _selectedIndex == 0 ?
                      typo16bold.copyWith(color: PRIMARY_100) : typo16regular),
                  ),
                )
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedIndex = 1);
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  },
                  child: Center(
                    child: SvgPicture.asset('assets/svg/'
                      'icon_profile_0${_selectedIndex == 1 ? '1' : '0'}.svg'),
                  ),
                ),
              ),
            ]
          )
        )
      )
    );
  }
}
