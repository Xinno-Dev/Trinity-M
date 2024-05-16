import 'dart:developer';

import '../../../common/common_package.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/PageNumbers.dart';
import '../../../common/const/widget/SimpleCheckDialog.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../presentation/view/registLocalAuth_screen.dart';
import '../../../presentation/view/registMnemonic_check_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/back_button.dart';
import '../../common/const/widget/warning_icon.dart';

class RegistMnemonicScreen extends ConsumerStatefulWidget {
  const RegistMnemonicScreen({super.key, this.hasCheck = 'false'});
  static String get routeName => 'registMnemonic';
  final String? hasCheck;
  @override
  ConsumerState<RegistMnemonicScreen> createState() =>
      _RegistMnemonicScreenState();
}

class _RegistMnemonicScreenState extends ConsumerState<RegistMnemonicScreen> {
  late FToast fToast;
  String mnemonic = '';
  List<String> mnemonicList = [];
  bool hasCheck = false;

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
    if (widget.hasCheck == 'true') {
      hasCheck = true;
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
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR(context, hasCheck ? '지갑 복구용 문구 보기' : '지갑 만들기'),
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
                  if (!hasCheck)...[
                    PageNumbers(select: 2),
                    SizedBox(height: 20.h),
                  ],
                  hasCheck ? Container(
                    padding: EdgeInsets.only(left: 20.w, bottom: 20.h),
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                TR(context, '지갑 복구용 문구'),
                                style: typo24bold,
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SimpleCheckDialog(
                                        infoString: TR(context, '복구용 문구는 지갑을 만들때 '
                                            '\n보안을 위해 자동으로 생성된 단어이며,'
                                            '\n자산을 복구하기 위한'
                                            '\n유일한 수단입니다.'),
                                      );
                                    },
                                  );
                                },
                                child: SvgPicture.asset(
                                  'assets/svg/icon_help.svg',
                                  height: 24.0,
                                ),
                              )
                            ]),
                          SizedBox(
                            height: 16.h,
                          ),
                          Center(
                            child: Text(
                              TR(context, '문구를 안전한 곳에 보관해주세요.\n문구가 없으실 경우엔 계정 복구가 불가합니다.'),
                              style:
                                  typo16medium150.copyWith(color: GRAY_70),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 80.h,
                          ),
                        ],
                      ),
                    )
                  : Container(
                    padding: EdgeInsets.only(left: 20.w, bottom: 20.h),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                            Text(
                              TR(context, '지갑 복구용 문구를 보관하세요'),
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
                  hasCheck
                      ? SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: PrimaryButton(
                            text: TR(context, '다음'),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleCheckDialog(
                                    titleString: TR(context, '문구 보관을 확인하세요'),
                                    infoString: TR(context, '지갑 복구용 문구를 보관하셨나요?\n'
                                        '보관 확인 과정을 진행하세요\n\n'
                                        '문구를 잃어버리실 경우 지갑 복구가\n'
                                        '불가하며,  바이핀은 사용자의 지갑\n'
                                        '복구용 문구를 보관하지 않습니다.'),
                                    hasTitle: true,
                                    defaultButtonText: TR(context, '넘어가기'),
                                    hasOptions: true,
                                    optionButtonText: TR(context, '보관 확인하기'),
                                    hasIcon: true,
                                    icon: WarningIcon(),
                                    defaultTapOption: () {
                                      context.pop();
                                      context.pushNamed(
                                          RegistLocalAuthScreen.routeName);
                                    },
                                    onTapOption: () {
                                      context.pop();
                                      context.pushNamed(
                                          RegistMnemonicCheckScreen.routeName);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 40),
                ],
              ),
            )
          );
        }),
      ),
    );
  }
}
