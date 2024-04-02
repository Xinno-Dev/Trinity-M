import 'package:auto_size_text_plus/auto_size_text.dart';
import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/widget/back_button.dart';

import 'package:provider/provider.dart' as provider;

import '../../../common/const/utils/languageHelper.dart';
import '../../../common/provider/language_provider.dart';
import '../../../common/provider/stakes_data.dart';
import '../../../domain/model/rpc/staking_type.dart';

class StakingCautionScreen extends ConsumerStatefulWidget {
  StakingCautionScreen({Key? key}) : super(key: key);

  static String get routeName => 'staking_caution';

  @override
  ConsumerState<StakingCautionScreen> createState() => _StakingCautionScreen();
}

class _StakingCautionScreen extends ConsumerState<StakingCautionScreen> {
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

  String getDescription(StakingType stakingType, String language) {
    // switch (stakingType) {
    //   case StakingType.staking:
    //   case StakingType.unStaking:
        return language == 'ko' ? '''
	•	스테이킹은 블록체인에서 새로운 블록을 생성하고 트랜잭션을 검증하는 데 사용되는 서비스를 의미합니다. 자산을 검증인에게 위임하여 스테이킹에 참여하는 자를 위임인이라고 부르고 위임인에게 위임을 받아 검증 작업에 참여하는 자를 검증인이라고 합니다. 바이핀 스테이킹은 검증인에게 자산을 위임하는 방식의 스테이킹 서비스를 제공합니다.

	•	위임을 신청한 디지털 자산은 스테이킹 신청 시부터 위임 철회가 완료되기 전까지 계정 내 보유 자산 및 출금 가능 자산에서 제외됩니다.  

	•	위임 보상은 블록체인 네트워크 상황에 따라 상시 변동합니다. 회사는 이에 관여할 수 없고, 보상 수준에 대해 어떠한 보장도 하지 않습니다.  

	•	서비스와 무관하게 디지털 자산 자체의 시세변동이 발생할 수 있으며, 서비스 이용 중 디지털 자산 시세 변동에 의한 손실은 회사에서는 책임지지 않습니다.  

	•	블록체인 네트워크의 지연, 오류, 점검 등에 문제가 발생한 경우, 본 서비스 관련 디지털 자산의 입출금 등이 일시적으로 제한될 수 있습니다. 

	•	회원은 본 서비스와 관련한 회원의 권리의 전부나 일부 또는 그 계약상 지위를 제삼자에게 이전, 양도, 담보제공 등 여하의 방법으로 처분할 수 없습니다.  

	•	다른 검증인에게 지분 이전은 불가하며, 위임 철회 후 새로 위임을 하셔야 합니다.
 
	•	위임 철회 시 수량은 위임 철회 대기 상태로 변경되며 최소 30일에서 최대 90일간 사용이 불가합니다. 위임 철회 수량에 대해서는 이자가 발생하지 않습니다.

	•	검증인 위임 방식의 스테이킹은 투자 방식 중 하나이며, 부주의하게 진행할 경우 손실을 입을 수 있습니다. 따라서 스테이킹을 진행하기 전에 원리와 리워드 수령 방식, 수수료율, 예치하는 자산의 안정성과 위험성, 자금 운용 계획 등을 충분히 검토하고 신중하게 판단하여 진행해야 합니다. 
    ''' : '''
	•	Staking refers to a service used in blockchain to create new blocks and validate transactions. Those delegating assets to validators for participation in staking are called delegators, while those participating in the validation tasks by receiving delegations from delegators are called validators. Byfin Staking provides a staking service by delegating assets to validators.
	
	•	Digital assets applied for delegation are excluded from the held and withdrawable assets within the account from the time of delegation application until the withdrawal process is completed.
	
	•	Delegation rewards fluctuate constantly based on the blockchain network situation. The company cannot control this and does not guarantee any specific reward level.
	
	•	Despite the service, fluctuations in the value of digital assets themselves may occur. The company is not responsible for losses due to fluctuations in digital asset prices during service usage.
	
	•	In case of issues like delays, errors, or maintenance in the blockchain network, transactions involving digital assets related to this service might temporarily be restricted.
	
	•	Members are prohibited from transferring, assigning, or providing any third party with all or part of their rights or position in connection with this service by any means.
	
	•	Transferring stakes to other validators is not possible. After withdrawal, a new delegation needs to be made.
	
	•	When withdrawing, the quantity will be set to a withdrawal waiting status for a minimum of 30 days and a maximum of 90 days. No interest accrues on the withdrawn quantity.
	
	•	Staking through validator delegation is one investment method, and careless engagement may result in losses. Therefore, thoroughly review the principles, reward collection methods, fee rates, stability, and risks associated with deposited assets, as well as financial operating plans, before proceeding with staking.
    ''';
    // }
  }

  @override
  Widget build(BuildContext context) {
    StakingType stakingType =
        provider.Provider.of<StakesData>(context, listen: false).stakingType;
    var language = ref.read(languageProvider).getLocale!.languageCode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: () {
            context.pop();
          },
        ),
        centerTitle: true,
        title: Row(
          children: [
            Expanded(child:
              AutoSizeText(
                '${TR(context, getAppBarTitle(stakingType))} ${TR(context, '기능 이용 주의 사항')}',
                style: typo18semibold,
                maxLines: 1,
                textAlign: TextAlign.center,
              )
            ),
            SizedBox(width: 40.w),
          ],
        ),
        titleSpacing: 0,
        elevation: 0,
      ),
      backgroundColor: WHITE,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Expanded(child:
              ListView(
                shrinkWrap: true,
                children: [
                  Text(
                      TR(context, getDescription(stakingType, language)),
                      maxLines: null,
                  )
                ]
              )),
              SizedBox(height: 20.h),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/icon_warning.svg',
                    width: 20.r,
                    height: 20.r,
                  ),
                  Expanded(child: AutoSizeText(
                    TR(context,
                        '스테이킹 신청 시, 취소 또는 변경 하실 수 없습니다.'),
                    style: typo14medium,
                    maxLines: 1,
                  ))
                ],
              )
            ],
          )
        )
      )
    );
  }
}