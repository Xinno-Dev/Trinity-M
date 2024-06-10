// import 'package:flutter_gif/flutter_gif.dart';
import '../../common/common_package.dart';
import '../../common/const/utils/convertHelper.dart';
import 'package:flutter/cupertino.dart';
// import 'package:gif/gif.dart';

import '../../common/const/utils/languageHelper.dart';

class AuthCompletedScreen extends ConsumerStatefulWidget {
  const AuthCompletedScreen({
    super.key,
    this.noti,
  });
  static String get routeName => 'authcompleted';
  final String? noti;

  @override
  ConsumerState<AuthCompletedScreen> createState() =>
      _AuthCompletedScreenState();
}

class _AuthCompletedScreenState extends ConsumerState<AuthCompletedScreen>
    with TickerProviderStateMixin {
  // late GifController gifController;
  late Map<String, dynamic> notiMap;
  @override
  void initState() {
    notiMap = ConvertHelper().stringToMap(widget.noti);
    // gifController = GifController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //반복
      // gifController.repeat(
      // min: 10,
      // max: 73,
      // period: const Duration(milliseconds: 1500),
      // );
      //한번
      // gifController.animateTo(
      //   72,
      //   duration: Duration(milliseconds: 1500),
      // );
    });
    super.initState();
  }

  @override
  void dispose() {
    // gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 40.h),
            SizedBox(
              child: Image.asset("assets/images/success-check.gif"),
              height: 126.h,
              width: 126.h,
            ),
            // Gif(
            //   controller: gifController,
            //   image: Image.asset("assets/images/success-check.gif"),
            //   height: 126.h,
            //   width: 126.h,
            // ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.only(left: 20.r, right: 20.r),
              child: Text(
                '${notiMap['Service']} ${TR('로그인 완료')}',
                style: typo24bold150,
              ),
            ),
            Spacer(),
            Container(
              width: 335.w,
              height: 56.h,
              margin: EdgeInsets.fromLTRB(20.r, 0, 20.r, 0),
              child: ElevatedButton(
                  onPressed: () {
                    context.go('/firebaseSetup');
                  },
                  child: Text(
                      TR('닫기'),
                    style: typo16bold.copyWith(color: WHITE),
                  ),
                  style: primaryButtonStyle),
            ),
            SizedBox(
              height: 40.h,
            ),
          ],
        ),
      ),
    );
  }
}
