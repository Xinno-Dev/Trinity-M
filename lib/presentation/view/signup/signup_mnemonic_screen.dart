import 'dart:developer';

import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/common/const/widget/PageNumbers.dart';
import 'package:larba_00/common/const/widget/SimpleCheckDialog.dart';
import 'package:larba_00/common/const/widget/custom_toast.dart';
import 'package:larba_00/common/const/widget/primary_button.dart';
import 'package:larba_00/presentation/view/main_screen.dart';
import 'package:larba_00/presentation/view/registLocalAuth_screen.dart';
import 'package:larba_00/presentation/view/registMnemonic_check_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../common/const/constants.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/widget/warning_icon.dart';

class SignUpMnemonicScreen extends ConsumerStatefulWidget {
  SignUpMnemonicScreen({super.key});
  static String get routeName => 'signupMnemonicScreen';
  @override
  ConsumerState<SignUpMnemonicScreen> createState() =>
      _SignUpMnemonicScreenState();
}

class _SignUpMnemonicScreenState extends ConsumerState<SignUpMnemonicScreen> {
  late FToast fToast;
  String mnemonic = '';
  List<String> mnemonicList = [];

  Future<void> _getMnemonic() async {
    String get_mnemonic = await UserHelper().get_check_mnemonic();

    setState(() {
      mnemonic = get_mnemonic;
      mnemonicList = mnemonic.split(' ');
    });
    fToast = FToast();
    fToast.init(context);
  }

  _showToast(String msg) {
    fToast.showToast(
      child: CustomToast(
        msg: msg,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();
    _getMnemonic();
    mnemonicList = mnemonic.split(' ');
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
            TR(context, '지갑 만들기'),
            style: typo18semibold,
          ),
          elevation: 0,
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          var mnBoxRatio = constraints.maxHeight / constraints.maxWidth;
          if (mnBoxRatio < 2.5) mnBoxRatio = 2.5;
          // log('---> mnBoxRatio : $mnBoxRatio / ${constraints.maxHeight / constraints.maxWidth}');
          return SingleChildScrollView(
              child: Container(
                height: constraints.maxHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    Container(
                      padding: EdgeInsets.only(left: 20.w, bottom: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          Text(
                            TR(context, '지갑 복구용 문구를 보관하세요.'),
                            style: typo24bold,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            TR(context, '문구를 복사하여 안전한 곳에 보관해주세요.\n'
                                '문구를 잃어버리실 경우 지갑 복구가 불가합니다.'),
                            style: typo16medium150.copyWith(
                                color: GRAY_70),
                          ),
                          // SizedBox(height: 56.h),
                        ]),
                    ),
                    SizedBox(height: 10.h),
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
                                    padding: EdgeInsets.all(8.r),
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
                    SizedBox(height: (constraints.maxHeight < 600) ? 10 : 16),
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
                            _showToast(TR(context, '문구가 복사되었습니다'));
                        },
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.h),
                      child: PrimaryButton(
                        text: TR(context, '다음'),
                        round: 0,
                        onTap: () {
                          Navigator.of(context).push(createAniRoute(MainScreen()));
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    //   child: PrimaryButton(
                    //     text: TR(context, '다음'),
                    //     onTap: () {
                    //       showDialog(
                    //         context: context,
                    //         builder: (BuildContext context) {
                    //           return SimpleCheckDialog(
                    //             titleString: TR(context, '문구 보관을 확인하세요'),
                    //             infoString: TR(context, '지갑 복구용 문구를 보관하셨나요?\n'
                    //                 '보관 확인 과정을 진행하세요\n\n'
                    //                 '문구를 잃어버리실 경우 지갑 복구가\n'
                    //                 '불가하며,  바이핀은 사용자의 지갑\n'
                    //                 '복구용 문구를 보관하지 않습니다.'),
                    //             hasTitle: true,
                    //             defaultButtonText: TR(context, '넘어가기'),
                    //             hasOptions: true,
                    //             optionButtonText: TR(context, '보관 확인하기'),
                    //             hasIcon: true,
                    //             icon: WarningIcon(),
                    //             defaultTapOption: () {
                    //               context.pop();
                    //               context.pushNamed(
                    //                   RegistLocalAuthScreen.routeName);
                    //             },
                    //             onTapOption: () {
                    //               context.pop();
                    //               context.pushNamed(
                    //                   RegistMnemonicCheckScreen.routeName);
                    //             },
                    //           );
                    //         },
                    //       );
                    //     },
                    //   ),
                    // ),
                    // SizedBox(height: 40),
                  ],
                ),
              )
          );
        }),
      ),
    );
  }
}
