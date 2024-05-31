import 'dart:convert';
import 'dart:developer';

import '../../../../common/const/widget/dialog_utils.dart';
import '../../../../domain/model/coin_model.dart';
import 'package:web3dart/credentials.dart';

import '../../../../common/common_package.dart';
import '../../../../common/const/constants.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/languageHelper.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/const/utils/userHelper.dart';
import '../../../../common/const/widget/coin_list_tile.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/provider/coin_provider.dart';
import '../../../../common/provider/network_provider.dart';
import '../../../../common/provider/temp_provider.dart';
import '../../../../common/trxHelper.dart';
import '../../../../domain/model/address_model.dart';
import '../../../../domain/model/network_model.dart';
import '../../../../domain/model/rpc/account.dart';
import '../../../../services/json_rpc_service.dart';

import 'package:provider/provider.dart' as provider;

import '../token_add_screen.dart';

class CoinListScreen extends ConsumerStatefulWidget {
  CoinListScreen({
    super.key,
    required this.networkModel,
    required this.walletAddress,
  });

  NetworkModel networkModel;
  String    walletAddress;

  @override
  ConsumerState<CoinListScreen> createState() => CoinListScreenState();
}

class CoinListScreenState extends ConsumerState<CoinListScreen> {
  bool isError = false;
  bool isEditMode = false;

  refreshCoin(CoinModel coin) async {
    // TODO: add balance refresh timer..
    // if (coin.updateTime == null) {
      coin.balance = await ref.read(coinProvider).
        getBalance(widget.networkModel, coin: coin);
    // }
    return coin;
  }

  refreshShowCoin() {
    var showList = [];
    for (CoinModel item in ref.read(coinProvider).coinList) {
      // 같은 네트워크의 토큰만 보여줌..
      // print('--> show item : ${item.isHide}, ${item.walletAddress} / ${isEditMode}');
      if (isEditMode || !item.isHide) {
        if ((item.walletAddress.isEmpty ||
            item.walletAddress == widget.walletAddress) &&
            widget.networkModel.chainId == item.mainNetChainId) {
          // print('--> show item add : ${item.toJson()}');
          showList.add(item);
        }
      }
    }
    return showList;
  }

  get showCoinCount {
    var result = 0;
    for (CoinModel item in ref.read(coinProvider).coinList) {
      if ((item.walletAddress.isEmpty ||
          item.walletAddress == widget.walletAddress) &&
          widget.networkModel.chainId == item.mainNetChainId) {
        result += 1;
      }
    }
    // if (result <= 0 || (result == 1 && showCoinCount == 0)) {
    //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //     ref.read(coinProvider).setCurrentCoinCode(null);
    //   });
    // }
    return result;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final showCoinList = refreshShowCoin();
    final currentCoin = ref.watch(coinProvider).currentCoin;
    // log('--> showCoinList : ${showCoinList.length}');
    return Column(
      children: [
        if (showCoinList.isNotEmpty)
        Expanded(
          child: ListView.builder(
            itemCount: showCoinList.length,
            itemBuilder: (context, index) {
              CoinModel coin = showCoinList[index];
              // log('--> showCoinList item : ${coin.code} / ${coin.name} / ${coin.balance}');
              return FutureBuilder(
                future: refreshCoin(coin),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    coin = snapshot.data as CoinModel;
                    return CoinListItem(
                      coin,
                      isSelected: currentCoin != null && currentCoin.code == coin.code,
                      isEditMode: isEditMode,
                      isCanHide: showCoinCount > 1,
                      onSelected: (_) {
                        ref.read(coinProvider).selectCoinModel(coin.code);
                      },
                      onDelete: (_) {
                        if (isEditMode && coin.isToken) {
                          ref.read(coinProvider).hideCoinModel(coin.code);
                        }
                      },
                    );
                  } else {
                    return showLoadingItem();
                  }
                }
              );
            }
          )
        ),
        if (showCoinList.isEmpty)
          Expanded(
            child: Center(
            child: Text(
              TR(context, '자산이 없습니다.\n토큰을 추가해 주세요'),
              style: typo16dialog.copyWith(color: GRAY_70),
              textAlign: TextAlign.center,
            ),
          )),
        Container(
          margin: EdgeInsets.all(20.r),
          alignment: Alignment.centerLeft,
          // child: TextButton(
          //   child: Text(
          //     TR(context, '+ 토큰 가져오기'),
          //     style: typo16semibold.copyWith(color: PRIMARY_90)
          //   ),
          //   onPressed: () {
          //     NetworkModel networkModel =
          //       provider.Provider.of<NetworkProvider>(context, listen: false)
          //         .networkModel;
          //     Navigator.of(context).push(
          //       createAniRoute(TokenAddScreen(networkModel))).
          //       then((result) {
          //
          //       }
          //     );
          //   },
          // ),
          child: Row(
            children: [
              // Text(
              //   TR(context, '토큰이 보이지 않나요?'),
              //   style: typo14medium150,
              // ),
              // SizedBox(height: 10.h),
              if (!isEditMode)
                Expanded(
                  child: PrimaryButton(
                    text: '${TR(context, '토큰 추가')}+',
                    color: isEditMode ? GRAY_10 : GRAY_20,
                    textStyle: typo16medium,
                    isSmallButton: true,
                    isBorderShow: true,
                    onTap: () async {
                      if (isEditMode) return;
                      Navigator.of(context).push(
                        createAniRoute(TokenAddScreen(
                            widget.networkModel, widget.walletAddress))).
                        then((result) {
                          print('----> TokenAddScreen result : $result');
                          if (result != null && result) {
                            Future.delayed(Duration(milliseconds: 200)).then((_) {
                              showSimpleDialog(context, TR(context, '추가하였습니다.'),
                                  'assets/svg/success.svg', 70.h);
                            });
                          }
                        }
                      );
                    }
                  )
                ),
              if (showCoinCount > 1)...[
                SizedBox(width: 10.w),
                if (isEditMode)
                  Expanded(
                    child: PrimaryButton(
                      text: TR(context, '편집 완료'),
                      color: GRAY_20,
                      textStyle: typo16medium,
                      isSmallButton: true,
                      isBorderShow: true,
                      onTap: () async {
                        setState(() {
                          isEditMode = !isEditMode;
                        });
                      }
                    )
                  ),
                if (!isEditMode)
                  Expanded(
                  child: PrimaryButton(
                    text: TR(context, '토큰 편집'),
                    color: GRAY_20,
                    textStyle: typo16medium,
                    isSmallButton: true,
                    isBorderShow: true,
                    afterIcon: Icon(Icons.settings, color: GRAY_40),
                    onTap: () async {
                      setState(() {
                        isEditMode = !isEditMode;
                      });
                    }
                  )
                )
              ]
            ]
          )
        )
      ]
    );
  }
}
