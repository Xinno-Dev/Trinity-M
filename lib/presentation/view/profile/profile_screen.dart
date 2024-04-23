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

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  static String get routeName => 'profileScreen';
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    return SafeArea(
      top: false,
      child: CustomScrollView(
        controller: controller,
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
              title: Text(TR(context, 'Profile')),
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
