import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../common/const/widget/custom_text_form_field.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../presentation/view/recover_wallet_register_password.dart';
import 'package:bip39/bip39.dart' as bip39;

import '../../common/common_package.dart';
import '../../common/const/constants.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/utils/uihelper.dart';
import '../../common/const/widget/SimpleCheckDialog.dart';
import '../../common/const/widget/back_button.dart';

class RecoverWalletInputScreen extends StatefulWidget {
  RecoverWalletInputScreen({super.key});
  static String get routeName => 'recover_wallet_input';

  @override
  State<RecoverWalletInputScreen> createState() =>
      _RecoverWalletInputScreenState();
}

class _RecoverWalletInputScreenState extends State<RecoverWalletInputScreen> {
  final List<FocusNode> focusNodeList =
      List<FocusNode>.generate(12, (index) => FocusNode());
  final List<TextEditingController> _controllerList = IS_DEV_MODE ?
      List.generate(12, (index) => TextEditingController(text: EX_TEST_MN_01.split(' ')[index])) :
      List.generate(12, (index) => TextEditingController());

  final _scrollController = ScrollController();
  bool _allFilled = IS_DEV_MODE;
  bool _showInfoText = false;
  String mnemonic = '';

  void checkAllFieldsFilled() {
    final anyEmpty =
      _controllerList.any((controller) => controller.text.isEmpty);
    setState(() {
      _allFilled = !anyEmpty;
    });
  }

  @override
  void initState() {
    for (final controller in _controllerList) {
      controller.addListener(checkAllFieldsFilled);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in _controllerList) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _scrollController.animateTo(0,
            duration: Duration(microseconds: 200), curve: Curves.bounceIn);
        for (FocusNode focus in focusNodeList) {
          focus.unfocus();
        }
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: WHITE,
          appBar: defaultAppBar(TR(context, '계정 복구')),
          body: LayoutBuilder(builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Text(
                              TR(context, '계정 복구 단어를 입력해주세요.'),
                              style: typo24bold,
                            )),
                            Expanded(
                                child: Text(
                              TR(context, '회원가입시 제공된 계정 복구 단어는\n'
                                  '12개의 단어로 이루어져있습니다.'),
                              style: typo16medium150.copyWith(color: GRAY_70),
                            )),
                            // SizedBox(
                            //   height: 16,
                            // ),
                            // GestureDetector(
                            //   onTap: () {
                            //     setState(() {
                            //       _showInfoText = !_showInfoText;
                            //     });
                            //   },
                            //   child: Container(
                            //     padding: EdgeInsets.symmetric(
                            //         vertical: 9.0, horizontal: 8.0),
                            //     decoration: BoxDecoration(
                            //       color: SECONDARY_10,
                            //       borderRadius: BorderRadius.circular(4),
                            //     ),
                            //     child: Row(
                            //       mainAxisSize: MainAxisSize.min,
                            //       children: [
                            //         Text(
                            //           TR(context, '지갑 복구용 문구란'),
                            //           style: typo14medium.copyWith(
                            //               color: SECONDARY_90),
                            //         ),
                            //         SizedBox(
                            //           width: 4,
                            //         ),
                            //         _showInfoText
                            //             ? SvgPicture.asset(
                            //                 'assets/svg/arrow_up.svg')
                            //             : SvgPicture.asset(
                            //                 'assets/svg/arrow_down.svg',
                            //                 colorFilter: ColorFilter.mode(
                            //                     SECONDARY_90, BlendMode.srcIn),
                            //               ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            if (_showInfoText) InfoTextColumn(),
                          ],
                        ),
                      )),
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 60),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: GridView.builder(
                          itemCount: 12,
                          shrinkWrap: true,
                          primary: false,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.2),
                          itemBuilder: (BuildContext context, int index) {
                            return RecoveryInputColumn(
                              index: index + 1,
                              focusNode: focusNodeList[index],
                              controller: _controllerList[index],
                            );
                          },
                        ),
                      )),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _showButton(),
                  )
                ],
              ),
            );
          }
        ),
      )
      )
    );
  }

  _showButton() {
    return _allFilled ? PrimaryButton(
      text: TR(context, '다음'),
      round: 0,
      onTap: () {
        mnemonic = '';
        for (TextEditingController controller
        in _controllerList) {
          if (controller == _controllerList.first) {
            mnemonic += controller.text;
          } else {
            mnemonic += (' ' + controller.text);
          }
        }
        bool isValidMnemonic = bip39.validateMnemonic(mnemonic);
        if (isValidMnemonic) {
          // context.pushNamed(
          //   RecoverWalletRegisterPassword.routeName,
          //   queryParams: {'mnemonic': mnemonic},
          // );
          context.pop(mnemonic);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleCheckDialog(
                  hasTitle: true,
                  titleString: TR(context, '지갑 복구 문구가 일치하지 않습니다'),
                  infoString: TR(context, '다시 입력해주세요.'),
                  defaultButtonText: TR(context, '다시 입력하기'));
            },
          );
        }
      },
    ) : DisabledButton(
      round: 0,
      text: TR(context, '다음'),
    );
  }
}

class InfoTextColumn extends StatelessWidget {
  const InfoTextColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
          child: Column(
            children: [
              InfoRow(
                text:
                TR(context, '복구용 문구는 지갑을 만들때 보안을 위해 자동으로\n생성된 단어이며, 자산을 복구하기 위한 유일한 수단\n입니다.'),
              ),
              SizedBox(
                height: 8,
              ),
              InfoRow(text:
                TR(context, '바이핀 지갑-> 설정메뉴-> 내 지갑 복구용 문구 보기\n메뉴에서 확인할 수 있습니다.')),
              SizedBox(
                height: 16,
              ),
              Divider(
                height: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: typo14medium150.copyWith(color: GRAY_50),
        ),
        SizedBox(
          width: 3,
        ),
        Text(
          text,
          style: typo14medium150.copyWith(color: GRAY_50),
        ),
      ],
    );
  }
}

class RecoveryInputColumn extends StatelessWidget {
  const RecoveryInputColumn({
    super.key,
    required this.index,
    required this.focusNode,
    this.onSubmitted,
    required this.controller,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final int index;
  final Function(String)? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '$index',
                style: typo14semibold,
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          CustomTextFormField(
              hintText: TR(context, '문구 입력'),
              constraints: constraints,
              focusNode: focusNode,
              controller: controller),
        ],
      );
    });
  }

  TextFormField buildDefaultTextFormField(
      {required String labelText,
      required BoxConstraints constraints,
      required FocusNode focusNode,
      required TextEditingController controller}) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: constraints.maxWidth > 107
            ? typo16regular.copyWith(color: GRAY_30)
            : typo14regular.copyWith(color: GRAY_30),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 23.5),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: GRAY_20,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: SECONDARY_90,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textInputAction: TextInputAction.next,
      textAlign: TextAlign.center,
    );
  }
}
