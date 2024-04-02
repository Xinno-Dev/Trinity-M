import '../../common_package.dart';

class TitleWithImage extends StatelessWidget {
  const TitleWithImage({
    super.key,
    required this.titleStyle,
    required this.title,
  });

  final TextStyle titleStyle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/svg/logo_rigo.svg',
          width: 20,
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          title,
          style: titleStyle,
        ),
      ],
    );
  }
}
