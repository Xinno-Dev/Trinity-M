import '../../common_package.dart';
import '../utils/languageHelper.dart';

class NetworkErrorScreen extends StatelessWidget {
  const NetworkErrorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WHITE,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            SvgPicture.asset(
              'assets/svg/wifi_off.svg',
              height: 80,
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              TR(context, '네트워크에 문제가 생겼어요'),
              style: typo22bold,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              TR(context, '문제를 해결하기 위해 열심히 노력하고 있습니다.\n잠시 후 다시 확인해주세요.'),
              style: typo16medium150,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}