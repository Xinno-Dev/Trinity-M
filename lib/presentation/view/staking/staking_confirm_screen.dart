import 'dart:developer';

import 'package:auto_size_text_plus/auto_size_text.dart';
import '../../../common/common_package.dart';
import '../../../common/provider/stakes_data.dart';
import 'package:provider/provider.dart' as provider;

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/detail_row.dart';
import '../../../common/const/widget/gray_5_round_container.dart';
import '../../../common/provider/network_provider.dart';
import '../../../common/provider/temp_provider.dart';
import '../../../common/trxHelper.dart';
import '../../../domain/model/network_model.dart';
import '../../../domain/model/rpc/delegateInfo.dart';
import '../../../domain/model/rpc/governance_rule.dart';
import '../../../domain/model/rpc/staking_type.dart';
import '../../../services/json_rpc_service.dart';
import '../sign_password_screen.dart';

class StakingConfirmScreen extends StatelessWidget {
  StakingConfirmScreen({Key? key}) : super(key: key);
  static String get routeName => 'staking_confirm';
  String fee = '0.00000000';

  String getAppBarTitle(StakingType stakingType) {
    switch (stakingType) {
      case StakingType.staking:
        return '스테이킹';
      case StakingType.unStaking:
        return '스테이킹 종료';
      case StakingType.delegate:
        return '위임';
      case StakingType.unDelegate:
        return '위임 종료';
      default:
        return '';
    }
  }

  String getButtonText(StakingType stakingType) {
    switch (stakingType) {
      case StakingType.staking:
        return '스테이킹';
      case StakingType.unStaking:
        return '스테이킹 종료';
      case StakingType.delegate:
        return '다음';
      case StakingType.unDelegate:
        return '위임 종료';
      default:
        return '';
    }
  }

  Future<String> getFee(NetworkModel networkModel) async {
    GovernanceRule governanceRule =
    await JsonRpcService().getGovernanceRule(networkModel);
    BigInt gasPrice = BigInt.parse(governanceRule.gasPrice ?? '0');
    BigInt minTrxGas = BigInt.parse(governanceRule.minTrxGas ?? '0');
    fee = await TrxHelper().getAmount((gasPrice * minTrxGas).toString(), scale: 8);
    return fee;
  }

  /*
  Future<String> getFee(NetworkModel networkModel) async {
    GovernanceRule governanceRule =
        await JsonRpcService().getGovernanceRule(networkModel);
    fee = governanceRule.minTrxGas ?? '?';
    return fee;
  }
  */

  @override
  Widget build(BuildContext context) {
    StakingType stakingType =
        provider.Provider.of<StakesData>(context, listen: false).stakingType;
    Stakes stakes =
        provider.Provider.of<StakesData>(context, listen: false).stakes;
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context).networkModel;

    String getTotalAmount(Stakes stakes) {
      return (double.parse(stakes.power!) + double.parse(fee))
          .toStringAsFixed(8);
    }

    log('---> stakes : ${stakes.toJson()}');

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
          TR(getAppBarTitle(stakingType)),
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
              Text(
                TR('정보를 확인해 주세요'),
                style: typo20bold,
              ),
              SizedBox(height: 30.h),
              Gray5RoundContainer(
                child: FutureBuilder(
                    future: getFee(networkModel),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            if (stakingType == StakingType.delegate)
                            DetailResizeRow(
                              title: TR('검증인'),
                              content: stakes.owner != null ?
                              Text(
                                stakes.owner!,
                                style: typo16medium.copyWith(color: SECONDARY_90),
                              ): AutoSizeText(
                                '0x${stakes.to ?? ''}',
                                maxLines: 1,
                                style: typo16medium.copyWith(color: SECONDARY_90),
                              ),
                            ),
                            DetailQuantityRow(
                              title: TR('수수료(예상)'),
                              quantity: snapshot.data!,
                              unit: 'RIGO',
                            ),
                            DetailQuantityRow(
                              title: '${TR(getAppBarTitle(stakingType))} ${TR('수량')}',
                              quantity: DBL(stakes.power).toStringAsFixed(8),
                              unit: 'RIGO',
                            ),
                            Divider(
                              height: 1,
                              color: GRAY_80,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                children: [
                                  TotalStakingRow(
                                    title: TR('총 수량\n(수수료 포함)'),
                                    balance: getTotalAmount(stakes),
                                  ),
                                  // SizedBox(
                                  //   height: 8,
                                  // ),
                                  // Align(
                                  //   alignment: AlignmentDirectional.centerEnd,
                                  //   child: Text(
                                  //     '\$0',
                                  //     style: typo14regular.copyWith(
                                  //         color: GRAY_50),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          TR('오류가 발생했습니다. 다시 시도해주세요.'),
                          style: typo28bold,
                        );
                      } else {
                        return Center(
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              color: PRIMARY_90,
                            ),
                          ),
                        );
                      }
                    }),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () async {
                    provider.Provider.of<NavigationProvider>(context,
                            listen: false)
                        .navigateTo(SignPasswordScreen.routeName);
                    context
                        .pushNamed(SignPasswordScreen.routeName, queryParams: {
                      'receivedAddress': stakes.to,
                      'sendAmount': stakes.power,
                    });
                  },
                  child: Text(
                    TR(getButtonText(stakingType)),
                    style: typo16bold.copyWith(color: WHITE),
                  ),
                  style: primaryButtonStyle,
                ),
              )
            ],
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
        Row(
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
      ],
    );
  }
}
