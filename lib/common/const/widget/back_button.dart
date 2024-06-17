import '../../../common/common_package.dart';

class CustomBackButton extends StatelessWidget {
  CustomBackButton({
    super.key,
    this.icon,
    this.onPressed,
  });

  final Widget? icon;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        width: 40.r,
        height: 40.r,
        color: Colors.transparent,
        child: Center(
          child: icon ?? Icon(Icons.arrow_back),
        ),
      ),
      onPressed: onPressed
    );
  }
}
