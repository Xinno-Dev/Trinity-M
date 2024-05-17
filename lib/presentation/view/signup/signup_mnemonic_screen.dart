import 'dart:convert';
import 'dart:developer';

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
import '../../../services/google_service.dart';
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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getMnemonic();
    mnemonicList = mnemonic.split(' ');
  }

  @override
  Widget build(BuildContext context) {
    final loginProv = ref.watch(loginProvider);
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: WHITE,
        appBar: AppBar(
          backgroundColor: WHITE,
          centerTitle: true,
          title: Text(
            TR(context, '지갑 만들기'),
            style: typo18semibold,
          ),
          titleSpacing: 0,
        ),
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
                          TR(context, '블록체인 연결을 위한\n복구문구를 보관하세요.'),
                          style: typo24bold150,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          TR(context, '블록체인 복구 문구를 안전한 곳에 보관해 주세요.\n'
                              '잃어버리실 경우 복구가 불가합니다.'),
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
                          mainAxisSpacing: 6.r,
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
                              TR(context, '문구 복사하기'),
                              style:
                              typo14bold100.copyWith(color: SECONDARY_90),
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: mnemonic));
                        final androidInfo = await DeviceInfoPlugin().androidInfo;
                        if (defaultTargetPlatform == TargetPlatform.iOS ||  androidInfo.version.sdkInt < 32)
                          Fluttertoast.showToast(msg: TR(context, '문구가 복사되었습니다'));
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          createAniRoute(CloudPassCreateScreen())).then((pass) async {
                          if (STR(pass).isNotEmpty) {
                            var address = loginProv.accountAddress;
                            // var keyPair = await loginProv.getAccountKey();
                            if (address != null) {
                              // var keyJson = jsonEncode(keyPair.toJson());
                              var rwfStr = await RWFExportHelper.encrypt(pass, address, mnemonic);
                              GoogleService.uploadKeyToGoogleDrive(context, rwfStr).then((result) {
                                LOG('---> startGoogleDriveUpload result : $result');
                              });
                            }
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 2, color: GRAY_20),
                        ),
                        child: Text(TR(context, '클라우드 백업'), style: typo16bold),
                      ),
                    )
                  ),
                  SizedBox(height: 10),
                ],
              ),
            )
          );
        }),
        bottomNavigationBar: widget.isShowNext ? Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: PrimaryButton(
            text: TR(context, '다음'),
            round: 0,
            onTap: () {
              ref.read(loginProvider).mainPageIndexOrg = 0;
              context.pushReplacementNamed(
                  MainScreen.routeName, queryParams: {'selectedPage': '1'});
              Fluttertoast.showToast(msg: TR(context, '회원가입 완료'));
            },
          ),
        ) : null,
      ),
    );
  }
}
