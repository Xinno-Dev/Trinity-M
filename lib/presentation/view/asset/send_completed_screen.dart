import 'package:auto_size_text_plus/auto_size_text.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/widget/balance_row.dart';

class SendCompletedScreen extends StatelessWidget {
  const SendCompletedScreen({Key? key,
    required this.sendAmount,
    required this.symbol})
      : super(key: key);
  static String get routeName => 'sendCompletedScreen';
  final String? sendAmount;
  final String? symbol; // sended coin or token symbol

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 120,
              ),
              Center(
                child: SvgPicture.asset('assets/svg/success.svg'),
              ),
              SizedBox(
                height: 60,
              ),
              BalanceRow(
                balance: sendAmount!,
                tokenUnit: symbol ?? 'RIGO',
                decimalSize: 18,
                fontSize: 34,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       sendAmount!,
              //       style: typo24bold.copyWith(color: PRIMARY_90),
              //       maxLines: 1,
              //     ),
              //     SizedBox(
              //       width: 4,
              //     ),
              //     Text(
              //       symbol ?? 'RIGO',
              //       style: typo24bold,
              //     ),
              //   ],
              // ),
              SizedBox(
                height: 20,
              ),
              Text(
                TR('코인 전송이 요청되었습니다.'),
                style: typo24bold150,
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                      onPressed: () {
                        context.go('/firebaseSetup');
                      },
                      child: Text(
                        TR('확인'),
                        style: typo16bold.copyWith(color: WHITE),
                      ),
                      style: primaryButtonStyle),
                ),
              ),
              SizedBox(
                height: 40.h,
              ),
            ],
          ),
        ),
      )
    );
  }
}
