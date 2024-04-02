import '../../../common/common_package.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/CustomCheckBox.dart';
import '../../../common/const/widget/SimpleCheckDialog.dart';
import '../../../common/const/widget/detail_row.dart';
import '../../../common/const/widget/gray_5_round_container.dart';
import '../../../common/const/widget/quantity_column.dart';

class StakingBottomSheetScreen extends StatefulWidget {
  const StakingBottomSheetScreen({Key? key}) : super(key: key);

  @override
  State<StakingBottomSheetScreen> createState() =>
      _StakingBottomSheetScreenState();
}

class _StakingBottomSheetScreenState extends State<StakingBottomSheetScreen> {
  FocusNode quantityTextFocus = FocusNode();
  final _quantityController = TextEditingController();
  bool _showFirstScreen = true;
  bool quantityTextFieldIsEmpty = true;
  bool agree_1 = false;
  bool agree_2 = false;
  String hintText = '00.00';
  String sendAmount = '0.00000000';
  String currentCoinUnit = 'RIGO';

  @override
  void initState() {
    super.initState();
    quantityTextFocus.addListener(() {
      if (quantityTextFocus.hasFocus) {
        hintText = '';
      } else {
        hintText = '00.00';
      }
      //setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _quantityController.dispose();
  }

  void _toggleScreen() {
    setState(() {
      _showFirstScreen = !_showFirstScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: _showFirstScreen
          ? GestureDetector(
              onTap: () {
                quantityTextFocus.unfocus();
              },
              child: Column(
                children: [
                  QuantityColumn(
                    stakingType: ColumnType.staking,
                  ),
                  Gray5RoundContainer(
                    child: Column(
                      children: [
                        DetailQuantityRow(
                          title: TR(context, '금액'),
                          quantity: '0',
                          unit: 'RIGO',
                        ),
                        DetailQuantityRow(
                          title: TR(context, '연 수익율'),
                          quantity: '85.25',
                          unit: 'RIGO',
                        ),
                        DetailQuantityRow(
                          title: TR(context, '예상 수익(연)'),
                          quantity: '0',
                          unit: 'RIGO',
                        ),
                        Divider(
                          height: 1,
                          color: GRAY_20,
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        TotalStakingRow(
                          title: TR(context, '총 스테이킹 금액'),
                          balance: '1,100,000',
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            '\$1,000.00',
                            style: typo14regular.copyWith(color: GRAY_50),
                          ),
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
                    title: TR(context, '스테이킹 기능 이용 주의사항'),
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
                    title: TR(context, '스테이킹의 위험을 이해하고 진행합니다.'),
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
                        _toggleScreen();
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
            )
          : StakingConfirmBottomSheet(),
    );
  }
}

class StakingConfirmBottomSheet extends StatelessWidget {
  StakingConfirmBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gray5RoundContainer(
          child: Column(
            children: [
              DetailQuantityRow(
                title: TR(context, '가스(예상치)'),
                quantity: '500.00',
                unit: 'RIGO',
              ),
              DetailQuantityRow(
                title: TR(context, '최대요금'),
                quantity: '600.00',
                unit: 'RIGO',
              ),
              Divider(
                height: 1,
                color: GRAY_20,
              ),
              SizedBox(
                height: 24,
              ),
              TotalStakingRow(
                title: TR(context, '합계'),
                balance: '100,500',
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  '\$1,000.00',
                  style: typo14regular.copyWith(color: GRAY_50),
                ),
              ),
            ],
          ),
        ),
        Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleCheckDialog(
                    infoString: TR(context, '100,000개의 RIGO 토큰의\n스테이킹이 완료되었습니다.'),
                  );
                },
              );
            },
            child: Text(
              TR(context, '스테이킹'),
              style: typo16bold.copyWith(color: WHITE),
            ),
            style: primaryButtonStyle,
          ),
        )
      ],
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
              '1,000,000',
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
