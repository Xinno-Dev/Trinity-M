
import '../../../../common/const/constants.dart';
import '../../../../domain/model/coin_model.dart';
import '../../../../domain/model/network_model.dart';
import '../../../../domain/model/swap_model.dart';
import '../../../../presentation/view/sign_password_screen.dart';
import 'package:provider/provider.dart' as provider;

import '../../../../common/common_package.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/languageHelper.dart';
import '../../../../common/const/utils/uihelper.dart';
import '../../../../common/const/widget/back_button.dart';
import '../../../../common/const/widget/balance_row.dart';
import '../../../../common/const/widget/disabled_button.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/provider/network_provider.dart';
import '../../../../common/provider/stakes_data.dart';
import '../../../../domain/model/rpc/delegateInfo.dart';
import '../../../../domain/model/rpc/staking_type.dart';
import 'swap_utils.dart';

class SwapConfirmScreen extends ConsumerStatefulWidget {
  SwapConfirmScreen(this.swapModel, {Key? key}) : super(key: key);
  static String get routeName => 'SwapConfirmScreen';
  SwapModel swapModel;

  @override
  ConsumerState createState() => _SwapConfirmScreenState();
}

class _SwapConfirmScreenState extends ConsumerState<SwapConfirmScreen> {
  get isEnableButton {
    return IS_DEV_MODE || STR(widget.swapModel.toAddress).isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final networkProv = provider.Provider.of<NetworkProvider>(context, listen: false);
    return Scaffold(
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
        backgroundColor: WHITE,
        body: Container(
          height: MediaQuery.of(context).size.height - kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showStepNumber(2),
              Text(TR(context, '스왑 정보를 확인해주세요'), style: typo16medium),
              SizedBox(height: 20.h),
              _buildInfoWidget(
                TR(context, '보내는 정보'),
                STR(widget.swapModel.fromNetwork?.name),
                STR(widget.swapModel.fromCoin?.name),
                STR(widget.swapModel.fromCoin?.walletAddress),
              ),
              Container(
                height: 30.h,
                alignment: Alignment.center,
                child: Icon(Icons.arrow_downward),
              ),
              _buildInfoWidget(
                TR(context, '받는 정보'),
                STR(widget.swapModel.toNetwork?.name),
                STR(widget.swapModel.toCoin?.name),
                STR(widget.swapModel.toAddress),
              ),
              Spacer(),
              _buildAmountWidget(widget.swapModel!),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: isEnableButton ? PrimaryButton(
                  text: TR(context, '스왑'),
                  onTap: () {
                    final stack = Stakes(
                      // fromTokenAddress: widget.swapModel.fromCoin?.chainCode,
                      // fromSymbol: widget.swapModel.fromCoin?.symbol,
                      to: widget.swapModel.toAddress,
                      toChainId: STR(widget.swapModel.toNetwork?.chainId),
                      toTokenAddress: STR(widget.swapModel.toCoin?.chainCode),
                      power: widget.swapModel.fromAmount,
                    );
                    provider.Provider.of<StakesData>(context,
                        listen: false)
                        .updateStakingType(StakingType.bridge);
                    provider.Provider.of<StakesData>(context,
                        listen: false)
                        .updateStakes(stack);
                    LOG('---> stack : ${stack.toJson()}');
                    LOG('---> toCoin : ${widget.swapModel.toCoin?.toJson()}');
                    Navigator.of(context).push(createAniRoute(SignPasswordScreen()));
                  },
                ) : DisabledButton(text: TR(context, '스왑')),
              ),
            ],
          ),
        )
    );
  }

  _buildInfoWidget(title, network, token, address) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: typo14medium),
          Container(
            margin:  EdgeInsets.symmetric(vertical: 10.h),
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1, color: GRAY_50)
            ),
            child: Column(
              children: [
                _buildInfoItem(TR(context, '네트워크'), network),
                _buildInfoItem(TR(context, '토큰'   ), token),
                _buildInfoItem(TR(context, '주소'   ), address),
              ],
            ),
          ),
        ]
      ),
    );
  }

  _buildInfoItem(String title, String desc) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Expanded(child: Text(title, style: typo14medium), flex: 1),
          Expanded(child: Text(desc , style: typo14medium), flex: 4),
        ],
      )
    );
  }

  _buildAmountWidget(SwapModel swapInfo) {
    final fromUnit = swapInfo.fromCoin?.symbol;
    final toUnit = swapInfo.toCoin?.symbol;
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
        children: [
          _buildAmountItem(TR(context, '보내는 수량'  ), amount: STR(swapInfo.fromAmount), unit: fromUnit),
          _buildAmountItem(TR(context, '수수료'      ), amount: STR(swapInfo.swapFee), unit: fromUnit),
          _buildAmountItem(TR(context, '교환비율(예상)'), desc: '1 $fromUnit ≈ ${DBL(swapInfo.swapRate)} $toUnit'),
          Divider(height: 20, thickness: 2.0, color: GRAY_20),
          _buildAmountItem(TR(context, '받을수량(예상)'), amount: STR(swapInfo.toAmount), unit: toUnit),
        ],
      ),
    );
  }

  _buildAmountItem(String title, {String? amount, String? unit, String? desc}) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          children: [
            Expanded(child: Text(title, style: typo14medium), flex: 1),
            if (STR(desc).isNotEmpty)
              Expanded(child: Text(STR(desc), style: typo14medium, textAlign: TextAlign.right), flex: 3),
            if (STR(amount).isNotEmpty)
              BalanceRow(balance: amount, tokenUnit: unit, fontSize: 16, height: 20),
          ],
        )
    );
  }
}
