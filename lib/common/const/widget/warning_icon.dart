import '../../common_package.dart';

class WarningIcon extends StatelessWidget {
  const WarningIcon({
    super.key,
    this.height = 32.0,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/icon_warning.svg',
      height: height,
    );
  }
}
