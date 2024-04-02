import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:larba_00/common/const/widget/disabled_button.dart';
import 'package:larba_00/common/provider/firebase_provider.dart';
import 'package:larba_00/domain/model/coin_model.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_add_screen.dart';
import 'package:larba_00/presentation/view/asset/networkScreens/network_info_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:helpers/helpers.dart';
import 'package:provider/provider.dart' as provider;

import '../../../../common/common_package.dart';
import '../../../../common/const/constants.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/languageHelper.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/const/utils/userHelper.dart';
import '../../../../common/const/widget/back_button.dart';
import '../../../../common/const/widget/coin_list_tile.dart';
import '../../../../common/const/widget/custom_radio_list_tile.dart';
import '../../../../common/const/widget/custom_toast.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/provider/coin_provider.dart';
import '../../../../common/provider/network_provider.dart';
import '../../../../domain/model/network_model.dart';
import '../../../../services/json_rpc_service.dart';

class SwapSelectScreen extends ConsumerStatefulWidget {
  SwapSelectScreen(
  {
    Key? key, this.isSend = true, this.targetIsRigo = true, this.selectCoin
  }) : super(key: key);
  static String get routeName => 'SwapSelectScreen';
  final bool isSend;
  final bool targetIsRigo;
  final CoinModel? selectCoin;

  @override
  ConsumerState createState() => _SwapSelectScreenState();
}

class _SwapSelectScreenState extends ConsumerState<SwapSelectScreen> {
  List<CoinModel> showList = [];

  initShowList() {
    LOG('------> initShowList [${widget.targetIsRigo}] : ${widget.selectCoin?.toJson()}');
    showList.clear();
    var coinProv = ref.read(coinProvider);
    for (CoinModel item in coinProv.coinList) {
      LOG('--> check [${item.isMDL}] : ${item.mainNetChainId} / ${widget.selectCoin?.mainNetChainId} '
          '- ${item.walletAddress} / ${widget.selectCoin?.contract}');
      if (!widget.isSend ||
          item.mainNetChainId == widget.selectCoin?.mainNetChainId && (
          STR(item.walletAddress).isEmpty ||
          item.walletAddress  == widget.selectCoin?.walletAddress)) {
        if (widget.targetIsRigo && item.isRigo) {
          showList.add(item);
        } else if (!widget.targetIsRigo && item.isMDL) {
          showList.add(item);
        }
      }
    }
  }

  @override
  void initState() {
    initShowList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final networkProv = provider.Provider.of<NetworkProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: () {
            context.pop();
          },
        ),
        leadingWidth: 40.w,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(TR(context, '토큰'),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView(
          children: [
            SizedBox(height: 10.h),
            ...showList.map((CoinModel e) =>
              CoinListItem(
                e,
                networkName: networkProv.getNetwork(e.mainNetChainId)?.name,
                isSelected: widget.selectCoin == e,
                isShowBalance: false,
                onSelected: (selectItem) {
                  Navigator.of(context).pop(e);
                },
              )).toList()
          ],
        ),
      )
    );
  }
}
