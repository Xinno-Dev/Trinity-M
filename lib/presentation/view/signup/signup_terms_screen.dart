import '../../../../common/const/constants.dart';
import '../../../../common/const/widget/CustomCheckBox.dart';
import '../../../../common/const/widget/PageNumbers.dart';
import '../../../../common/common_package.dart';
import '../../../../common/const/widget/dialog_utils.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../presentation/view/registPassword_screen.dart';
import '../../../../presentation/view/terms_detail_screen.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/provider/login_provider.dart';
import '../profile/webview_screen.dart';
import '../registMnemonic_screen.dart';
import 'signup_nick_screen.dart';

class SignUpTermsScreen extends ConsumerStatefulWidget {
  const SignUpTermsScreen({super.key});
  static String get routeName => 'signUpTerms';

  @override
  ConsumerState createState() => _SignUpTermsScreenState();
}

class _SignUpTermsScreenState extends ConsumerState<SignUpTermsScreen> {
  //
  List<String> title = [
    '이용 약관',
    '개인정보처리방침',
  ];
  // '마케팅 활용 및 광고성 정보 수신 동의'];

  bool agree_all = false; //전체동의
  bool agree_1 = false; //필수동의 1
  bool agree_2 = false; //필수동의 2
  bool agree_3 = false; //선택동의
  bool agreeEnable = false; //버튼활성화여부

  void agreeSetup() {
    if ((agree_1 && agree_2 && agree_3) == true) {
      agree_all = true;
    } else {
      agree_all = false;
    }
    if ((agree_1 && agree_2) == true) {
      agreeEnable = true;
    } else {
      agreeEnable = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          backgroundColor: WHITE,
          centerTitle: true,
          title: Text(
            TR(context, '약관 동의'),
            style: typo18semibold,
          ),
          titleSpacing: 0,
        ),
        body: Container (
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                padding: EdgeInsets.only(left: 20.w, top: 60.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TR(context, '약관에 동의해 주세요'),
                      style: typo24bold150,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      TR(context, 'Trinity M 을 이용해주셔서 감사합니다.\n'
                        '서비스 이용을 위해 약관 동의가 필요합니다.'),
                      style: typo16medium150.copyWith(
                        color: GRAY_70,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // width: 335.w,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        // width: 233.w,
                        // height: 34.h,
                        child: Column(
                          children: [
                            CustomCheckbox(
                              title: TR(context, '전체 동의'),
                              checked: agree_all,
                              pushed: false,
                              onChanged: (agree) {
                                setState(() {
                                  agree_all = agree!;
                                  agree_1   = agree;
                                  agree_2   = agree;
                                  agree_3   = agree;
                                  agreeEnable = agree;
                                });
                              },
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              height: 1,
                              color: GRAY_20,
                            ),
                            SizedBox(height: 16.h),
                            CustomCheckbox(
                              title: TR(context, title[0]) +
                                  ' ${TR(context, '(필수)')}',
                              checked: agree_1,
                              onChanged: (agree) {
                                setState(() {
                                  agree_1 = agree!;
                                  agreeSetup();
                                });
                              },
                              onPushnamed: () {
                                // context.pushNamed(TermsDetailScreen.routeName,
                                //   queryParams: {'title': title[0], 'type': '0'});
                                Navigator.of(context).push(
                                  createAniRoute(WebviewScreen(
                                    title: TR(context, title[0]),
                                    url: '$API_HOST/terms/1')));
                              },
                            ),
                            SizedBox(height: 4.h),
                            CustomCheckbox(
                              title: TR(context, title[1]) +
                                  ' ${TR(context, '(필수)')}',
                              checked: agree_2,
                              onChanged: (agree) {
                                setState(() {
                                  agree_2 = agree!;
                                  agreeSetup();
                                });
                              },
                              onPushnamed: () {
                                // context.pushNamed(TermsDetailScreen.routeName,
                                //   queryParams: {'title': title[1], 'type': '1'});
                                Navigator.of(context).push(
                                  createAniRoute(WebviewScreen(
                                    title: TR(context, title[1]),
                                    url: '$API_HOST/terms/2')));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
        bottomNavigationBar: IS_DEV_MODE || agreeEnable
            ? PrimaryButton(
          text: TR(context, '다음'),
          round: 0,
          onTap: () {
            Navigator.of(context).push(
                createAniRoute(SignUpNickScreen()));
          },
        ) : DisabledButton(
          text: TR(context, '다음'),
        ),
      ),
    );
  }
}
