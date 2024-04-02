import 'package:larba_00/common/const/utils/convertHelper.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/disabled_button.dart';
import 'package:larba_00/common/const/widget/primary_button.dart';
import 'package:larba_00/common/provider/coin_provider.dart';
import 'package:larba_00/domain/model/rpc/delegateInfo.dart';
import 'package:larba_00/presentation/view/staking/staking_caution_screen.dart';
import 'package:larba_00/presentation/view/staking/staking_confirm_screen.dart';
import 'package:larba_00/services/json_rpc_service.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart' as provider;

import '../../../common/common_package.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/CustomCheckBox.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../common/const/widget/detail_row.dart';
import '../../../common/const/widget/gray_5_round_container.dart';
import '../../../common/provider/network_provider.dart';
import '../../../common/provider/stakes_data.dart';
import '../../../common/style/outlineInputBorder.dart';
import '../../../domain/model/network_model.dart';
import '../../../domain/model/rpc/staking_type.dart';

enum InputType { staking, delegate }

class StakingInputScreen extends ConsumerStatefulWidget {
  const StakingInputScreen({Key? key}) : super(key: key);
  static String get routeName => 'staking_input';

  @override
  ConsumerState<StakingInputScreen> createState() => _StakingInputScreenState();
}

class _StakingInputScreenState extends ConsumerState<StakingInputScreen> {
  FocusNode quantityTextFocus = FocusNode();
  final _quantityController = TextEditingController();
  late FToast fToast;

  bool quantityTextFieldIsEmpty = true;
  bool agree_1 = false;
  bool agree_2 = false;
  String hintText = '00';
  String sendAmount = '0';
  double balance = 0;
  String minProfit = '0.00';
  String maxProfit = '0.00';
  String formattedSendAmount = '0';

  String currentCoinUnit = 'RIGO';
  String typeText = '';
  String myAddress = '';

  @override
  WidgetRef get ref => context as WidgetRef;

  _showToast(String msg) {
    fToast.init(context);
    fToast.showToast(
      child: CustomToast(
        msg: msg,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  void setUI(context) {
    StakingType stakingType =
        provider.Provider.of<StakesData>(context, listen: false).stakingType;

    quantityTextFocus.addListener(() {
      if (quantityTextFocus.hasFocus) {
        hintText = '';
      } else {
        hintText = '00';
      }
    });

    if (stakingType == StakingType.staking) {
      typeText = '스테이킹';
    } else {
      typeText = '위임';
    }
  }

  Future<void> setMyAddress() async {
    myAddress = await UserHelper().get_address();
  }

  @override
  void initState() {
    super.initState();
    setMyAddress();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  void dispose() {
    super.dispose();
    _quantityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setUI(context);

    StakingType stakingType =
        provider.Provider.of<StakesData>(context, listen: false).stakingType;
    Stakes stakes =
        provider.Provider.of<StakesData>(context, listen: false).stakes;
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;

    bool isDelegate = stakingType == StakingType.delegate;
    String toAddress = stakes.to ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: () {
            context.pop();
          },
        ),
        centerTitle: true,
        title: Text(
          TR(context, typeText),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      backgroundColor: WHITE,
      body: GestureDetector(
        onTap: () {
          quantityTextFocus.unfocus();
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TR(context, '수량'),
                              style: typo14semibold,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            TextField(
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.numberWithOptions(),
                              controller: _quantityController,
                              focusNode: quantityTextFocus,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 4),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: GRAY_20),
                                ),
                                focusedBorder: grayBorder,
                                hintText: hintText,
                                hintStyle:
                                    typo18semibold.copyWith(color: GRAY_40),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Text(
                                    currentCoinUnit,
                                    style: typo16regular,
                                  ),
                                ),
                                suffixIconConstraints:
                                    BoxConstraints(minWidth: 0, minHeight: 0),
                              ),
                              style: typo18semibold,
                              textAlign: TextAlign.end,
                              onChanged: (String text) {
                                setState(() {
                                  if (text == '0') {
                                    text = '';
                                  }
                                  quantityTextFieldIsEmpty = text.isEmpty;
                                  //sendAmount = text;
                                });
                              },
                              textInputAction: TextInputAction.done,
                              onSubmitted: (String text) {
                                quantityTextFocus.unfocus();
                              },
                              inputFormatters: [
                                CurrencyInputFormatter(
                                    trailingSymbol: '',
                                    thousandSeparator: ThousandSeparator.Comma,
                                    mantissaLength: 0,
                                    onValueChange: (num value) {
                                      setState(() {
                                        if (value > 0) {
                                          sendAmount = value.toString();
                                          formattedSendAmount =
                                              getFormattedText(value: value);
                                          minProfit = getFormattedText(
                                              decimalPlaces: 2,
                                              value: value * 0.05);
                                          maxProfit = getFormattedText(
                                              decimalPlaces: 2,
                                              value: value * 0.15);
                                        } else {
                                          sendAmount = '0';
                                          formattedSendAmount = '0';
                                          minProfit = '0.00';
                                          maxProfit = '0.00';
                                        }
                                      });
                                    })
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            FutureBuilder<String>(
                                future: ref.read(coinProvider)
                                    .getBalance(networkModel),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasData) {
                                    String strBalance = snapshot.data!;
                                    balance = double.parse(strBalance);
                                    String formattedBalance =
                                        getFormattedText(value: balance);

                                    return Row(
                                      children: [
                                        Text(
                                          TR(context, '코인 보유량'),
                                          style: typo14medium.copyWith(
                                              color: GRAY_50),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          formattedBalance,
                                          style: typo14medium,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          'RIGO',
                                          style: typo14regular,
                                        ),
                                      ],
                                    );
                                  } else if (snapshot.hasError) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text('Error: ${snapshot.error}'),
                                    );
                                  } else {
                                    return SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                }),
                            SizedBox(
                              height: 16,
                            )
                          ],
                        ),
                        Gray5RoundContainer(
                          child: Column(
                            children: [
                              if (isDelegate)
                                DetailRow(
                                  title: TR(context, '검증인'),
                                  content: Text(
                                    getShortAddressText(toAddress, 6),
                                    style: typo18semibold.copyWith(
                                        color: SECONDARY_90),
                                  ),
                                ),
                              DetailQuantityRow(
                                title: TR(context, isDelegate ? '위임 금액' : '금액'),
                                quantity: formattedSendAmount,
                                unit: 'RIGO',
                              ),
                              DetailQuantityRow(
                                title: TR(context, '연 수익율'),
                                quantity: '5~15',
                                unit: '%',
                              ),
                              DetailRow(
                                title: TR(context, '예상 수익(연)'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$minProfit',
                                      style: typo16medium,
                                    ),
                                    Text('~$maxProfit $currentCoinUnit',
                                        style: typo16medium),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: GRAY_20,
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              isDelegate
                                  ? Row(
                                      children: [
                                        Text(
                                          TR(context, '총 위임 금액'),
                                          style: typo16medium.copyWith(
                                              color: GRAY_70),
                                        ),
                                        Spacer(),
                                        Row(
                                          children: [
                                            Text(
                                              formattedSendAmount,
                                              style: typo18semibold.copyWith(
                                                color: PRIMARY_90,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              'RIGO',
                                              style: typo16regular,
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : TotalStakingRow(
                                      title: '${TR(context, '총')} ${TR(context, typeText)}${TR(context, ' 금액')}',
                                      balance: formattedSendAmount,
                                    ),
                              SizedBox(
                                height: 8,
                              ),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: Text(
                                  '\$0',
                                  style: typo14regular.copyWith(color: GRAY_50),
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Divider(
                          height: 1,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        CustomCheckbox(
                          title: '${TR(context, typeText)} ${TR(context, '기능 이용 주의사항')}',
                          onChanged: (value) {
                            setState(() {
                              agree_1 = value!;
                            });
                          },
                          onPushnamed: () {
                            context.pushNamed(StakingCautionScreen.routeName);
                          },
                          checked: agree_1,
                          pushed: true,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        CustomCheckbox(
                          title: ref.read(languageProvider).getLocale!.languageCode == 'ko' ?
                            '${TR(context, typeText)}의 위험을 이해하고 진행합니다.' :
                            'Understand the risks of ${TR(context, typeText)} and proceed.',
                          checked: agree_2,
                          pushed: false,
                          localAuth: true,
                          onChanged: (value) {
                            setState(() {
                              agree_2 = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                (agree_1 && agree_2 && !quantityTextFieldIsEmpty)
                    ? PrimaryButton(
                        text: TR(context, '다음'),
                        onTap: () {
                          if (double.parse(sendAmount) > balance) {
                            _showToast(TR(context, '보유한 수량이 부족합니다'));
                            return;
                          }
                          provider.Provider.of<StakesData>(context,
                                  listen: false)
                              .updateStakes(Stakes(
                            to: isDelegate ? toAddress : myAddress,
                            power: sendAmount,
                          ));
                          context.pushNamed(StakingConfirmScreen.routeName);
                        },
                      )
                    : DisabledButton(text: TR(context, '다음'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TotalStakingRow extends StatelessWidget {
  const TotalStakingRow({
    super.key,
    required this.title,
    required this.balance,
  });

  final String title, balance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: typo16semibold,
        ),
        Spacer(),
        FittedBox(
          child: Row(
            children: [
              Text(
                balance,
                style: typo18semibold.copyWith(
                  color: PRIMARY_90,
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                'RIGO',
                style: typo16regular,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
