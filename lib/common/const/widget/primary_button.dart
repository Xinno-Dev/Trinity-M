import '../../common_package.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.icon,
    this.afterIcon,
    this.width,
    this.round,
    this.color,
    this.textStyle,
    this.isSmallButton = false,
    this.isBorderShow = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.onTap,
  });

  final String text;
  final double? width;
  final double? round;
  final Color? color;
  final Widget? icon;
  final Widget? afterIcon;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final bool isSmallButton;
  final bool isBorderShow;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: isSmallButton ? 40.h : 56.h,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? PRIMARY_100,
          borderRadius: BorderRadius.circular(round ?? 8),
          border: isBorderShow ? Border.all(width: 1, color: GRAY_30) : Border(),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)...[
                icon!,
                SizedBox(width: 5),
              ],
              Text(text,
                style: textStyle ?? typo16bold.copyWith(color: WHITE),
              ),
              if (afterIcon != null)...[
                SizedBox(width: 5),
                afterIcon!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}