import 'dart:developer';

import '../../../common/common_package.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/PageNumbers.dart';
import '../../../common/const/widget/disabled_button.dart';
import '../../../common/const/widget/primary_button.dart';
import '../../../presentation/view/registLocalAuth_screen.dart';
import 'package:web3dart/crypto.dart';
import '../../../common/style/outlineInputBorder.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/back_button.dart';
import '../../common/const/widget/custom_text_form_field.dart';

class RegistMnemonicCheckScreen extends ConsumerStatefulWidget {
  const RegistMnemonicCheckScreen({super.key});
  static String get routeName => 'registMnemonicCheck';
  @override
  ConsumerState<RegistMnemonicCheckScreen> createState() =>
      _RegistMnemonicCheckScreenState();
}

class _RegistMnemonicCheckScreenState
    extends ConsumerState<RegistMnemonicCheckScreen> {
  String mnemonic = '';
  List<String> mnemonicList = [];
  List<int> checkNum = [4, 6, 8, 11];
  final List<FocusNode> focusNodeList =
      List<FocusNode>.generate(4, (index) => FocusNode());
  final _scrollController = ScrollController();

  final List<TextEditingController> controllerList =
      List<TextEditingController>.generate(
          4, (index) => TextEditingController());
  bool isEnable = false;

  Future<void> _getMnemonic() async {
    String get_mnemonic = await UserHelper().get_check_mnemonic();

    setState(() {
      mnemonic = get_mnemonic;
      mnemonicList = mnemonic.split(' ');
    });
  }

  void checkAllFieldsFilled() {
    final anyEmpty =
        controllerList.any((controller) => controller.text.isEmpty);
    setState(() {
      isEnable = !anyEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    for (final controller in controllerList) {
      controller.addListener(checkAllFieldsFilled);
    }
    _getMnemonic();
    mnemonicList = mnemonic.split(' ');
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(Duration(seconds: 2)).then((_) {
    //     _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    //   });
    // });
  }

  Widget buildBottomButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 14.9,
          child: isEnable
              ? PrimaryButton(
                  text: '다음',
                  onTap: () {
                    int successCount = 0;
                    for (int i = 0; i < 4; i++) {
                      //4가지 문구가 모두 정확하면 다음 화면, 틀리면 에러문구 표시
                      if (mnemonicList[checkNum[i] - 1] ==
                          controllerList[i].text) {
                        successCount++;
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleCheckDialog(
                              titleString: TR(context, '문구가 일치하지 않습니다'),
                              infoString: TR(context, '문구를 다시 입력해 주세요.'),
                              hasTitle: true,
                              defaultButtonText: TR(context, '돌아가기'),
                              defaultTapOption: () {
                                setState(() {
                                  for (var controller in controllerList) {
                                    controller.text = '';
                                  }
                                  isEnable = false;
                                  successCount = 0;
                                });
                                context.pop();
                              },
                            );
                          },
                        );
                        break;
                      }
                    }
                    if (successCount == 4) {
                      context.pushNamed(RegistLocalAuthScreen.routeName);
                    }
                  },
                )
              : DisabledButton(text: TR(context, '다음')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        for (FocusNode focus in focusNodeList) {
          focus.unfocus();
        }
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      },
      child: SafeArea(
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
            TR(context, '지갑 만들기'),
            style: typo18semibold,
          ),
          elevation: 0,
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                // physics: NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30.h),
                      PageNumbers(select: 2),
                      SizedBox(height: 16.h),
                      Container(
                        // color: GRAY_20,
                        // height: 176.h,
                        padding: EdgeInsets.only(left: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              TR(context, '문구 보관을 확인합니다'),
                              style: typo24bold,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              TR(context, '빈칸의 번호에 맞는 문구를 입력해주세요'),
                              style: typo16medium150.copyWith(
                                  color: GRAY_70),
                            ),
                            // SizedBox(height: 56.h),
                          ]),
                      ),
                      // SizedBox(height: 72.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        alignment: Alignment.center,
                        child: Center(
                        child: Container(
                          height: 150.w,
                          margin: EdgeInsets.symmetric(vertical: 20.h),
                          child: GridView.builder(
                            shrinkWrap: true,
                            itemCount: 4,
                            padding: EdgeInsets.zero,
                            gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.r,
                              mainAxisSpacing: 8.r,
                              childAspectRatio: 2.5,
                            ),
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Container(
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      '${checkNum[index]}',
                                      style: typo14semibold.copyWith(
                                          // 각 디바이스 별 디자인을 맞추기 위해 임의로 typo14semibold -> typo12semibold100 변경
                                          color: GRAY_90),
                                    ),
                                  ),
                                  SizedBox(height: 5.h),
                                  Expanded(
                                    child: Focus(
                                      canRequestFocus: false,
                                      child: CustomTextFormField(
                                        hintText: TR(context, '문구 입력'),
                                        focusNode: focusNodeList[index],
                                        controller: controllerList[index]),
                                      // onFocusChange: (status) {
                                      //   if (status && index > 1) {
                                      //     _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                                      //   }
                                      // },
                                    )
                                  ),
                                ],
                                )
                              );
                            },
                          ),
                        ),
                      ),
                      ),
                      SizedBox(height: 600)
                    ],
                )
              );
            },
          ),
        ),
        bottomNavigationBar: buildBottomButton(context),
      ),
      ),
    );
  }
}
