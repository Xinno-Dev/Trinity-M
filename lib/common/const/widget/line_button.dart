import '../../common_package.dart';

class LineButton extends StatelessWidget {
  const LineButton({
    super.key,
    required this.text,
    this.onTap,
    this.color,
    this.textColor,
    this.padding,
    this.isSmallButton = false,
  });

  final String text;
  final Color? color;
  final Color? textColor;
  final double? padding;
  final bool isSmallButton;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isSmallButton ? 36.h : 56.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color ?? PRIMARY_90, width: 1),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding ?? 20.0),
            child: Text(
              text,
              style: typo16bold.copyWith(color: textColor ?? PRIMARY_90, fontSize: isSmallButton ? 12 : 16),
            ),
          ),
        ),
      ),
    );
  }
}
