import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_10_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/provider/stakes_data.dart';
import '../../../common/provider/temp_provider.dart';
import '../../../domain/model/rpc/governance_rule.dart';
import '../../../presentation/view/staking/select_staking_list_screen.dart';
import '../../../presentation/view/staking/staking_input_screen.dart';
import '../../../services/json_rpc_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;

import '../../../common/common_package.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/balance_row.dart';
import '../../../common/provider/language_provider.dart';
import '../../../common/provider/network_provider.dart';
import '../../../domain/model/network_model.dart';
import '../../../domain/model/rpc/delegateInfo.dart';
import '../../../domain/model/rpc/staking_type.dart';
import '../signup/login_screen.dart';

class StakingScreen extends ConsumerStatefulWidget {
  const StakingScreen({Key? key, required this.stakingType}) : super(key: key);
  final StakingType stakingType;

  @override
  ConsumerState<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends ConsumerState<StakingScreen> with WidgetsBindingObserver {
  late String typeText, cancelButtonText;
  String totalReward = '0.0';
  String stakingTime = '';
  String unStakingMinTime = '';
  String unStakingMaxTime = '';

  @override
  WidgetRef get ref => context as WidgetRef;

  bool hasAmount = false;

  void setUI(context) {
    if (widget.stakingType == StakingType.staking) {
      typeText = '_스테이킹';
      cancelButtonText = '스테이킹 종료';
    } else {
      typeText = '_위임';
      cancelButtonText = '위임 종료';
    }
  }

  Future<String> getAmount() async {
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;
    if (widget.stakingType == StakingType.staking) {
      return await JsonRpcService().getStakesAmount(networkModel);
    } else {
      // 위임의 경우
      return await JsonRpcService().getDelegateAmount(networkModel);
    }
  }

  Future<String> getFormattedAmount() async {
    StateController<bool> isError = ref.read(errorProvider.notifier);

    try {
      String amount = await getAmount();
      isError.state = false;
      return getFormattedText(value: double.parse(amount));
    } catch (err) {
      isError.state = true;
      throw 'getAmount Error : $err';
    }
  }

  Future<bool> calculateHasAmount() async {
    String amount = await getAmount();
    double doubleAmount = double.parse(amount);
    return (doubleAmount > 0);
  }

  Future<Map<String, dynamic>> getRewardAmount() async {
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;

    // DelegateInfo delegateInfo = await JsonRpcService().getDelegateInfo(networkModel);
    // String stakingReward = delegateInfo.rewardAmount ?? '0';
    //ResultStake resultStake = await JsonRpcService().getMyDelegateList(networkModel);
    //String delegateReward = resultStake.receivedReward;
    //double total = double.parse(stakingReward) + double.parse(delegateReward);
    //totalReward = total.toStringAsFixed(2);

    ResultStake resultMyStake = await JsonRpcService().getMyStakeList(networkModel);
    String stakingReward = resultMyStake.receivedReward;

    ResultStakesAndReward resultMyDelegate = await JsonRpcService().getMyDelegateList(networkModel);
    String delegateReward = resultMyDelegate.receivedReward;
    double delegateReward2 = double.parse(delegateReward);

    double total = double.parse(stakingReward) + delegateReward2;
    totalReward = total.toStringAsFixed(8);

    if (widget.stakingType == StakingType.staking) {
      return {'rewardAmount': stakingReward, 'total': totalReward};
    } else {
      String delegateReward3 = delegateReward2.toStringAsFixed(8);
      return {'rewardAmount': delegateReward3, 'total': totalReward};
    }
  }

  Future<void> getTime() async {
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;
    JsonRpcService service = JsonRpcService();
    GovernanceRule rule = await service.getGovernanceRule(networkModel);
    print(rule.lazyRewardBlocks);
    DateTime now = DateTime.now();
    DateTime minTime =
        now.add(Duration(seconds: int.parse(rule.lazyRewardBlocks!)));
    DateTime maxTime =
        now.add(Duration(seconds: int.parse(rule.lazyRewardBlocks!) * 3));

    DateFormat formatter = DateFormat(
        ref.read(languageProvider).isKor ?
        'yyyy년 M월 d일 HH:mm:ss (\'UTC\' +9)' :
        'M-d-yyyy HH:mm:ss (\'UTC\' +9)');

    setState(() {
      stakingTime = formatter.format(now);
      unStakingMinTime = formatter.format(minTime);
      unStakingMaxTime = formatter.format(maxTime);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('---> didChangeAppLifecycleState : $state');
    if (IS_AUTO_LOCK_MODE && state == AppLifecycleState.inactive) {
      setState(() {
        context.goNamed(LoginScreen.routeName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    setUI(context);
    // Provider를 이용해 다시 build가 되게 하기 위함
    provider.Provider.of<NavigationProvider>(context).currentRoute;

    return Container(
      color: BG,
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            WhiteContainerWithTitle(
              title: '${TR(context, '내')} ${TR(context, typeText)} ${TR(context, '_수량')}',
              children: [
                FutureBuilder<String>(
                  future: getFormattedAmount(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return Row(
                        children: [
                          Text(
                            snapshot.data!,
                            style: typo18semibold,
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            'RIGO',
                            style: typo16regular,
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      hasAmount = false;
                      return BalanceRow(balance: '0');
                    } else {
                      return SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                // Row(
                //   children: [
                //     CustomBadge(text: '총 연수익률'),
                //     SizedBox(
                //       width: 8,
                //     ),
                //     Text(
                //       '5~15',
                //       style: typo16semibold.copyWith(color: SECONDARY_90),
                //     ),
                //     SizedBox(
                //       width: 4,
                //     ),
                //     Text(
                //       '%',
                //       style: typo16semibold.copyWith(color: SECONDARY_90),
                //     ),
                //   ],
                // ),
                // SizedBox(
                //   height: 16,
                // ),
                // StakingWaitingColumn(
                //   title: '스테이킹 대기',
                //   content: stakingTime,
                // ),
                // Divider(
                //   height: 1,
                // ),
                // StakingWaitingColumn(
                //   title: '언스테이킹 대기',
                //   content: unStakingMinTime + '\n~' + unStakingMaxTime,
                // ),
                // SizedBox(
                //   height: 16,
                // ),
                buildButtonRow(context),
              ],
            ),
            WhiteContainerWithTitle(
              title: '${TR(context, '내')} ${TR(context, typeText)} ${TR(context, '보상')}',
              children: [
                FutureBuilder<Map<String, dynamic>>(
                    future: getRewardAmount(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (snapshot.hasData) {
                        Map<String, dynamic> data = snapshot.data!;
                        return RewardColumn(
                          reward: data['rewardAmount'],
                          totalReward: data['total'],
                        );
                      } else if (snapshot.hasError) {
                        return RewardColumn(reward: '0', totalReward: '0');
                      } else {
                        return SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              ],
            ),
            SizedBox(height: 160),
          ],
        ),
      ),
    );
  }

  // 여기서 버튼을 누를때 StakingType은 결정난다!
  FutureBuilder<bool> buildButtonRow(BuildContext context) {
    // 이 줄의 stakingType은 스테이킹/위임 탭 구분시 넘어 오는 파라메터
    StakingType stakingType = widget.stakingType;

    return FutureBuilder(
        future: calculateHasAmount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              bool hasAmount = snapshot.data!;
              return Row(
                children: [
                  // 언스테이킹/위임 종료 버튼
                  Expanded(
                    child: hasAmount
                        ? Primary10Button(
                            text: TR(context, cancelButtonText),
                            onTap: () {
                              if (stakingType == StakingType.staking) {
                                provider.Provider.of<StakesData>(context,
                                        listen: false)
                                    .updateStakingType(StakingType.unStaking);
                              } else {
                                provider.Provider.of<StakesData>(context,
                                        listen: false)
                                    .updateStakingType(StakingType.unDelegate);
                              }
                              context.pushNamed(
                                  SelectStakingListScreen.routeName,
                                  queryParams: {'delegateAddress': ''});
                            },
                          )
                        : DisabledButton(
                            text: TR(context, cancelButtonText),
                            // isSmallButton: true,
                          ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  // 스테이킹/위임 버튼
                  Expanded(
                    child: PrimaryButton(
                        text: TR(context, typeText),
                        onTap: () {
                          provider.Provider.of<StakesData>(context,
                                  listen: false)
                              .updateStakes(Stakes());

                          if (stakingType == StakingType.staking) {
                            provider.Provider.of<StakesData>(context,
                                    listen: false)
                                .updateStakingType(stakingType);
                            context.pushNamed(StakingInputScreen.routeName);
                          } else {
                            provider.Provider.of<StakesData>(context,
                                    listen: false)
                                .updateStakingType(StakingType.delegate);
                            context.pushNamed(SelectStakingListScreen.routeName,
                                queryParams: {'delegateAddress': ''});
                          }
                        }),
                  ),
                ],
              );
            }
          }
        });
  }
}

class RewardColumn extends StatelessWidget {
  const RewardColumn({
    super.key,
    required this.reward,
    required this.totalReward,
  });

  final String reward, totalReward;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              reward,
              style: typo18semibold.copyWith(color: PRIMARY_90),
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              'RIGO',
              style: typo16regular.copyWith(color: GRAY_70),
            ),
          ],
        ),
        // SizedBox(
        //   height: 17,
        // ),
        // Divider(
        //   height: 1,
        // ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 17.0),
        //   child: Row(
        //     children: [
        //       Text(
        //         '보상금액 총합',
        //         style: typo14semibold.copyWith(color: GRAY_70),
        //       ),
        //       Spacer(),
        //       Row(
        //         children: [
        //           Text(
        //             totalReward,
        //             style: typo16medium,
        //           ),
        //           SizedBox(
        //             width: 4,
        //           ),
        //           Text(
        //             'RIGO',
        //             style: typo16regular.copyWith(color: GRAY_70),
        //           ),
        //         ],
        //       )
        //     ],
        //   ),
        // ),
        // Gray5RoundContainer(
        //   isNotification: true,
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       SvgPicture.asset(
        //         'assets/svg/icon_info.svg',
        //         height: 16.0,
        //       ),
        //       SizedBox(
        //         width: 4,
        //       ),
        //       Text(
        //         '보상금액의 총합은 스테이킹과 위임한 보상 금액의\n합계 입니다.',
        //         style: typo12medium150.copyWith(color: GRAY_70),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class WhiteContainerWithTitle extends StatelessWidget {
  const WhiteContainerWithTitle(
      {Key? key, required this.title, required this.children})
      : super(key: key);

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: WHITE,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: typo18semibold,
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            )
          ],
        ),
      ),
    );
  }
}
