import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trinity_m_00/common/provider/login_provider.dart';
import 'package:trinity_m_00/domain/viewModel/profile_view_model.dart';
import 'package:trinity_m_00/presentation/view/main_screen.dart';
import '../../../../common/common_package.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/provider/market_provider.dart';
import '../../../../domain/model/product_model.dart';

import '../../../common/const/utils/uihelper.dart';
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
    _viewModel = MarketViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    ref.watch(marketProvider);
    return prov.isScreenLocked ? lockScreen(context) :
      Scaffold(
        appBar: defaultAppBar(TR(context, '보유 상품')),
        backgroundColor: WHITE,
        body: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(15, 40, 15, 10),
              child: _viewModel.showUserItemList(prov.accountAddress),
            ),
            Column(
              children: [
                _viewModel.showUserItemListShowType(),
                Divider(),
              ],
            )
          ]
        ),
      );
  }
}
