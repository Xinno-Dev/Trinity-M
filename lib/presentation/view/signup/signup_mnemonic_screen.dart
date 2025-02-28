import 'dart:convert';
import 'dart:developer';

import 'package:trinity_m_00/presentation/view/signup/login_pass_screen.dart';

import '../../../../common/common_package.dart';
import '../../../../common/const/utils/userHelper.dart';
import '../../../../common/const/widget/PageNumbers.dart';
import '../../../../common/const/widget/SimpleCheckDialog.dart';
import '../../../../common/const/widget/custom_toast.dart';
import '../../../../common/const/widget/primary_button.dart';
import '../../../../common/provider/login_provider.dart';
import '../../../../presentation/view/main_screen.dart';
import '../../../../presentation/view/registLocalAuth_screen.dart';
import '../../../../presentation/view/registMnemonic_check_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/rwfExportHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/widget/warning_icon.dart';
import '../../../domain/viewModel/profile_view_model.dart';
import '../../../services/google_service.dart';
import '../../../services/icloud_service.dart';
import 'signup_pass_screen.dart';

class SignUpMnemonicScreen extends ConsumerStatefulWidget {
  SignUpMnemonicScreen({super.key, this.isShowNext = true});
  static String get routeName => 'signupMnemonicScreen';
  bool isShowNext;

  @override
  ConsumerState<SignUpMnemonicScreen> createState() =>
      _SignUpMnemonicScreenState();
}

class _SignUpMnemonicScreenState extends ConsumerState<SignUpMnemonicScreen> {
  late FToast fToast;
  String mnemonic = '';
  List<String> mnemonicList = [];

  Future<void> _getMnemonic() async {
    mnemonic = await UserHelper().get_check_mnemonic();
    mnemonicList = mnemonic.split(' ');
    LOG('--> mnemonicList : $mnemonic');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getMnemonic();
  }

  @override
  Widget build(BuildContext context) {
    final prov = ref.watch(loginProvider);
    return prov.isScreenLocked ? lockScreen(context) :
      Scaffold(
        backgroundColor: WHITE,
        appBar: defaultAppBar(TR('계정 복구 단어 백업')),
        body: LayoutBuilder(builder: (context, constraints) {
          var mnBoxRatio = constraints.maxHeight / constraints.maxWidth;
          if (mnBoxRatio < 2.0) mnBoxRatio = 2.0;
          // log('---> mnBoxRatio : $mnBoxRatio / ${constraints.maxHeight / constraints.maxWidth}');
          return SingleChildScrollView(
            child: Container(
              height: constraints.maxHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20.w, bottom: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),
                        Text(
                          TR('계정 복구를 위한\n복구 단어를 보관하세요.'),
                          style: typo24bold150,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          TR('계정 복구 단어를 안전한 곳에 보관해 주세요.\n'
                          '잃어버리실 경우 계정 복구가 불가합니다.'),
                          style: typo16medium150.copyWith(
                              color: GRAY_70),
                        ),
                        // SizedBox(height: 56.h),
                      ]),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      child: GridView.builder(
                        itemCount: mnemonicList.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 5,
                          childAspectRatio: mnBoxRatio,
                        ),
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Container(
                            color: BG,
                            child: Padding(
                              padding: EdgeInsets.all(5.r),
                              child: Stack(
                                children: [
                                  Text(
                                    '${index + 1}',
                                    style:
                                    typo14semibold.copyWith(color: GRAY_90),
                                  ),
                                  Center(
                                    child: Text(
                                      mnemonicList[index],
                                      style:
                                      typo16medium.copyWith(color: GRAY_60),
                                    ),
                                  ),
                                ],
                              ),
                            ));
                        },
                      ),
                    )),
                  Center(
                    child: GestureDetector(
                      child: Container(
                        padding:
                        EdgeInsets.symmetric(vertical: 9, horizontal: 20),
                        decoration: BoxDecoration(
                          color: GRAY_5,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('assets/svg/icon_copy.svg',
                                height: 12,
                                colorFilter: ColorFilter.mode(
                                    SECONDARY_90, BlendMode.srcIn)),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              TR('복구 단어 복사하기'),
                              style:
                              typo14bold100.copyWith(color: SECONDARY_90),
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: mnemonic));
                        if (defaultTargetPlatform == TargetPlatform.iOS) {
                          showToast(TR('문구가 복사되었습니다.'));
                        } else {
                          var androidInfo = await DeviceInfoPlugin().androidInfo;
                          if (androidInfo.version.sdkInt < 32)
                            showToast(TR('문구가 복사되었습니다.'));
                        }
                      },
                    ),
                  ),
                  if (IS_CLOUD_BACKUP_ON)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: InkWell(
                        onTap: _startCloudBackup,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 2, color: GRAY_20),
                          ),
                          child: Text(TR('클라우드 백업'), style: typo16bold),
                        ),
                      )
                    ),
                  SizedBox(height: 10),
                ],
              ),
            )
          );
        }),
        bottomNavigationBar: widget.isShowNext ? PrimaryButton(
          text: TR('다음'),
          round: 0,
          onTap: () {
            ref.read(loginProvider).mainPageIndexOrg = 0;
            context.pushReplacementNamed(
                MainScreen.routeName, queryParams: {'selectedPage': '1'});
            showToast(TR('회원가입 완료.'));
          },
        ) : null,
    );
  }

  _startCloudBackup() {
    final prov = ref.read(loginProvider);
    Navigator.of(context).push(
        createAniRoute(CloudPassCreateScreen())).then((pass) async {
      if (STR(pass).isNotEmpty) {
        prov.disableLockScreen();
        var address = prov.accountAddress;
        var email   = prov.userEmail;
        var keyPair = await prov.getAccountKey();
        if (address != null && keyPair != null) {
          var rwfStr = await RWFExportHelper.encrypt(
              pass, address, email, keyPair.d, mnemonic);
          if (defaultTargetPlatform == TargetPlatform.android) {
            _startGoogleCloud(rwfStr);
            return;
          }
          showSelectDialog(context, TR('백업 대상을 선택해 주세요.'),
            [TR('Apple iCloud'), TR('Google Drive')]).then((result) {
            switch (result) {
              case 0:
                _startAppleCloud(rwfStr);
                break;
              case 1:
                _startGoogleCloud(rwfStr);
                break;
            }
          });
        }
      }
    });
  }

  _startGoogleCloud(rwfStr) {
    final prov = ref.read(loginProvider);
    GoogleService.uploadKeyToDrive(
        context, prov.userEmail, rwfStr).then((_) {
      prov.enableLockScreen();
    });
  }

  _startAppleCloud(rwfStr) {
    final prov = ref.read(loginProvider);
    ICloudService.uploadKeyToDrive(
      context, prov.userEmail, rwfStr,
      (){
        showToast(TR('백업이 완료됬습니다.'));
        prov.enableLockScreen();
      },
      (err) {
        showToast('${TR('백업에 실패했습니다.')}\n$err');
      }
    );
  }
}
