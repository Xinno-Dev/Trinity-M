import '../../common_package.dart';
import '../utils/languageHelper.dart';
import 'custom_badge.dart';

class ValidatorsListColumn extends StatelessWidget {
  const ValidatorsListColumn({
    super.key,
    required this.address,
    required this.stakingRatio,
    required this.totalAmount,
    required this.dailyReward,
    required this.rank,
  });

  final int rank;
  final String address, stakingRatio, totalAmount, dailyReward;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Medal(rank: rank),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    address,
                    style: typo16semibold,
                  ),
                  Spacer(),
                  CustomBadge(isSmall: true, text: TR('스테이킹 비율')),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    stakingRatio,
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
                    TR('총 스테이킹'),
                    style: typo14medium.copyWith(color: GRAY_50),
                  ),
                  Spacer(),
                  Text(
                    totalAmount,
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
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Text(
                    TR('보상량'),
                    style: typo14medium.copyWith(color: GRAY_50),
                  ),
                  Spacer(),
                  Text(
                    dailyReward,
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

  get medalColor {
    if (rank == 1) return Color.fromRGBO(255, 168, 53, 1);
    if (rank == 2) return Color.fromRGBO(191, 191, 191, 1);
    if (rank == 3) return Color.fromRGBO(226, 146, 86, 1);
    return SUB_90;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(color: medalColor, shape: BoxShape.circle),
        child: Center(
          child: Text(
            rank.toString(),
            style: medalStyle,
          ),
        ),
      ),
    );
  }
}
