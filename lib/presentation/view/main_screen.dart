import 'dart:developer';

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
    AssetScreen(),
    // SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius bottomNavigationBarBorderRadius = BorderRadius.vertical(
      top: Radius.circular(16.0),
    );
    return SafeArea(
        top: false,
        child: Scaffold(
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              borderRadius: bottomNavigationBarBorderRadius,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(179, 181, 189, 0.15),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: WHITE,
              selectedItemColor: PRIMARY_100,
              unselectedItemColor: GRAY_60,
              selectedLabelStyle: typo16bold,
              unselectedLabelStyle: typo16bold,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 0),
                  label: TR(context, 'Market')
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 0),
                  label: TR(context, 'Assets')
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        )
    );
  }
}
