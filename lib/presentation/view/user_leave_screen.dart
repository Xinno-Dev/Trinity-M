import '../../../common/common_package.dart';

import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/back_button.dart';

class UserLeaveScreen extends ConsumerStatefulWidget {
  const UserLeaveScreen({super.key});
  static String get routeName => 'userleave';
  @override
  ConsumerState<UserLeaveScreen> createState() => _UserLeaveScreenState();
}

class _UserLeaveScreenState extends ConsumerState<UserLeaveScreen> {
  bool agree_1 = false, agree_2 = false, agree_3 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR('탈퇴하기'),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Spacer(),
                    SizedBox(height: 80.h),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 0),
                      child: Text(
                        TR('BYFFIN 월렛 이용을\n그만하시겠어요?'),
                        style: typo24bold150,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 0),
                      child: Text(
                        TR('탈퇴할 경우 더이상 서비스를 이용할 수 없으며\n아래 동의가 필요합니다.'),
                        style: typo16medium150,
                      ),
                    ),
                    // Spacer(),
                    SizedBox(height: 40.h),
                    CustomCheckbox(
                      title:
                      TR('보유중인 자산을 모두 확인했으며,\n이를 다른 지갑으로 이전할 수 있다는 안내를 확인했습니다'),
                      checked: agree_1,
                      onChanged: (agree) {
                        setState(() {
                          agree_1 = agree!;
                        });
                      },
                    ),
                    CustomCheckbox(
                      title:
                      TR('탈퇴 시 개인 키가 파기되어 회사 및 누구도 이전하지 않은 자산에 접근할 수 없으며 복구가 불가능함을 확인했습니다'),
                      checked: agree_2,
                      onChanged: (agree) {
                        setState(() {
                          agree_2 = agree!;
                        });
                      },
                    ),
                    CustomCheckbox(
                      title:
                      TR('이전하지 않은 자산의 소유권(소수점 7자리 이하 소량 잔고 포함)을 포함한 일체의 권리를 포기하는데 동의합니다'),
                      checked: agree_3,
                      onChanged: (agree) {
                        setState(() {
                          agree_3 = agree!;
                        });
                      },
                    ),
                    // Spacer(),
                    SizedBox(
                      height: 52.h,
                    ),
                    Center(
                      child: TextButton(
                        onPressed: (agree_1 && agree_2 && agree_3 == true)
                            ? () {}
                            : null,
                        child: Text(
                          TR('동의 후 탈퇴'),
                          style: typo14semibold.copyWith(
                              color: (agree_1 && agree_2 && agree_3 == true)
                                  ? PRIMARY_90
                                  : GRAY_30),
                        ),
                      ),
                    ),
                    Container(
                      width: 335.w,
                      height: 56,
                      margin: EdgeInsets.fromLTRB(20.r, 0, 20.r, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop();
                        },
                        child: Text(
                          TR('계속 이용하기'),
                          style: typo16bold.copyWith(color: GRAY_70),
                        ),
                        style: popupSecondaryButtonStyle.copyWith(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => GRAY_5,
                          ),
                          overlayColor: MaterialStateProperty.all(GRAY_5),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              // side: BorderSide(),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 34)
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({
    Key? key,
    this.onChanged,
    this.onPushnamed,
    required this.title,
    required this.checked,
  }) : super(key: key);

  final bool checked;
  final String title;

  final Function(bool?)? onChanged;
  final Function()? onPushnamed;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  late bool isChecked;

  @override
  Widget build(BuildContext context) {
    isChecked = widget.checked;
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: InkWell(
        onTap: () {
          setState(() => isChecked = !isChecked);
          widget.onChanged?.call(isChecked);
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(6, 8, 6, 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isChecked ? PRIMARY_90 : GRAY_30,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SvgPicture.asset(
                  'assets/svg/termsCheck.svg',
                  fit: BoxFit.scaleDown,
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 999,
                  text: TextSpan(
                    text: widget.title,
                    style: typo16medium150.copyWith(color: GRAY_60),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
