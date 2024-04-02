import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/widget/settingsMenu.dart';
import 'package:larba_00/presentation/view/terms_detail_screen.dart';

import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/back_button.dart';

class SettingsPolicyScreen extends ConsumerStatefulWidget {
  const SettingsPolicyScreen({super.key});
  static String get routeName => 'settings_policy';
  @override
  ConsumerState<SettingsPolicyScreen> createState() =>
      _SettingsPolicyScreenState();
}

class _SettingsPolicyScreenState extends ConsumerState<SettingsPolicyScreen> {
  List<String> title = [
    'BYFFIN 이용약관',
    '개인정보처리방침',
  ];
    // '마케팅 활용 및 광고성 정보 수신 동의'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR(context, '약관 및 정책'),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  // mainAxisSize: MainAxisSize.max,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    for(var i=0; i<title.length; i++)
                    SettingsMenu(
                      leftImage: false,
                      title: TR(context, title[i]),
                      touchupinside: () {
                        context.pushNamed(TermsDetailScreen.routeName,
                            queryParams: {'title': TR(context, title[i]), 'type': '$i'});
                      },
                    ),
                    // SettingsMenu(
                    //   leftImage: false,
                    //   title: TR(context, title[1]),
                    //   touchupinside: () {
                    //     context.pushNamed(TermsDetailScreen.routeName,
                    //         queryParams: {'title': TR(context, title[1]), 'type': '1'});
                    //   },
                    // ),
                    // SettingsMenu(
                    //   leftImage: false,
                    //   title: TR(context, title[2]),
                    //   touchupinside: () {
                    //     context.pushNamed(TermsDetailScreen.routeName,
                    //         queryParams: {'title': TR(context, title[2]), 'type': '2'});
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
