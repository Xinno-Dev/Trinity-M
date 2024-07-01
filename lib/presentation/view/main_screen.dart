
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/provider/login_provider.dart';
import '../../../domain/viewModel/profile_view_model.dart';
import 'package:flutter/scheduler.dart';

import '../../common/common_package.dart';
import '../../common/const/constants.dart';
import '../../common/const/utils/appVersionHelper.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/utils/uihelper.dart';
import '../../common/provider/market_provider.dart';
import '../../domain/model/purchase_model.dart';
import '../../services/pg_service.dart';
import 'market/market_screen.dart';
import 'market/payment_screen.dart';
import 'profile/profile_Identity_screen.dart';
import 'profile/profile_screen.dart';
import 'profile/webview_screen.dart';
import 'signup/login_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  MainScreen({Key? key, this.selectedPage = 0}) : super(key: key);
  static String get routeName => 'mainScreen';
  int selectedPage;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
  with WidgetsBindingObserver {
  final _mainScaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  late ProfileViewModel _viewModel;

  List<Widget> _mainPages = <Widget>[
    MarketScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    final prov = ref.read(loginProvider);
    prov.context = context;
    prov.mainPageIndex = widget.selectedPage;
    prov.enableLockScreen();
    _viewModel = ProfileViewModel(context);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAppUpdate(context);
    });
    _pageController = PageController(initialPage: prov.mainPageIndex);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final prov = ref.read(loginProvider);
    switch (state) {
      case AppLifecycleState.resumed:
        checkAppUpdate(context);
        prov.setLockScreen(false);
        _pageController = PageController(initialPage: prov.mainPageIndex);
        break;
      case AppLifecycleState.inactive:
        // isUpdateCheckDone = false;
        prov.setLockScreen(true);
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    _movePage();
    final scrSize = MediaQuery.of(context).size;
    final scrRatio = scrSize.width / scrSize.height;
    isPadMode = scrRatio > 0.6;
    LOG('--> MediaQuery.of(context).size.width : [$defaultTargetPlatform] ${scrSize.width} / ${scrSize.height}');

    return prov.isScreenLocked ? lockScreen(context) :
      AnnotatedRegion<SystemUiOverlayStyle>(
        value:SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness:Brightness.dark,
      ),
      child: Scaffold(
        key: _mainScaffoldKey,
        drawerEnableOpenDragGesture: false,
        appBar: AppBar(
          title: _viewModel.getPageTitle(),
          titleSpacing: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          leadingWidth: 50,
          leading: Container(
            padding: EdgeInsets.only(left: 5),
            child: prov.isShowMask ? null : InkWell(
              onTap: () {
                _viewModel.hideProfileSelectBox();
                _mainScaffoldKey.currentState!.openDrawer();
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: EdgeInsets.all(10),
                child: SvgPicture.asset('assets/svg/icon_ham.svg',
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).dividerColor, BlendMode.srcIn))
              ),
            )
          ),
          actions: [
            SizedBox(width: 45),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: _selectPage,
                physics: NeverScrollableScrollPhysics(),
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
                    color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
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
                            child: Text(TR('Market'),
                              style: typo16bold.copyWith(
                                color: prov.mainPageIndex == 0 ? PRIMARY_100 :
                                    Theme.of(context).disabledColor
                              )
                            )
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
        ),
        drawer: _viewModel.mainDrawer(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // _showCardPay();
            _showIdentity();
            // ApiService().testCheck();
            // showSimpleDialog(context, 'test test');
            // var mnemonic = EX_TEST_MN_02;
            // var address = prov.accountAddress;
            // var keyPair = await prov.getAccountKey(passOrg: '11111');
            // if (address != null && keyPair != null) {
            //   var rwfStr = await RWFExportHelper.encrypt(
            //       '22222', address, keyPair.d, mnemonic);
            //   LOG('------> rwfStr : $rwfStr');
            // }
            // var str = '{"version":"1","address":"746cd77220f91a9c42264bad889751cf3c104f99","origin":"IaErnUvlKy3+RSHSxF4kvm1OgdS4QEe3FKMLsMFr8FGoKJsHpRaDArDKwv2STNkbaJ2+oG9zrD87wTpfpyH/E/pGH4eANkhintLLPAxeH38=","algo":"secp256k1","cp":{"ca":"aes-256-cbc","ct":"PdBIzuoJWr5ySsoBW8npDr6f899VJeY4HeEa9AWGcah2reLCwjBagUCeW5F5nSLP0ZhApf7KL4WqOEIgB6hj0+UGS/UJO1L9himEMBT4wXU=","ci":"qyctDNj+11JXkL6Gf8nfrA=="},"dkp":{"ka":"pbkdf2","kh":"sha256","kc":"4336","ks":"VSFRT6gU2QGnImbZtOrRjOYaR3g=","kl":"32"}}';
            // var result = await RWFExportHelper.decrypt('22222', str);
            // LOG('------> rwfStr : $result');
          },
          child: Text('+'),
        ),
      )
    );
  }

  _showCardPay() {
    var purchaseInfo = PurchaseModel(
      name:         '다날 결제 테스트 상품',
      merchantUid:  'mid_000000',
      buyPrice:     '100',
      buyerId:      'user_000000',
      buyerName:    'Xinno Tester',
      buyerEmail:   'dev@xinno.io',
      priceUnit:    'KRW',
    );
    ref.read(loginProvider).disableLockScreen();
    Navigator.of(context).push(
        createAniRoute(PaymentScreen(purchaseInfo))).then((_) {
      ref.read(loginProvider).enableLockScreen();
    });
  }

  _showIdentity() {
    ref.read(loginProvider).disableLockScreen();
    Navigator.of(context).push(
        createAniRoute(ProfileIdentityScreen())).then((_) {
      ref.read(loginProvider).enableLockScreen();
    });
  }

  _selectPage(index) {
    _viewModel.hideProfileSelectBox();
    final prov = ref.read(loginProvider);
    if (index == 1 && !prov.isLogin) {
      Navigator.of(context).push(
          createAniRoute(LoginScreen(isAppStart: false)));
    } else {
      prov.setMainPageIndex(index);
    }
  }

  _movePage() {
    final prov = ref.read(loginProvider);
    // LOG('---> movePage : ${prov.mainPageIndexOrg} => ${prov.mainPageIndex}');
    if (prov.mainPageIndexOrg != prov.mainPageIndex) {
      prov.mainPageIndexOrg = prov.mainPageIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.animateToPage(prov.mainPageIndex,
            duration: Duration(milliseconds: 200), curve: Curves.linear);
      });
    }
  }
}
