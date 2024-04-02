import 'dart:developer';

import 'package:larba_00/common/const/utils/convertHelper.dart';
import 'package:larba_00/domain/model/rpc/delegateInfo.dart';
import 'package:larba_00/domain/model/rpc/validator.dart';
import 'package:larba_00/presentation/view/staking/staking_input_screen.dart';
import 'package:larba_00/presentation/view/staking/unstaking_input_screen.dart';
import 'package:provider/provider.dart' as provider;

import '../../../common/common_package.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/const/widget/staking_list_radio_column.dart';
import '../../../common/provider/network_provider.dart';
import '../../../common/provider/stakes_data.dart';
import '../../../common/provider/temp_provider.dart';
import '../../../common/trxHelper.dart';
import '../../../domain/model/network_model.dart';
import '../../../domain/model/rpc/staking_type.dart';
import '../../../services/json_rpc_service.dart';

enum ListType { staking, validators, delegatingValidators, delegate }

class SelectStakingListScreen extends StatefulWidget {
  const SelectStakingListScreen({Key? key, this.delegateAddress = ''})
      : super(key: key);
  static String get routeName => 'select_staking_list';
  final String delegateAddress;

  @override
  State<SelectStakingListScreen> createState() =>
      _SelectStakingListScreenState();
}

class _SelectStakingListScreenState extends State<SelectStakingListScreen> {
  int selectListIndex = -1;
  late final String appBarTitle, subTitle;
  late Function()? nextButtonPressed;
  String stakesTotalAmount = '';
  late Stakes selectedStake;

  void updateStakes() {
    provider.Provider.of<StakesData>(context, listen: false)
        .updateStakes(selectedStake);
  }

  void setUI() {
    StakingType stakingType =
        provider.Provider.of<StakesData>(context, listen: false).stakingType;
    switch (stakingType) {
      case StakingType.unStaking:
        appBarTitle = '스테이킹 종료';
        subTitle = '스테이킹 리스트 선택';
        nextButtonPressed = () {
          updateStakes();
          context.pushNamed(UnStakingInputScreen.routeName);
        };
        break;
      case StakingType.delegate:
        appBarTitle = '위임';
        subTitle = '검증인 선택';
        nextButtonPressed = () {
          updateStakes();
          context.pushNamed(StakingInputScreen.routeName);
        };
        break;
      case StakingType.unDelegate:
        if (widget.delegateAddress == '') {
          appBarTitle = '위임 종료';
          subTitle = '위임 중인 검증인 선택';
          nextButtonPressed = () {
            context.pushNamed(SelectStakingListScreen.routeName,
                queryParams: {'delegateAddress': selectedStake.to!});
          };
        } else {
          appBarTitle = '위임 종료';
          subTitle = '위임 리스트';
          nextButtonPressed = () {
            updateStakes();
            context.pushNamed(UnStakingInputScreen.routeName);
          };
        }
        break;
      case StakingType.transfer:
        break;
      case StakingType.staking:
        break;
    }
  }

  Future<void> getTotalStakesAmount() async {
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;
    DelegateInfo delegateInfo =
        await JsonRpcService().getDelegateInfo(networkModel);
    stakesTotalAmount = delegateInfo.totalPower ?? '0';
  }

  Future<List<Stakes>> getStakesList() async {
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;
    ResultStake resultStake =
        await JsonRpcService().getMyStakeList(networkModel);
    return resultStake.stakes;
  }

  // 위임중인 검증인
  Future<List<StakesAndReward>> getDelegatingValidatorsList() async {
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;
    ResultStakesAndReward resultStake =
        await JsonRpcService().getMyDelegateList(networkModel);
    List<ValidatorList> validatorList =
        await JsonRpcService().getValidators(networkModel);

    // stakes 리스트 중 validator가 같은 경우 합쳐서 보여 주어야 함
    Map<String, List<StakesAndReward>> groupedMap = {};

    // 1. to 속성 값을 기준으로 객체들을 그룹화
    for (var obj in resultStake.stakesAndReward) {
      if (groupedMap.containsKey(obj.stakes.to)) {
        groupedMap[obj.stakes.to]!.add(obj);
      } else {
        groupedMap[obj.stakes.to!] = [obj];
      }
    }

    List<StakesAndReward> result = [];
    BigInt initVal = new BigInt.from(0);
    String ratio = '0.00000';

    // 2. amount 값을 더하여 하나의 객체로 만듦
    for (var entry in groupedMap.entries) {
      String to = entry.key;
      List<StakesAndReward> group = entry.value;

      // 위임 금액 합계 (소수점 단위 고려?) (리고 단위)
      BigInt totalAmount = group.fold(initVal, (previousValue, element) {
        return BigInt.parse(element.stakes.power!) + previousValue;
      });

      // 보상량 합계 (폰즈 단위)
      BigInt totalReward = group.fold(initVal, (previousValue, element) {
        return BigInt.parse(element.reward!) + previousValue;
      });

      // 현재 계정이 위임한 검증인의 전체 스테이킹양 가져오기
      for (ValidatorList validator in validatorList) {
        if (to == validator.validators) {
          totalDelegateAmount = double.parse(validator.amount!);
          ratio = (totalAmount.toDouble() / totalDelegateAmount * 100)
              .toStringAsFixed(5);
        }
      }

      StakesAndReward newStakesAndReward = StakesAndReward(
        Stakes(to: to, power: totalAmount.toString()),
        ratio,
        reward: totalReward.toString(),
      );

      result.add(newStakesAndReward);
    }

    return result;
  }

  Future<List<Stakes>> getDelegateList(String address) async {
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;
    ResultStakesAndReward resultStakesAndReward =
        await JsonRpcService().getMyDelegateList(networkModel);
    List<Stakes> result = [];
    for (StakesAndReward sr in resultStakesAndReward.stakesAndReward) {
      if (sr.stakes.to == address) {
        result.add(sr.stakes);
      }
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    setUI();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getTotalStakesAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR(context, appBarTitle),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      backgroundColor: WHITE,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  TR(context, subTitle),
                  style: typo16semibold,
                ),
              ),
              Divider(),
              Expanded(
                child: getListWidget(context),
              ),
              selectListIndex < 0
                  ? DisabledButton(
                      text: TR(context, '다음'),
                      onTap: () {},
                    )
                  : PrimaryButton(
                      text: TR(context, '다음'),
                      onTap: nextButtonPressed,
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget getListWidget(BuildContext context) {
    StakingType stakingType =
        provider.Provider.of<StakesData>(context, listen: false).stakingType;
    switch (stakingType) {
      case StakingType.unStaking:
        return buildStakesListFutureBuilder();
      case StakingType.delegate:
        return buildValidatorsListFutureBuilder();
      case StakingType.unDelegate:
        if (widget.delegateAddress == '') {
          return buildDelegatingValidatorsListFutureBuilder();
        } else {
          return buildDelegateListFutureBuilder(widget.delegateAddress);
        }
      default:
        return Container();
    }
  }

  FutureBuilder<List<Stakes>> buildStakesListFutureBuilder() {
    return FutureBuilder(
      future: getStakesList(),
      builder: (BuildContext context, AsyncSnapshot<List<Stakes>> snapshot) {
        if (snapshot.hasData) {
          var showList = snapshot.data ?? [];
          showList.sort((a, b) => DBL(a.power) < DBL(b.power) ? 1 : -1);
          showList.forEach((e) => e.index = showList.indexOf(e));
          return ListView.builder(
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              Stakes stakes = showList[index];

              // 스테이킹 비율 계산
              double stakingRatio = double.parse(stakes.power!) /
                  double.parse(stakesTotalAmount) *
                  100;
              String StakingRatioText = stakingRatio.toStringAsFixed(3);
              String shortTxHash = getShortAddressText(stakes.txhash!, 6);
              String formattedAmount =
                  getFormattedText(value: double.parse(stakes.power!));
              String formattedReward = "0"; // TODO
              // String formattedReward = getFormattedText(
              //     value: double.parse(stakes.receivedReward!),
              //     decimalPlaces: DECIMAL_PLACES);
              var showIndex = stakes.index ?? 0;
              log('--> buildStakesListFutureBuilder : $showIndex');
              return InkWell(
                onTap: () {
                  setState(() {
                    selectListIndex = showIndex;
                    selectedStake = stakes;
                  });
                },
                child: StakingListRadioColumn(
                  isStaking: true,
                  address: shortTxHash,
                  ratio: StakingRatioText,
                  amount: formattedAmount,
                  reward: formattedReward,
                  index: showIndex,
                  value: selectListIndex,
                ),
              );
            },
            itemCount: showList.length,
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
      },
    );
  }

  FutureBuilder<List<ValidatorList>> buildValidatorsListFutureBuilder() {
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;
    double totalStakingAmount = 0.0;

    return FutureBuilder(
      future: JsonRpcService().getValidators(networkModel),
      builder:
          (BuildContext context, AsyncSnapshot<List<ValidatorList>> snapshot) {
        if (snapshot.hasData) {
          var showList = snapshot.data ?? [];
          totalStakingAmount = 0;
          for (ValidatorList validator in showList) {
            totalStakingAmount += double.parse(validator.amount!);
            LOG('----> totalStakingAmount : $totalStakingAmount');
          }
          showList.sort((a, b) => DBL(a.amount) < DBL(b.amount) ? 1 : -1);
          showList.forEach((e) => e.index = showList.indexOf(e));
          return ListView.builder(
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              ValidatorList validatorList = showList[index];
              String shortAddress =
                  getShortAddressText(validatorList.validators!, 6);
              double amount = double.parse(validatorList.amount!);

              String stakingRatio =
                  (amount / totalStakingAmount * 100).toStringAsFixed(3);
              String formattedAmount = getFormattedText(value: amount);
              var showIndex = validatorList.index ?? 0;
              log('--> buildValidatorsListFutureBuilder : $showIndex');
              return InkWell(
                onTap: () {
                  setState(() {
                    selectListIndex = showIndex;
                    selectedStake = Stakes(
                        power: validatorList.amount!,
                        to: validatorList.validators!);
                  });
                },
                child: StakingListRadioColumn(
                  isStaking: false,
                  address: shortAddress,
                  ratio: stakingRatio,
                  amount: formattedAmount,
                  reward: validatorList.rewardAmount!,
                  index: showIndex,
                  value: selectListIndex,
                ),
              );
            },
            itemCount: showList.length,
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
      },
    );
  }

  // 위임 종료
  FutureBuilder<List<StakesAndReward>>
      buildDelegatingValidatorsListFutureBuilder() {
    return FutureBuilder(
      future: getDelegatingValidatorsList(),
      builder: (BuildContext context,
          AsyncSnapshot<List<StakesAndReward>> snapshot) {
        if (snapshot.hasData) {
          var showList = snapshot.data ?? [];
          showList.sort((a, b) => DBL(a.stakes.power) < DBL(b.stakes.power) ? 1 : -1);
          showList.forEach((e) => e.index = showList.indexOf(e));
          return ListView.builder(
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              StakesAndReward sr = showList[index];
              String shortAddress = getShortAddressText(sr.stakes.to!, 6);
              String strAmount =
                  double.parse(sr.stakes.power!).toStringAsFixed(0);
              String reward = TrxHelper().getAmount(sr.reward ?? "0", scale: 8);
              String ratio = sr.ratio;
              var showIndex = sr.index ?? 0;
              log('--> buildDelegatingValidatorsListFutureBuilder : $showIndex');
              return InkWell(
                onTap: () {
                  setState(() {
                    selectListIndex = showIndex;
                    selectedStake =
                        Stakes(power: sr.stakes.power!, to: sr.stakes.to);
                  });
                },
                child: StakingListRadioColumn(
                  isStaking: false,
                  isUnDelegate: true,
                  address: shortAddress,
                  ratio: ratio,
                  amount: strAmount,
                  reward: reward, // TODO : stakes.receivedReward!,
                  index: showIndex,
                  value: selectListIndex,
                ),
              );
            },
            itemCount: showList.length,
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
      },
    );
  }

  // 위임 종료 - 위임 중인 검증인 선택 후 - 위임 리스트
  FutureBuilder<List<Stakes>> buildDelegateListFutureBuilder(String address) {
    return FutureBuilder(
      future: getDelegateList(address),
      builder: (BuildContext context, AsyncSnapshot<List<Stakes>> snapshot) {
        if (snapshot.hasData) {
          var showList = snapshot.data ?? [];
          showList.sort((a, b) => DBL(a.power) < DBL(b.power) ? 1 : -1);
          showList.forEach((e) => e.index = showList.indexOf(e));
          return ListView.builder(
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              Stakes stakes = showList[index];
              String shortAddress = getShortAddressText(stakes.txhash!, 6);
              String strAmount = double.parse(stakes.power!).toStringAsFixed(0);
              String ratio =
                  (double.parse(stakes.power!) / totalDelegateAmount * 100)
                      .toStringAsFixed(5);
              var showIndex = stakes.index ?? 0;
              log('--> buildDelegateListFutureBuilder : $showIndex');
              return InkWell(
                onTap: () {
                  setState(() {
                    selectListIndex = showIndex;
                    selectedStake = Stakes(
                        power: stakes.power!,
                        to: stakes.to,
                        txhash: stakes.txhash);
                  });
                },
                child: StakingListRadioColumn(
                  isStaking: false,
                  isUnDelegate: true,
                  address: shortAddress,
                  ratio: ratio,
                  amount: strAmount,
                  reward: "0", // TODO : stakes.receivedReward!
                  index: showIndex,
                  value: selectListIndex,
                ),
              );
            },
            itemCount: showList.length,
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
      },
    );
  }
}
