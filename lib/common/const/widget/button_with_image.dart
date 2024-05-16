import 'package:auto_size_text_plus/auto_size_text.dart';

import '../../common_package.dart';
import '../../style/colors.dart';
import '../../style/textStyle.dart';

class ButtonWithImage extends StatelessWidget {
  const ButtonWithImage({
    super.key,
    required this.buttonText,
    required this.imageAssetName,
    required this.style,
    this.onPressed,
    this.isEnable = true,
  });

  final String buttonText;
  final String imageAssetName;
  final Function()? onPressed;
  final ButtonStyle style;
  final isEnable;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160.w,
      height: 48.h,
      child: TextButton(
        style: style,
        onPressed: () {
          if (isEnable && onPressed != null) onPressed!();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SvgPicture.asset(
              imageAssetName,
              height: 20.h,
            ),
            AutoSizeText(
              buttonText,
              maxLines: 1,
              style: typo12semibold100.copyWith(
                fontWeight: FontWeight.w600,
                color: isEnable ? GRAY_90 : GRAY_30
              ),
            ),
          ],
        ),
      ),
    );
  }
}
