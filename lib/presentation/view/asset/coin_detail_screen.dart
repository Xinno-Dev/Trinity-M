import '../../../../common/const/widget/button_with_image.dart';
import '../../../../common/const/widget/gray_divider.dart';
import '../../../../presentation/view/asset/receive_asset_screen.dart';
import '../../../../presentation/view/asset/send_asset_screen.dart';
import '../../../../presentation/view/asset/tabBarViewScreens/trx_history_list_screen.dart';

import '../../../common/common_package.dart';
import '../../../common/const/utils/languageHelper.dart';
import '../../../common/const/utils/uihelper.dart';

class CoinDetailScreen extends StatefulWidget {
  const CoinDetailScreen({Key? key, required this.coinName}) : super(key: key);
  static String get routeName => 'coinDetailScreen';
  final String? coinName;

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: WHITE,
        title: Text(
          'Rigo Main Network',
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  widget.coinName!,
                  style: typo16medium,
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Text(
                      '45.00',
                      style: typo28bold,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      'BNB',
                      style: typo24bold,
                    ),
                  ],
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  '\$14,061.83',
                  style: typo16regular.copyWith(color: GRAY_50),
                ),
                SizedBox(
                  height: 32,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ButtonWithImage(
                        buttonText: TR(context, '받기'),
                        imageAssetName:
                            'assets/svg/filled_round_arrow_down.svg',
                        style: primaryImageButtonStyle,
                        onPressed: () {
                          UiHelper().buildRoundBottomSheet(
                            context: context,
                            title: TR(context, '내 주소로 받기'),
                            child: ReceiveAssetScreen(
                              walletAddress: '',
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: ButtonWithImage(
                        buttonText: TR(context, '보내기'),
                        imageAssetName: 'assets/svg/filled_round_arrow_up.svg',
                        style: primaryImageButtonStyle,
                        onPressed: () {
                          context.pushNamed(SendAssetScreen.routeName);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
          GrayDivider(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                TR(context, '거래내역'),
                style: typo16semibold,
              ),
            ),
          ),
          TrxHistoryListScreen(),
        ],
      ),
    );
  }
}
