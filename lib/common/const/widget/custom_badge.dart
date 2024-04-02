import '../../common_package.dart';

class CustomBadge extends StatelessWidget {
  const CustomBadge({
    required this.text,
    this.isSmall = false,
  });

  final String text;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: SUB_20,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(text,
          style: isSmall
              ? typo12semibold100.copyWith(color: SUB_90, height: 1)
              : typo14bold.copyWith(color: SUB_90, height: 1)),
    );
  }
}
