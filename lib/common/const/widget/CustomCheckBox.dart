import 'package:auto_size_text_plus/auto_size_text.dart';
import 'package:larba_00/common/common_package.dart';

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({
    Key? key,
    this.onChanged,
    this.onPushnamed,
    this.pushed = true,
    this.localAuth = false,
    this.height = 40,
    required this.title,
    required this.checked,
  }) : super(key: key);

  final bool checked;
  final String title;
  final bool pushed;
  final bool localAuth;
  final double height;
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
    return InkWell(
      onTap: () {
        setState(() => isChecked = !isChecked);
        widget.onChanged?.call(isChecked);
      },
      child: Container(
      height: widget.height.h,
      child: Row(
        children: [
          SizedBox(
            height: 34.h,
          ),
          Container(
              width: 18.r,
              height: 18.r,
              decoration: BoxDecoration(
                color: isChecked ? PRIMARY_90 : GRAY_20,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: SvgPicture.asset(
                'assets/svg/termsCheck.svg',
                fit: BoxFit.scaleDown,
              )),
          SizedBox(
            width: 8.w,
          ),
          Expanded(child:
            AutoSizeText(
              widget.title,
              style: widget.pushed
                ? typo16medium.copyWith(color: isChecked ? GRAY_90 : GRAY_60)
                : widget.localAuth
                    ? typo16medium.copyWith(
                        color: isChecked ? GRAY_90 : GRAY_60,
                      )
                    : typo18semibold.copyWith(color: GRAY_60),
              maxLines: 1,
              minFontSize: 12,
              maxFontSize: 16,
              stepGranularity: 2,
            )
          ),
          if (widget.pushed)...[
            // Spacer(),
            SizedBox(width: 5.w),
            SizedBox(
              height: 34.h,
              width: 34.h,
              child: TextButton(
                onPressed: widget.onPushnamed,
                child: SvgPicture.asset(
                  'assets/svg/arrow.svg',
                  width: 30.r,
                  height: 30.r,
                ),
              )),
            ],
        ],
      )
      ),
    );
  }
}