import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:larba_00/common/common_package.dart';

class MainBox extends StatelessWidget {
  const MainBox({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pressed,
    this.auth = false,
  });

  final String title;
  final String subtitle;
  final Function() pressed;
  final bool auth;
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 104.h,
      width: 335.w,
      child: ElevatedButton(
        onPressed: pressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 24.w),
            SvgPicture.asset(auth
                ? 'assets/svg/notification.svg'
                : 'assets/svg/id-card.svg'),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 32.h,
                  ),
                  Text(
                    title,
                    style: typo16bold.copyWith(color: auth ? GRAY_10 : GRAY_90),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    subtitle,
                    style: typo14medium.copyWith(
                      color: auth ? GRAY_30 : GRAY_70,
                    ),
                  ),
                  SizedBox(
                    height: 32.h,
                  ),
                ],
              ),
            ),
          ],
        ),
        style: auth ? mainsubButtonStyle : mainButtonStyle,
      ),
    );
  }
}
