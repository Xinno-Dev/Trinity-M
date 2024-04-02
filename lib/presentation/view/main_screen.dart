import 'dart:developer';

import 'package:larba_00/common/provider/coin_provider.dart';
import 'package:larba_00/common/provider/temp_provider.dart';
import 'package:larba_00/domain/model/coin_model.dart';
import 'package:larba_00/presentation/view/settings/settings_screen.dart';
import 'package:larba_00/presentation/view/staking/staking_main_screen.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart' as provider;

import '../../common/common_package.dart';
import '../../common/const/utils/languageHelper.dart';
import 'asset/asset_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key, this.selectedPage = 0}) : super(key: key);
  static String get routeName => 'mainScreen';
  final int selectedPage;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _selectedIndex = widget.selectedPage;
  CoinModel? currentCoin;

  List<Widget> _widgetOptions = <Widget>[
    AssetScreen(),
    // StakingMainScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    // if (index == 1 && !currentCoin!.isRigo) {
    //   _showStakingDisableDialog();
    //   return;
    // }
    setState(() {
      _selectedIndex = index;
    });
  }

  _showDialog() async {
    if (isRecoverLogin) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleCheckDialog(
              hasTitle: true,
              titleString: TR(context, '계정이 여러개 있으신가요?'),
              infoString: TR(context, '복구용 문구에 여러 계정이'
                  '\n연결 되어도, 최초로 생성한 계정만'
                  '\n복구됩니다.'
                  '\n\n계정이 한개 이상이실 경우,'
                  '\n계정 추가하기 메뉴를 통해 직접 계정을'
                  '\n추가하여 나머지 계정을 복구해주세요.'),
              defaultButtonText: '확인');
        },
      );
      isRecoverLogin = false;
    }
  }

  _showStakingDisableDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleCheckDialog(
            infoString: TR(context, 'RIGO 코인에서만 사용가능합니다'),
            defaultButtonText: '확인');
      },
    );
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showDialog();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius bottomNavigationBarBorderRadius = BorderRadius.vertical(
      top: Radius.circular(16.0),
    );
    currentCoin = ref.watch(coinProvider).currentCoin;

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
          child: ClipRRect(
            borderRadius: bottomNavigationBarBorderRadius,
            child: BottomNavigationBar(
              backgroundColor: WHITE,
              selectedItemColor: GRAY_90,
              selectedLabelStyle: typo10medium100,
              unselectedLabelStyle: typo10medium100.copyWith(color: GRAY_40),
              items: [
                BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/svg/bnb_asset_off.svg'),
                    activeIcon:
                        SvgPicture.asset('assets/svg/bnb_asset_active.svg'),
                    label: TR(context, '자산')),
                // BottomNavigationBarItem(
                //     icon: SvgPicture.asset('assets/svg/bnb_staking_off.svg'),
                //     activeIcon:
                //         SvgPicture.asset('assets/svg/bnb_staking_active.svg'),
                //     label: TR(context, '스테이킹')),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset('assets/svg/bnb_setting_off.svg'),
                    activeIcon:
                        SvgPicture.asset('assets/svg/bnb_setting_active.svg'),
                    label: TR(context, '설정')),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ),
      )
    );
  }
}
