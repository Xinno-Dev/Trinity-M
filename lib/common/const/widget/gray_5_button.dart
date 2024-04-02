import '../../common_package.dart';

class Gray5Button extends StatelessWidget {
  const Gray5Button({
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
        decoration: BoxDecoration(
          color: GRAY_5,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              text,
              style: typo16bold.copyWith(color: GRAY_70),
            ),
          ),
        ),
      ),
    );
  }
}
