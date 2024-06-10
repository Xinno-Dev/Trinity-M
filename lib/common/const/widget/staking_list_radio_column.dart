import '../../common_package.dart';
import '../utils/languageHelper.dart';
import 'custom_badge.dart';

class StakingListRadioColumn extends StatelessWidget {
  const StakingListRadioColumn({
    super.key,
    required this.address,
    required this.ratio,
    required this.amount,
    required this.reward,
    required this.value,
    required this.index,
    this.isRadio = true,
    this.rank = 0,
    required this.isStaking,
    this.isUnDelegate = false,
  });

  final int value, index, rank;
  final String address, ratio, amount, reward;
  final bool isRadio, isStaking, isUnDelegate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              Row(
                children: [
                  isRadio
                      ? Image(
                          width: 16.w,
                          color: (value == index) ? SECONDARY_90 : null,
                          image:
                              AssetImage('assets/images/radio_button_off.png'),
                        )
                      : Medal(rank: rank),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    address,
                    style: typo16semibold,
                  ),
                  Spacer(),
                  CustomBadge(
                    isSmall: true,
                    text: TR(isUnDelegate ? '지분 비율' : '스테이킹 비율')),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    ratio,
                    style: typo14medium.copyWith(color: SECONDARY_90),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    '%',
                    style: typo14regular.copyWith(color: SECONDARY_90),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    TR(isStaking ? '총 스테이킹' : '위임 금액'),
                    style: typo14medium.copyWith(color: GRAY_50),
                  ),
                  Spacer(),
                  Text(
                    amount,
                    style: typo16semibold,
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
              if (!isUnDelegate)
                Column(
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Text(
                          TR(isStaking ? '일일 보상량' : '보상량'),
                          style: typo14medium.copyWith(color: GRAY_50),
                        ),
                        Spacer(),
                        Text(
                          reward,
                          style: typo14medium,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          'RIGO',
                          style: typo14regular.copyWith(color: GRAY_70),
                        ),
                      ],
                    ),
                  ],
                )
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }
}

class Medal extends StatelessWidget {
  const Medal({
    super.key,
    required this.rank,
  });

  final int rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      decoration: BoxDecoration(color: SUB_90, shape: BoxShape.circle),
      child: Text(
        rank.toString(),
        style: medalStyle,
      ),
    );
  }
}
