import 'dart:io';

import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/SimpleCheckDialog.dart';
import 'package:larba_00/common/const/widget/settingsMenu.dart';
import 'package:larba_00/common/const/widget/warning_icon.dart';
import 'package:larba_00/common/provider/temp_provider.dart';
import 'package:larba_00/presentation/view/signup/login_screen.dart';
import 'package:larba_00/presentation/view/settings/settings_language_screen.dart';
import 'package:larba_00/presentation/view/settings/settings_policy_screent.dart';
import 'package:larba_00/presentation/view/settings/settings_security_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart' as provider;
import 'package:store_redirect/store_redirect.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/provider/firebase_provider.dart';
import '../../../domain/model/app_start_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  static String get routeName => 'settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with WidgetsBindingObserver {
  //
  PackageInfo _packageInfo = PackageInfo(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
    buildSignature: '',
    installerStore: '',
  );

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    WidgetsBinding.instance.addObserver(this);
    _initPackageInfo();
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('---> didChangeAppLifecycleState : $state');
    if (IS_AUTO_LOCK_MODE && state == AppLifecycleState.inactive) {
      setState(() {
        context.goNamed(LoginScreen.routeName);
      });
    }
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    var serverVersion = provider.Provider.of<FirebaseProvider>(context)
        .getServerVersion(Platform.isAndroid ? 'android' : 'ios').version;
    var isShowUpdate = serverVersion != _packageInfo.version;
    return Scaffold(
      backgroundColor: WHITE,
      // appBar: AppBar(
      //   backgroundColor: WHITE,
      //   leading: IconButton(
      //     icon: SvgPicture.asset('assets/svg/back.svg'),
      //     onPressed: () {
      //       context.pop();
      //     },
      //   ),
      //   centerTitle: true,
      //   title: Text(
      //     '설정',
      //     style: typo18semibold,
      //   ),
      //   elevation: 0,
      // ),
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 15, 0, 15),
                      child: Text(
                        TR(context, '설정'),
                        style: typo18semibold,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    SettingsMenu(
                      title: TR(context, '언어 설정'),
                      imageName: 'settings',
                      touchupinside: () {
                        context.pushNamed(SettingsLanguageScreen.routeName);
                      },
                    ),
                    SettingsMenu(
                      title: TR(context, '보안 및 개인정보 보호'),
                      imageName: 'security',
                      touchupinside: () {
                        context.pushNamed(SettingsSecurityScreen.routeName);
                      },
                    ),
                    SettingsMenu(
                      title: TR(context, '약관 및 정책'),
                      imageName: 'policy',
                      touchupinside: () {
                        context.pushNamed(SettingsPolicyScreen.routeName);
                      },
                    ),
                    InkWell(
                      onTap: () {
                        if (Platform.isAndroid || Platform.isIOS) {
                          StoreRedirect.redirect(
                              androidAppId: "com.medium.byffinwallet",
                              iOSAppId: "6469018232"
                          );
                        }
                      },
                      child: SettingsMenu(
                        title: '${TR(context, '앱 버전')} ${_packageInfo.version}'
                          '${isShowUpdate ? ' (${TR(context, '마켓 버전')}: ${serverVersion})' : ''}',
                        imageName: 'info',
                        hasRightString: !isShowUpdate,
                      )
                    ),
                    Spacer(),
                    Container(
                      height: 8,
                      color: GRAY_10,
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: TextButton(
                        child: Text(
                          TR(context, '지갑 잠금'),
                          style: typo14semibold.copyWith(color: GRAY_50),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SimpleCheckDialog(
                                titleString: TR(context, '지갑 잠금 유의사항'),
                                infoString:
                                  TR(context, '지갑 복구용 문구를 보관하지 않고\n지갑을 잠그실 경우,\n보유하신 자산에 접근할 수 없습니다.'),
                                hasTitle: true,
                                defaultButtonText: TR(context, '취소'),
                                hasOptions: true,
                                optionButtonText: TR(context, '잠금'),
                                hasIcon: true,
                                icon: WarningIcon(),
                                defaultTapOption: () {
                                  context.pop();
                                },
                                onTapOption: () {
                                  UserHelper().clearLoginDate();
                                  isGlobalLogin = false;
                                  context.goNamed(LoginScreen.routeName);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 34,
                    )
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
