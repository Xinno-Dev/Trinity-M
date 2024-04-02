import 'package:larba_00/common/common_package.dart';

class CustomBackButton extends StatelessWidget {
  CustomBackButton({
    super.key,
    this.onPressed,
  });

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        width: 40.r,
        height: 40.r,
        color: Colors.transparent,
        child: Center(
          child: SvgPicture.asset('assets/svg/back.svg',
              width: 22.r, height: 22.r),
        ),
      ),
      onPressed: onPressed
    );
  }
}
