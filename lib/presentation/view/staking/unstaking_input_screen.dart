import 'dart:developer';

import 'package:larba_00/common/const/utils/convertHelper.dart';
import 'package:larba_00/domain/model/rpc/delegateInfo.dart';
import 'package:larba_00/presentation/view/staking/staking_caution_screen.dart';
import 'package:larba_00/presentation/view/staking/staking_confirm_screen.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:provider/provider.dart' as provider;

import '../../../common/common_package.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/CustomCheckBox.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/detail_row.dart';
import '../../../common/const/widget/gray_5_round_container.dart';
import '../../../common/provider/network_provider.dart';
import '../../../common/provider/stakes_data.dart';
import '../../../common/style/outlineInputBorder.dart';
import '../../../domain/model/network_model.dart';
import '../../../domain/model/rpc/staking_type.dart';
import '../../../services/json_rpc_service.dart';

enum CancelInputType { staking, delegate }

class UnStakingInputScreen extends ConsumerStatefulWidget {
  const UnStakingInputScreen({Key? key}) : super(key: key);
  static String get routeName => 'unStaking_input';

  @override
  ConsumerState<UnStakingInputScreen> createState() => _UnStakingInputScreenState();
}

class _UnStakingInputScreenState extends ConsumerState<UnStakingInputScreen> {
  FocusNode quantityTextFocus = FocusNode();
  final _quantityController = TextEditingController();
  bool quantityTextFieldIsEmpty = true;
  bool agree_1 = false;
  bool agree_2 = false;
  String hintText = '00';
  String currentCoinUnit = 'RIGO';
  String stakingAmount = '00.00';
  String remainingAmount = '0';
  String validator = '';

  String typeText = '';

  Text unitText = Text(
    'RIGO',
    style: typo16regular.copyWith(color: GRAY_70),
  );

  @override
  WidgetRef get ref => context as WidgetRef;

  void setUI(BuildContext context) {
    StakingType stakingType =
        provider.Provider.of<StakesData>(context, listen: false).stakingType;
    Stakes stakes =
        provider.Provider.of<StakesData>(context, listen: false).stakes;
    if (stakingType == StakingType.unStaking) {
      typeText = TR(context, '스테이킹');
    } else {
      typeText = TR(context, '위임');
    }
    String stringAmount = stakes.power!;
    //stakingAmount = stringAmount.substring(0, stringAmount.length - 2); // TODO : check
    stakingAmount = stringAmount;
    _quantityController.text = stakingAmount;

    validator = getShortAddressText(stakes.to!, 6);
  }

  Future<Map<String, dynamic>> getAmount(bool isDelegate) async {
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;
    String result;
    if (isDelegate) {
      result = await JsonRpcService().getDelegateAmount(networkModel);
    } else {
      result = await JsonRpcService().getStakesAmount(networkModel);
    }

    String formattedResult = getFormattedText(value: double.parse(result));
    double remainingResult =
        (double.parse(result) - double.parse(stakingAmount));
    remainingAmount = getFormattedText(value: remainingResult);

    return {'amount': formattedResult, 'remainingAmount': remainingAmount};
  }

  @override
  void initState() {
    super.initState();
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
    bool isDelegate = stakingType == StakingType.unDelegate;

    log('--> languageCode: ${ref.read(languageProvider).getLocale!.languageCode}');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          '$typeText ${TR(context, '종료')}',
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
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        FutureBuilder(
                            future: getAmount(isDelegate),
                            builder: (BuildContext buildContext,
                                AsyncSnapshot<Map<String, dynamic>> snapshot) {
                              if (snapshot.hasData) {
                                return Column(
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
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      controller: _quantityController,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 4),
                                        border: grayBorder,
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 20.0),
                                          child: Text(
                                            currentCoinUnit,
                                            style: typo16regular,
                                          ),
                                        ),
                                        suffixIconConstraints: BoxConstraints(
                                            minWidth: 0, minHeight: 0),
                                      ),
                                      style: typo18semibold,
                                      textAlign: TextAlign.end,
                                      inputFormatters: [
                                        CurrencyInputFormatter(
                                          trailingSymbol: '',
                                          thousandSeparator:
                                              ThousandSeparator.Comma,
                                          mantissaLength: 2,
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '$typeText ${TR(context, '보유량')}',
                                          style: typo14medium.copyWith(
                                              color: GRAY_50),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          snapshot.data!['amount'],
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
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Gray5RoundContainer(
                                      child: Column(
                                        children: [
                                          if (isDelegate)
                                            DetailRow(
                                              title: TR(context, '검증인'),
                                              content: Text(
                                                validator,
                                                style: typo18semibold.copyWith(
                                                    color: SECONDARY_90),
                                              ),
                                            ),
                                          DetailRow(
                                            title: '$typeText ${TR(context, '종료 금액')}',
                                            content: Row(
                                              children: [
                                                Text(
                                                  stakingAmount,
                                                  style: typo16medium.copyWith(
                                                      color: isDelegate
                                                          ? GRAY_90
                                                          : PRIMARY_90),
                                                ),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                unitText,
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '${TR(context, '남은')} $typeText${TR(context, ' 금액')}',
                                                style: typo16medium.copyWith(
                                                    color: GRAY_70),
                                              ),
                                              Spacer(),
                                              Row(
                                                children: [
                                                  Text(
                                                    snapshot.data![
                                                        'remainingAmount'],
                                                    style: typo16medium,
                                                  ),
                                                  SizedBox(
                                                    width: 4,
                                                  ),
                                                  unitText
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Center(
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                );
                              }
                            }),
                        Divider(
                          height: 1,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        CustomCheckbox(
                          title: '$typeText${TR(context, ' 기능 이용 주의사항')}',
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
                          localAuth: true,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        CustomCheckbox(
                          title: ref.read(languageProvider).getLocale!.languageCode == 'ko' ?
                            '$typeText의 위험을 이해하고 진행합니다' :
                            'Understand the risks of $typeText and proceed',
                          checked: agree_2,
                          pushed: false,
                          localAuth: true,
                          onChanged: (value) {
                            setState(() {
                              agree_2 = value!;
                            });
                          },
                        ),
                        SizedBox(
                          height: 40,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () {
                      context.pushNamed(StakingConfirmScreen.routeName);
                    },
                    child: Text(
                      TR(context, '다음'),
                      style: typo16bold.copyWith(
                          color: (agree_1 && agree_2) ? WHITE : GRAY_40),
                    ),
                    style: (agree_1 && agree_2)
                        ? primaryButtonStyle
                        : disableButtonStyle,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
