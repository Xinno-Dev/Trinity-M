import '../../../common/common_package.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/eccManager.dart';
import '../../../common/const/utils/uihelper.dart';
import '../../../common/const/widget/SimpleCheckDialog.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../presentation/view/authpassword_screen.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../common/const/utils/convertHelper.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/rwfExportHelper.dart';
import '../../../common/const/widget/back_button.dart';
import '../../../common/const/widget/custom_text_edit.dart';
import '../../../common/const/widget/custom_toast.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/const/widget/icon_border_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../common/style/outlineInputBorder.dart';

class ImportPrivateKeyScreen extends ConsumerStatefulWidget {
  const ImportPrivateKeyScreen({super.key});
  static String get routeName => 'import_privateKey';
  @override
  ConsumerState<ImportPrivateKeyScreen> createState() =>
      _ImportPrivateKeyScreenState();
}

class _ImportPrivateKeyScreenState
    extends ConsumerState<ImportPrivateKeyScreen> {
  final TextEditingController _textcontroller0 =
  TextEditingController(text: IS_DEV_MODE ? '72ea53c05b61e7da73ec3d5ac9ce16b2207210fae5c48ccc867c8cbd8db3a7b2' : '');
  final TextEditingController _textcontroller1 = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  late FToast fToast;
  final String buttonText = '불러오기';
  int tabIndex = 0;

  @override
  void initState() {
    fToast = FToast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        focusNode.unfocus();
      },
      child: DefaultTabController(
      length: 2,
        child: Scaffold(
          backgroundColor: WHITE,
          appBar: AppBar(
            backgroundColor: WHITE,
            leading: CustomBackButton(
              onPressed: context.pop,
            ),
            centerTitle: true,
            title: Text(
              TR(context, '계정 불러오기'),
              style: typo18semibold,
            ),
            elevation: 0,
            bottom: TabBar(
              // padding: EdgeInsets.only(top: 10, left: 15, right: 15),
              onTap: (index) {
                setState(() {
                  tabIndex = index;
                });
              },
              labelColor: GRAY_90,
              labelStyle: typo16semibold,
              unselectedLabelColor: GRAY_40,
              indicatorColor: GRAY_90,
              indicatorPadding: EdgeInsets.symmetric(horizontal: 30.0),
              tabs: [
                Tab(text: TR(context, '개인키')),
                Tab(text: TR(context, 'RWF')),
              ],
            ),
          ),
          body: SafeArea(
            child: SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _showPrivateTab1(),
                          _showPrivateTab2(),
                        ]
                      ),
                    ),
                    Container(
                      child: isEnableButton
                          ? PrimaryButton(
                        text: TR(context, buttonText),
                        onTap: () async {
                          if (tabIndex == 0) {
                            _execImport(_textcontroller0.text);
                          } else {
                            var inputPass = _passController.text;
                            var rwfText   = _textcontroller1.text;
                            if (inputPass.length >= 6) {
                              showLoadingDialog(context, 'RWF 변환중 입니다.', isShowIcon: false);
                              Future.delayed(Duration(milliseconds: 200)).then((_) async {
                                var rwfTextDec = await RWFExportHelper.decrypt(inputPass, rwfText);
                                LOG('---> RWFExportHelper().decrypt : $rwfTextDec');
                                hideLoadingDialog();
                                _execImport(rwfTextDec);
                              });
                            } else {
                              _showToast('비밀번호를 확인해 주세요');
                            }
                          }
                        },
                      ) : DisabledButton(text: TR(context, buttonText)),
                    ),
                    SizedBox(
                      height: 20.h,
                    )
                  ]
                )
              )
            )
          ),
        ),
      )
    );
  }

  _execImport(text) async {
    bool isValid = await _validateKeyPair(text);
    if (isValid && text != 'fail') {
      context.pushNamed(
          AuthPasswordScreen.routeName,
          queryParams: {
            'import_privateKey': text
          });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleCheckDialog(
            hasTitle: true,
            titleString: TR(context, '개인키가 일치하지 않습니다'),
            infoString: TR(context, '확인 후 다시 시도해 주세요.'),
            defaultTapOption: () {
              context.pop();
            },
          );
        },
      );
    }
  }

  _showPrivateTab1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TR(context, '개인키 문자열을 입력해 주세요'),
          style: typo16medium.copyWith(color: GRAY_70),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: GRAY_20),
          ),
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: _textcontroller0,
            minLines: 1,
            maxLines: 3,
            textAlign: TextAlign.start,
            focusNode: focusNode,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 20.0),
              enabledBorder: gray20Border,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: SECONDARY_50,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              hintText:
              '${TR(context, '_예')})b1e4a513cb068d7611c671f9fdf71d0e633fd8b5a76c1de863a1e4a51306bd1d',
              hintStyle:
              typo16regular150.copyWith(color: GRAY_30),
              suffixIconConstraints:
              BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: focusNode.hasFocus
                  ? IconButton(
                onPressed: () {
                  setState(() {
                    focusNode.unfocus();
                    _textcontroller0.clear();
                  });
                },
                icon: SvgPicture.asset(
                  'assets/svg/close.svg',
                  width: 16.0,
                ),
              )
                  : SizedBox(),
            ),
            onChanged: (value) {
              setState(() {
              });
            },
          ),
        ),
        IconBorderButton(
          imageAssetName: 'assets/svg/icon_copy.svg',
          text: TR(context, '붙여넣기'),
          onPressed: () async {
            ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
            setState(() {
              _textcontroller0.text = cdata?.text ?? '';
            });
          },
        ),
        SizedBox(height: 20.h),
        _infoText(),
      ],
    );
  }

  _showPrivateTab2() {
    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      shrinkWrap: true,
      children: [
        Row(
          children: [
            Text(
              TR(context, 'RWF 문자열을 입력해 주세요.'),
              style: typo16medium.copyWith(color: GRAY_70),
            ),
            SizedBox(width: 5.w),
            InkWell(
              onTap: () {
                showSimpleDialog(context, 'RWF(RIGO Wallet Key Format) 는\n'
                    '개인키를 암호화 하여 저장한\njson 형식의 파일 입니다.', null, 160.0);
              },
              child: SvgPicture.asset('assets/svg/icon_question.svg', width: 18.r, height: 18.r),
            )
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: GRAY_20),
          ),
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: _textcontroller1,
            maxLines: 10,
            textAlign: TextAlign.start,
            focusNode: focusNode,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                  vertical: 16.0, horizontal: 20.0),
              enabledBorder: gray20Border,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: SECONDARY_50,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              hintText:
              '${TR(context, '_예')})b1e4a513cb068d7611c671f9fdf71d0e633fd8b5a76c1de863a1e4a51306bd1d',
              hintStyle:
              typo16regular150.copyWith(color: GRAY_30),
              suffixIconConstraints:
              BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: focusNode.hasFocus
                  ? IconButton(
                onPressed: () {
                  setState(() {
                    focusNode.unfocus();
                    _textcontroller1.clear();
                  });
                },
                icon: SvgPicture.asset(
                  'assets/svg/close.svg',
                  width: 16.0,
                ),
              )
                  : SizedBox(),
            ),
            onChanged: (value) {
              setState(() {
              });
            },
          ),
        ),
        Row(
          children: [
            IconBorderButton(
              imageAssetName: 'assets/svg/icon_copy.svg',
              text: TR(context, '붙여넣기'),
              onPressed: () async {
                ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
                setState(() {
                  _textcontroller1.text = cdata?.text ?? '';
                });
              },
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Text(
              TR(context, '비밀번호를 입력해 주세요.'),
              style: typo16medium.copyWith(color: GRAY_70),
            ),
            SizedBox(width: 5.w),
            InkWell(
              onTap: () {
                showSimpleDialog(context, 'RWF(RIGO Wallet Key Format)\n'
                    '생성 시, 설정하신 비밀번호를 입력해 주세요.');
              },
              child: SvgPicture.asset('assets/svg/icon_question.svg', width: 18.r, height: 18.r),
            )
          ],
        ),
        showTextEdit('',
          controller: _passController,
          showPassStatus: true,
          onChanged: (text) {
            setState(() {});
          }
        ),
        SizedBox(height: 10.h),
        _infoText(),
        SizedBox(height: 300),
      ],
    );
  }

  get isEnableButton {
    LOG('---> isEnableButton : $tabIndex');
    if (tabIndex == 0) {
      return _textcontroller0.text.length == 64;
    } else {
      return _passController.text.length > 4 && _textcontroller1.text.length > 0;
    }
  }

  _infoText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: SvgPicture.asset(
            'assets/svg/icon_info.svg',
          ),
        ),
        SizedBox(
          width: 5.w,
        ),
        Text(
          TR(context, '불러온 계정은 지갑 복구 시,\n지갑 복구용 문구로는 복구 할 수 없습니다.'),
          style: typo14medium.copyWith(color: GRAY_70, height: 1.5),
        ),
      ],
    );
  }

  showTextEdit(
      title, {
        String? desc,
        String? error,
        TextEditingController? controller, String? hint,
        bool isEnabled = true,
        bool isShowOutline = true,
        bool isShowPass = false,
        bool showPassStatus = false,
        Function(String)? onChanged,
        Function()? onTap,
      }) {
    return CustomTextEdit(
      context,
      title,
      desc: desc,
      error: error,
      controller: controller,
      hint: hint,
      isEnabled: isEnabled,
      isShowOutline: isShowOutline,
      isShowPass: isShowPass,
      showPassStatus: showPassStatus,
      onChanged: onChanged,
      onTap: onTap,
    );
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
}

Future<bool> _validateKeyPair(String privateKey) async {
  EccManager eccManager = EccManager();
  var keyPair = await eccManager.loadKeyPair(privateKey);
  if (keyPair == null) {
    return false;
  }
  bool isValid = await eccManager.isValidateKeyPair(keyPair);

  return isValid;
}
