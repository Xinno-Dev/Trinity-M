import '../../../common/common_package.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/settingsMenu.dart';
import '../../../presentation/view/authpassword_screen.dart';
import 'package:flutter/cupertino.dart';

import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/back_button.dart';

class SettingsSecurityScreen extends ConsumerStatefulWidget {
  const SettingsSecurityScreen({super.key});
  static String get routeName => 'settings_security';
  @override
  ConsumerState<SettingsSecurityScreen> createState() =>
      _SettingsSecurityScreenState();
}

class _SettingsSecurityScreenState
    extends ConsumerState<SettingsSecurityScreen> {
  //TODO: - 로컬인증 사용 여부를 관리하는 곳이 필요하고, 거기거 값을 가져와야함.
  bool useLacontext = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _initLocalAuthInfo();
  }

  Future<void> _initLocalAuthInfo() async {
    String usingLocalAuth = await UserHelper().get_useLocalAuth();

    setState(() {
      if (usingLocalAuth == 'true') {
        useLacontext = true;
      } else {
        useLacontext = false;
      }
    });
  }

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
          TR('보안 및 개인정보 보호'),
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
                    SettingsMenu(
                      leftImage: false,
                      title: TR('비밀번호 변경'),
                      touchupinside: () {
                        context.pushNamed(AuthPasswordScreen.routeName,
                            queryParams: {'reset': 'true'});
                      },
                    ),
                    SettingsMenu(
                      leftImage: false,
                      title: TR('지갑 복구용 문구 보기'),
                      touchupinside: () {
                        context.pushNamed(AuthPasswordScreen.routeName,
                            queryParams: {'mnemonic': 'true'});
                      },
                    ),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 1, color: GRAY_5))),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            TR('생체 인증 사용'),
                            style: typo16medium150,
                          ),
                          Spacer(),
                          CupertinoSwitch(
                              activeColor: PRIMARY_90,
                              thumbColor: WHITE,
                              trackColor: GRAY_30,
                              value: useLacontext,
                              onChanged: (bool value) async {
                                UserHelper().setUser(localAuth: '$value');
                                setState(() {
                                  useLacontext = value;
                                });
                              }),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ),
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
