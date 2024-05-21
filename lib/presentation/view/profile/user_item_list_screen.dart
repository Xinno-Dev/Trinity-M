import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trinity_m_00/presentation/view/main_screen.dart';
import '../../../../common/common_package.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/provider/market_provider.dart';
import '../../../../domain/model/product_model.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../domain/viewModel/market_view_model.dart';

class UserItemListScreen extends ConsumerStatefulWidget {
  UserItemListScreen({super.key});
  static String get routeName => 'userItemListScreen';

  @override
  ConsumerState<UserItemListScreen> createState() => _UserItemListScreenState();
}

class _UserItemListScreenState extends ConsumerState<UserItemListScreen> {
  late MarketViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MarketViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(marketProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(TR(context, '보유 상품')),
          centerTitle: true,
          titleTextStyle: typo16bold,
          backgroundColor: Colors.white,
          // leading: IconButton(
          //   onPressed: context.pop,
          //   icon: Icon(Icons.close),
          // ),
        ),
        backgroundColor: Colors.white,
        body: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [
              _viewModel.showUserItemListShowType(),
              _viewModel.showUserItemList(context),
            ]
        ),
      ),
    );
  }
}
