import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/mainBox.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/common/provider/market_provider.dart';
import 'package:larba_00/presentation/view/history_screen.dart';
import 'package:larba_00/presentation/view/market/product_detail_screen.dart';
import 'package:larba_00/presentation/view/signup/login_screen.dart';
import 'package:larba_00/presentation/view/settings/settings_screen.dart';

import 'package:animations/animations.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../services/google_service.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});
  static String get routeName => 'marketScreen';
  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final controller  = ScrollController();
  var selectTab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    prov.context = context;
    return SafeArea(
      top: false,
      child: CustomScrollView(
        controller: controller,
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text(TR(context, 'Market')),
            centerTitle: true,
            // automaticallyImplyLeading: false, // TODO: disabled for Dev..
            titleTextStyle: typo16bold,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            actions: [
              InkWell(
                onTap: () {
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(Icons.search)
                ),
              ),
              InkWell(
                onTap: () {
                  GoogleService.uploadKeyToGoogleDrive(context).then((result) {
                    LOG('---> uploadKeyToGoogleDrive result : $result');
                  });
                },
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(Icons.upload)
                ),
              ),
              InkWell(
                onTap: () {
                  GoogleService.downloadKeyFromGoogleDrive(context).then((rwf) {
                    LOG('---> downloadKeyFromGoogleDrive result : $rwf');
                  });
                },
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(Icons.download)
                ),
              ),
              InkWell(
                onTap: () {
                  ref.read(loginProvider).logout().then((_) {
                    context.replaceNamed('login');
                  });
                },
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Icon(Icons.more_vert)
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: prov.showCategoryBar(),
            )
          ),
          prov.showProductList()
        ],
      ),
    );
  }
}
