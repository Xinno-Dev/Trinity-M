import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../common/common_package.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/provider/market_provider.dart';
import '../../../domain/model/product_model.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../domain/viewModel/market_view_model.dart';
import 'payment_screen.dart';
import 'pg/payment_test.dart';

class ItemSelectScreen extends ConsumerStatefulWidget {
  ItemSelectScreen({super.key});
  static String get routeName => 'itemSelectScreen';

  @override
  ConsumerState<ItemSelectScreen> createState() => _ItemSelectScreenState();
}

class _ItemSelectScreenState extends ConsumerState<ItemSelectScreen> {
  final controller  = ScrollController();
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
          appBar: defaultAppBar(TR(context, '옵션선택'),
            leading: IconButton(
              onPressed: () {
                prov.setOptionIndex(-1);
                context.pop();
              },
              icon: Icon(Icons.close),
          )),
          backgroundColor: Colors.white,
          body: ListView(
            shrinkWrap: true,
            children: [
              _viewModel.showOptionSelectList(),
            ]
          ),
          bottomNavigationBar: prov.optionIndex >= 0
              ? PrimaryButton(
            text: TR(context, '선택완료'),
            round: 0,
            onTap: () {
              context.pop(prov.optionIndex);
            },
          ) : DisabledButton(
            text: TR(context, '선택완료'),
          )
      ),
    );
  }
}
