import '../../common_package.dart';

class DisabledButton extends StatelessWidget {
  DisabledButton({
    super.key,
    required this.text,
    this.onTap,
    this.round,
    this.height,
    this.isSmallButton = false,
  });

  final String text;
  final Function()? onTap;
  final bool isSmallButton;
  final double? round;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? (isSmallButton ? 40 : 56),
        decoration: BoxDecoration(
          color: GRAY_10,
          borderRadius: BorderRadius.circular(round ?? 8),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              text,
              style: typo16bold.copyWith(color: GRAY_40),
            ),
          ),
        ),
      ),
    );
  }
}
