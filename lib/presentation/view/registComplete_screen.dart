import 'dart:developer';

import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/widget/primary_button.dart';
import 'package:larba_00/common/provider/temp_provider.dart';
import 'package:larba_00/presentation/view/main_screen.dart';

import '../../common/const/utils/languageHelper.dart';
import '../../common/const/utils/uihelper.dart';

class RegistCompleteScreen extends ConsumerStatefulWidget {
  const RegistCompleteScreen({
    super.key,
    this.join = 'false',
    this.reset = 'false',
    this.addAccount = 'false',
    this.loadAccount = 'false',
  });
  static String get routeName => 'registComplete';
  final String? join;
  final String? reset;
  final String? addAccount;
  final String? loadAccount;

  @override
  ConsumerState<RegistCompleteScreen> createState() =>
      _RegistCompleteScreenState();
}

class _RegistCompleteScreenState extends ConsumerState<RegistCompleteScreen>
    with TickerProviderStateMixin {
  bool isJoin = false;
  bool isReset = false;
  bool isAdd = false;
  bool isLoad = false;
  String titleStr = '';
  String subTitleStr = '';

  String getButtonText() {
    if (isReset) return '로그인하기';
    if (widget.loadAccount == 'true' || widget.addAccount == 'true')
      return '자산으로 가기';
    return '지갑 사용하기';
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  refreshTitle(context) {
    if (widget.join == 'true') {
      isJoin = true;
      titleStr = TR(context, 'BYFFIN 지갑 을\n만들었습니다');
      subTitleStr = TR(context, 'BYFFIN의 여러 디앱 서비스를\n사용해 보세요!');
    }
    if (widget.reset == 'true') {
      isReset = true;
      titleStr = TR(context, '비밀번호 변경이\n완료되었습니다');
      subTitleStr = TR(context, '새로운 비밀번호로 로그인을 해주세요');
    }
    if (widget.addAccount == 'true') {
      isAdd = true;
      titleStr = TR(context, '새 계정을 추가했습니다');
      subTitleStr = TR(context, '새로운 비밀번호로 로그인을 해주세요');
    }
    if (widget.loadAccount == 'true') {
      isLoad = true;
      titleStr = TR(context, '계정을 불러왔습니다');
      subTitleStr = TR(context, '새로운 비밀번호로 로그인을 해주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    refreshTitle(context);
    return Scaffold(
      backgroundColor: isReset ? WHITE : SECONDARY_10,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment:
                isReset ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80.h),
              SvgPicture.asset(
                'assets/svg/success.svg',
                width: isReset ? 80.0 : 56.w,
                height: isReset ? 80.0 : 56.h,
              ),
              SizedBox(height: 40.h),
              Text(
                titleStr,
                style: typo24bold150,
              ),
              SizedBox(height: 16.h),
              Text(
                isReset
                    ? TR(context, '새로운 비밀번호로 로그인을 해주세요')
                    : TR(context, 'BYFFIN의 여러 디앱 서비스를\n사용해 보세요!'),
                style: typo16medium150,
              ),
              Spacer(),
              PrimaryButton(
                text: TR(context, getButtonText()),
                onTap: () {
                  if (isReset) {
                    isGlobalLogin = false;
                  } else {
                    isGlobalLogin = true;
                  }
                  if (isGlobalLogin) {
                    context.goNamed(MainScreen.routeName,
                        queryParams: {
                          'selectedPage': '0',
                        }
                    );
                  } else {
                    context.go('/firebaseSetup');
                  }
                },
              ),
              // Container(
              //   width: 335.w,
              //   height: 56,
              //   margin: EdgeInsets.fromLTRB(20.r, 0, 20.r, 0),
              //   child: ElevatedButton(
              //       onPressed: () {
              //         if (isReset) {
              //           isGlobalLogin = false;
              //         } else {
              //           isGlobalLogin = true;
              //         }
              //         context.go('/firebaseSetup');
              //       },
              //       child: Text(
              //         isReset ? '로그인하기' : '지갑 사용하기',
              //         style: typo16bold.copyWith(color: WHITE),
              //       ),
              //       style: primaryButtonStyle),
              // ),
              SizedBox(
                height: 40.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
