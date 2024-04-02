import '../../common_package.dart';

class IconBorderButton extends StatelessWidget {
  const IconBorderButton({
    super.key,
    required this.imageAssetName,
    required this.text,
    this.onPressed,
  });

  final String imageAssetName, text;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            imageAssetName,
            height: 12.0,
          ),
          SizedBox(
            width: 4.0,
          ),
          Text(
            text,
            style: typo10medium100,
          ),
        ],
      ),
      style: grayBorderButtonStyle,
    );
  }
}
