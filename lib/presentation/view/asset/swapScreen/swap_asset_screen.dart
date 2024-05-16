import '../../../../common/common_package.dart';
import '../../../../common/const/constants.dart';
import '../../../../common/const/widget/balance_row.dart';
import '../../../../common/provider/coin_provider.dart';
import '../../../../domain/model/coin_model.dart';
import '../../../../presentation/view/asset/swapScreen/swap_address_screen.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart' as provider;
import '../../../../domain/model/network_model.dart';
import 'package:web3dart/web3dart.dart';

import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/languageHelper.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/const/utils/userHelper.dart';
import '../../../../common/const/widget/back_button.dart';
import '../../../../common/const/widget/disabled_button.dart';
import '../../../../common/const/widget/network_error_screen.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/provider/network_provider.dart';
import '../../../../common/style/outlineInputBorder.dart';
import '../../../../domain/model/swap_model.dart';
import '../../../../services/bridge_service.dart';
import 'swap_utils.dart';
import 'swap_select_screen.dart';

class SwapAssetScreen extends ConsumerStatefulWidget {
  SwapAssetScreen({Key? key, required this.walletAddress}) : super(key: key);
  static String get routeName => 'swapAssetScreen';
  final String? walletAddress;

  @override
  ConsumerState createState() => _SwapAssetScreenState();
}

class _SwapAssetScreenState extends ConsumerState<SwapAssetScreen> {
  final _amountController   = TextEditingController();
  final _keyboardController = KeyboardVisibilityController();
  final _scrollController   = ScrollController();

  late SwapModel swapInfo;
  var isError = false;
  var walletBalance = '';
  var _errorMsg = '';

  _initSwapInfo() {
    var networkModel = provider.Provider.of<NetworkProvider>(context, listen: false).networkModel;
    var coinModel = ref.read(coinProvider).currentCoin;
    swapInfo = SwapModel(
      fromNetwork: networkModel,
      fromCoin: coinModel,
      fromAmount: coinModel!.isRigo ? '10.0' : '0.0000000000000005',
      toAddress: widget.walletAddress,
      swapFee:  '1.0',
      swapRate: '1.0' // for Default..
    );
    _amountController.text = STR(swapInfo.fromAmount);
    return swapInfo;
  }

  get isBalanceOk {
    return DBL(swapInfo.fromAmount) <= DBL(walletBalance);
  }

  get isEnableButton {
    return IS_DEV_MODE || (swapInfo.isEnable && isBalanceOk);
  }

  refreshSwapRatio() async {
    LOG('--> refreshSwapRatio');
    String? ratioStr = '1.0';
    if (BOL(swapInfo.fromCoin?.isRigo)) {
      ratioStr = await BridgeService().getSwapRatio(
          STR(swapInfo.toNetwork?.chainId),
          STR(swapInfo.toCoin?.chainCode),
          '1', true);
    } else {
      ratioStr = await BridgeService().getSwapRatio(
          STR(swapInfo.fromNetwork?.chainId),
          STR(swapInfo.fromCoin?.chainCode),
          '1', false);
    }
    LOG('--> refreshSwapRatio ratioStr : $ratioStr');
    swapInfo.swapRate = ratioStr != null ? ratioStr : '1';
    refreshAmount();
    return ratioStr;
  }

  refreshAmount() {
    if (DBL(swapInfo.fromAmount) <= 0) return '0.0';
    final swapRate = double.parse(STR(swapInfo.swapRate, defaultValue: '1.0'));
    if (swapInfo.fromCoin?.isRigo) {
      swapInfo.toAmount = (double.parse(STR(swapInfo.fromAmount)) * swapRate).toStringAsFixed(18);
      LOG('--> refreshAmount : ${swapInfo.fromAmount} -> ${swapInfo.toAmount} / '
        '$swapRate');
    } else {
      swapInfo.toAmount = (double.parse(STR(swapInfo.fromAmount)) / swapRate).toStringAsFixed(18);
      LOG('--> refreshAmount : ${swapInfo.fromAmount} -> ${swapInfo.toAmount} / '
          '$swapRate');
    }
  }
  
  @override
  void initState() {
    _initSwapInfo();
    // TODO: provider 로 글로벌 적용으로 변경 예정..
    _keyboardController.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          _scrollController.animateTo(visible ? _scrollController.position.maxScrollExtent : 0,
              duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        title: Text(
          TR(context, '스왑'),
          style: typo18semibold,
        ),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: isError ? NetworkErrorScreen() : Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            showStepNumber(0),
            Expanded(
              child: ListView(
                controller: _scrollController,
                children: [
                  _buildFromWidget(),
                  _buildErrorWidget(),
                  _buildCenterIcon(),
                  _buildToWidget(),
                  _buildRatioWidget(),
                ]
              )
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: isEnableButton ? PrimaryButton(
                text: TR(context, '다음'),
                onTap: () async {
                  Navigator.of(context).push(createAniRoute(SwapAddressScreen(swapInfo)));
                },
              ) : DisabledButton(text: TR(context, '다음')),
            ),
          ],
        )
      )
    );
  }

  _buildCenterIcon() {
    return Padding(padding: EdgeInsets.only(bottom: 15.h),
      child: SvgPicture.asset('assets/svg/icon_swap_center.svg', width: 42.r, height: 42.r),
    );
  }

  _buildFromWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TR(context, '보내는 자산'), style: typo16medium),
          Container(
            margin: EdgeInsets.only(top: 15.r),
            child: Row(
              children: [
                swapInfo.fromNetwork?.getIconImage(25.r),
                SizedBox(width: 5.w),
                Text(swapInfo.fromNetwork?.name ?? '', style: typo16medium),
              ],
            ),
          ),
          Container(
            margin:  EdgeInsets.symmetric(vertical: 10.h),
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(width: 1, color: GRAY_30),
            ),
            child: Column(
              children: [
                _buildCoinSelectWidget(swapInfo.fromCoin, swapInfo.fromCoin?.isRigo),
                _buildAmountWidget(swapInfo.fromCoin, swapInfo.fromAmount),
              ],
            ),
          ),
        ]
      ),
    );
  }

  _buildErrorWidget() {
    return Container(
      height: 25.h,
      child: Text(_errorMsg, style: typo14regular.copyWith(color: PRIMARY_90),
        textAlign: TextAlign.end),
    );
  }

  _buildRatioWidget() {
    return swapInfo.toCoin != null ? Container(
      height: 25.h,
      child: FutureBuilder(
        future: refreshSwapRatio(),
        builder: (context, snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(TR(context, '교환 비율(예상)'), style: typo12dialog),
              if (swapInfo.fromCoin?.isMDL)
                Text('${swapInfo.swapRate} ${STR(swapInfo.fromCoin?.symbol)} ≈ '
                  '1 ${swapInfo.toCoin?.symbol}',
                  style: typo12regular),
              if (swapInfo.fromCoin?.isRigo)
                Text('1 ${STR(swapInfo.fromCoin?.symbol)} ≈ '
                    '${swapInfo.swapRate} ${swapInfo.toCoin?.symbol}',
                    style: typo12regular)
            ],
          );
        }
      )
    ) : Container();
  }

  _buildToWidget() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(TR(context, '받는 자산'), style: typo16medium),
          Container(
            margin:  EdgeInsets.symmetric(vertical: 10.h),
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(width: 1, color: GRAY_30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildCoinSelectWidget(swapInfo.toCoin, !swapInfo.fromCoin?.isRigo, false),
                SizedBox(height: 8.h),
                if (swapInfo.toCoin == null)
                  Text(' - ', style: typo16medium),
                if (swapInfo.toCoin != null)
                  Container(
                    height: 30.h,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(TR(context, ''), style: typo16medium),
                      BalanceRow(balance: swapInfo.toAmount,
                        tokenUnit: swapInfo.toCoin?.symbol,
                        fontSize: 16, height: 20),
                    ],
                  )
                )
              ],
            ),
          )
        ]
      ),
    );
  }

  _buildCoinSelectWidget(CoinModel? coinModel, bool isRigo, [bool isSend = true]) {
    var networkProv = provider.Provider.of<NetworkProvider>(context, listen: false);
    LOG('--> _buildCoinSelectWidget [$isSend] : ${coinModel?.toJson()}');
    return OutlinedButton(
      onPressed: () {
        if (!isSend) {
          Navigator.of(context).push(createAniRoute(SwapSelectScreen(
            isSend: isSend,
            targetIsRigo: isRigo,
            selectCoin: coinModel,
          ))).then((result) {
            LOG('--> _buildCoinSelectWidget result [$isSend] : ${result
                ?.toJson()}');
            if (result != null) {
              setState(() {
                swapInfo.toNetwork = networkProv.getNetwork(result?.mainNetChainId);
                swapInfo.toCoin = result;
                refreshAmount();
                // if (isSend) {
                //   swapInfo.fromNetwork = networkProv.getNetwork(result?.mainNetChainId);
                //   swapInfo.fromCoin = result;
                // } else {
                //   swapInfo.toNetwork = networkProv.getNetwork(result?.mainNetChainId);
                //   swapInfo.toCoin = result;
                //   refreshAmount();
                // }
              });
            }
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          children: [
            if (coinModel != null)...[
              getCoinIcon(coinModel),
              SizedBox(width: 10.w),
              Text(
                coinModel.name,
                style: typo16medium,
              ),
            ],
            if (coinModel == null)...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 9),
                child: Text(TR(context, '토큰 선택'),
                  style: typo16medium.copyWith(color: GRAY_30)),
              )
            ],
            if (!isSend)...[
              Spacer(),
              Icon(Icons.keyboard_arrow_down, color: GRAY_80)
            ],
          ],
        ),
      ),
      style: grayBorderButtonStyle);
  }

  _buildAmountWidget(CoinModel? coinModel, String? amount) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            style: typo16medium,
            textAlign: TextAlign.end,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            scrollPadding: EdgeInsets.only(bottom: 300.h),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(width: 1, color: GRAY_20),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(width: 2, color: SECONDARY_50),
              ),
              hintText: TR(context, '수량 입력'),
              hintStyle: typo16semibold.copyWith(color: GRAY_40),
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  STR(coinModel?.symbol),
                  style: typo16bold,
                ),
              ),
              suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            ),
            onChanged: (text) {
              setState(() {
                swapInfo.fromAmount = text;
                refreshAmount();
              });
            },
          ),
          _buildAmountButtons(),
          Container(
            padding: EdgeInsets.only(top: 8.h),
            child: FutureBuilder(
              future: ref.read(coinProvider).
                getBalance(swapInfo.fromNetwork!, coin: swapInfo.fromCoin),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  walletBalance = STR(snapshot.data);
                  _errorMsg = isBalanceOk ? '' : TR(context, '수량이 부족합니다.');
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(TR(context, '보유수량 : '), style: typo14medium),
                      BalanceRow(balance: walletBalance,
                        tokenUnit: swapInfo.fromCoin?.symbol, fontSize: 14, height: 20),
                    ],
                  );
                } else {
                  return showLoadingItem(20.0);
                }
              }
            ),
          )
        ],
      ),
    );
  }

  _buildAmountButtons() {
    final btnTextN  = ['10','100','1,000','최대'];
    final btnValueN = [10,100,1000,-1];
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      child: Row(
        children: btnTextN.map((e) => Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                if (e == btnTextN.last) {
                  swapInfo.fromAmount = walletBalance;
                } else {
                  swapInfo.fromAmount =
                      (double.parse(STR(swapInfo.fromAmount)) +
                          btnValueN[btnTextN.indexOf(e)]).toString();
                }
                _amountController.text = STR(swapInfo.fromAmount);
                _errorMsg = isBalanceOk ? '' : TR(context, '수량이 부족합니다.');
              });
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                left:  e == btnTextN.first ? 0: 2.5.w,
                right: e == btnTextN.last  ? 0: 2.5.w),
              padding: EdgeInsets.symmetric(vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.black12,
              ),
              child: Text(TR(context, e), style: typo12semibold100),
          )))).toList(),
      ),
    );
  }
}