import '../../../common/const/widget/detail_row.dart';
import '../../../common/const/widget/gray_5_round_container.dart';
import '../../../common/const/widget/quantity_column.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/CustomCheckBox.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/const/widget/staking_list_radio_column.dart';
import '../../../common/const/widget/staking_waiting_column.dart';

class UnStakingBottomSheetScreen extends StatefulWidget {
  const UnStakingBottomSheetScreen({Key? key}) : super(key: key);

  @override
  State<UnStakingBottomSheetScreen> createState() =>
      _UnStakingBottomSheetScreenState();
}

class _UnStakingBottomSheetScreenState
    extends State<UnStakingBottomSheetScreen> {
  int selectListIndex = -1;
  int _currentPageIndex = 0;
  bool agree_1 = false;
  bool agree_2 = false;

  Text unitText = Text(
    'RIGO',
    style: typo16regular.copyWith(color: GRAY_70),
  );

  Widget currentScreen(context) {
    switch (_currentPageIndex) {
      case 0:
        return SelectStakingListScreen(context);
      case 1:
        return Column(
          children: [
            QuantityColumn(
              stakingType: ColumnType.unstaking,
            ),
            Gray5RoundContainer(
              child: Column(
                children: [
                  DetailRow(
                    title: TR('스테이킹 종료금액'),
                    content: Row(
                      children: [
                        Text(
                          '0',
                          style: typo16medium.copyWith(color: PRIMARY_90),
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
                        TR('남은 스테이킹 금액'),
                        style: typo16medium.copyWith(color: GRAY_70),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Text(
                            '1,100,000',
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
                    height: 8,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      '\$1,100.00',
                      style: typo14regular.copyWith(color: GRAY_50),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Gray5RoundContainer(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StakingWaitingColumn(
                        title: TR('스테이킹 대기'),
                        content: '2023년 4월 5일 14:00:00 (UTC +9)',
                      ),
                      StakingWaitingColumn(
                        title: TR('언스테이킹 대기'),
                        content: '2023년 9월 30일  17:30:55(UTC +9)',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              height: 1,
            ),
            SizedBox(
              height: 16,
            ),
            CustomCheckbox(
              title: TR('스테이킹 기능 이용 주의사항'),
              onChanged: (value) {
                setState(() {
                  agree_1 = value!;
                });
              },
              onPushnamed: () {},
              checked: agree_1,
            ),
            SizedBox(
              height: 16,
            ),
            CustomCheckbox(
              title: TR('스테이킹의 위험을 이해하고 진행합니다.'),
              checked: agree_2,
              pushed: false,
              localAuth: true,
              onChanged: (value) {
                setState(() {
                  agree_2 = value!;
                });
              },
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _currentPageIndex = 2;
                  });
                },
                child: Text(
                  '다음',
                  style: typo16bold.copyWith(
                      color: (agree_1 && agree_2) ? WHITE : GRAY_40),
                ),
                style: (agree_1 && agree_2)
                    ? primaryButtonStyle
                    : disableButtonStyle,
              ),
            )
          ],
        );
      case 2:
        return Container(
          color: Colors.yellow,
        );

      default:
        return Container();
    }
  }

  Column SelectStakingListScreen(context) {
    return Column(
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            TR('스테이킹 리스트 선택'),
            style: typo16semibold,
          ),
        ),
        StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  setModalState(() {
                    selectListIndex = 0;
                  });
                  setState(() {
                    selectListIndex = 0;
                  });
                },
                child: StakingListRadioColumn(
                  address: '0xB8fe...21F5eB',
                  ratio: '3.000',
                  amount: '155,342,222',
                  reward: '1078.8112',
                  index: 0,
                  value: selectListIndex,
                  isStaking: true,
                ),
              ),
              InkWell(
                onTap: () {
                  setModalState(() {
                    selectListIndex = 1;
                  });
                  setState(() {
                    selectListIndex = 1;
                  });
                },
                child: StakingListRadioColumn(
                  address: '0x23DE...Dd34CS',
                  ratio: '2.976',
                  amount: '123,123,123',
                  reward: '930.0202',
                  index: 1,
                  value: selectListIndex,
                  isStaking: true,
                ),
              ),
            ],
          );
        }),
        Spacer(),
        selectListIndex < 0
            ? DisabledButton(
                text: TR('다음'),
                onTap: () {},
              )
            : PrimaryButton(
                text: TR('다음'),
                onTap: () {
                  setState(() {
                    _currentPageIndex = 1;
                  });
                },
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return currentScreen(context);
        },
      ),
    );
  }
}
