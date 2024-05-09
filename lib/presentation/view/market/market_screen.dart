import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/uihelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/mainBox.dart';
import 'package:larba_00/common/provider/login_provider.dart';
import 'package:larba_00/common/provider/market_provider.dart';
import 'package:larba_00/presentation/view/history_screen.dart';
import 'package:larba_00/presentation/view/main_screen.dart';
import 'package:larba_00/presentation/view/market/product_detail_screen.dart';
import 'package:larba_00/presentation/view/signup/login_screen.dart';
import 'package:larba_00/presentation/view/settings/settings_screen.dart';

import 'package:animations/animations.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../domain/viewModel/market_view_model.dart';
import '../../../services/google_service.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});
  static String get routeName => 'marketScreen';

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final controller  = ScrollController();
  late MarketViewModel _viewModel;

  @override
  void initState() {
    final prov = ref.read(marketProvider);
    _viewModel = MarketViewModel(prov);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    _viewModel.context = context;
    return SafeArea(
      top: false,
      child: CustomScrollView(
        controller: controller,
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            // title: Text(TR(context, 'Market')),
            // leading: IconButton(
            //   onPressed: () {
            //   },
            //   icon: SvgPicture.asset('assets/svg/icon_ham.svg'),
            // ),
            // centerTitle: true,
            // titleTextStyle: typo16bold,
            toolbarHeight: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(40),
              child: _viewModel.showCategoryBar(),
            ),
          ),
          _viewModel.showProductList()
        ],
      ),
    );
  }
}
