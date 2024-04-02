import '../../common_package.dart';

class Primary10Button extends StatelessWidget {
  const Primary10Button({
    super.key,
    required this.text,
    this.onTap,
  });

  final String text;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: PRIMARY_10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              text,
              style: typo16bold.copyWith(color: PRIMARY_90),
            ),
          ),
        ),
      ),
    );
  }
}
