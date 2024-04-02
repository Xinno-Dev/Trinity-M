import 'package:auto_size_text_plus/auto_size_text.dart';
import 'package:larba_00/common/common_package.dart';

import '../utils/languageHelper.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({
    super.key,
    required this.title,
    this.imageName = 'security',
    this.touchupinside,
    this.leftImage = true,
    this.hasRightString = false,
  });

  final String title;
  final String imageName;
  final Function()? touchupinside;
  final bool leftImage;
  final bool hasRightString;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: GRAY_5))),
      child: InkWell(
        onTap: touchupinside,
        child: Row(
          children: [
            SizedBox(
              width: 20,
            ),
            leftImage
                ? SvgPicture.asset(
                    'assets/svg/$imageName.svg',
                    fit: BoxFit.scaleDown,
                    height: 24,
                  )
                : SizedBox(),
            SizedBox(
              width: leftImage ? 8.w : 0,
            ),
            Expanded(
              child: AutoSizeText(
                '$title',
                style: typo16medium,
                maxFontSize: 18,
                maxLines: 1,
              )
            ),
            hasRightString
                ? SizedBox(width: 5.w)
                : leftImage
                    ? SizedBox()
                    : SizedBox(width: 5.w),
            hasRightString
                ? Text(
                    TR(context, '최신 버전 사용 중'),
                    style: typo14regular.copyWith(color: GRAY_50),
                  )
                : leftImage
                    ? SizedBox()
                    : SvgPicture.asset('assets/svg/arrow.svg'),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }
}
