import '../../../common/const/widget/primary_button.dart';

import '../../common/common_package.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/provider/temp_provider.dart';

class RecoverWalletCompleteScreen extends ConsumerStatefulWidget {
  const RecoverWalletCompleteScreen({super.key});
  static String get routeName => 'recover_wallet_complete';

  @override
  ConsumerState<RecoverWalletCompleteScreen> createState() =>
      _RecoverWalletCompleteScreenState();
}

class _RecoverWalletCompleteScreenState
    extends ConsumerState<RecoverWalletCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SECONDARY_10,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 104.h),
              SvgPicture.asset(
                'assets/svg/success.svg',
                width: 80.w,
                height: 80.h,
              ),
              SizedBox(height: 40.h),
              Text(
                TR('BYFFIN 지갑이\n복구되었습니다'),
                style: typo24bold150,
              ),
              SizedBox(height: 16.h),
              Text(
                TR('BYFFIN의 여러 디앱 서비스를\n사용해 보세요!'),
                style: typo16medium150,
              ),
              Spacer(),
              PrimaryButton(
                text: TR('지갑 사용하기'),
                onTap: () {
                  // DateTime now = DateTime.now();
                  // DateFormat formatter = DateFormat('yyyy.MM.dd');
                  // String formattedDate = formatter.format(now);
                  //
                  // UserHelper().setUser(registDate: formattedDate);
                  isRecoverLogin = true;
                  isGlobalLogin = true;
                  context.go('/firebaseSetup');
                },
              ),
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
