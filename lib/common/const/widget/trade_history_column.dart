import '../../../common/common_package.dart';
import '../../../domain/model/network_model.dart';
import '../../../domain/model/rpc/tx_history.dart';
import '../../../presentation/view/trade_detail_screen.dart';
import '../../common_package.dart';
import '../utils/convertHelper.dart';
import '../utils/languageHelper.dart';
import '../utils/uihelper.dart';
import 'balance_row.dart';
import 'show_explorer.dart';

class TradeHistoryColumn extends StatelessWidget {
  const TradeHistoryColumn({
    super.key,
    required this.networkModel,
    required this.txHistory,
  });

  final NetworkModel networkModel;
  final TxHistory txHistory;

  @override
  Widget build(BuildContext context) {

    String getContentText(HistoryType historyType) {
      switch (historyType) {
        case HistoryType.sent:
        case HistoryType.sentToken:
          return '보내기';
        case HistoryType.received:
        case HistoryType.receivedToken:
          return '받기';
        case HistoryType.staking:
          return '스테이킹';
        case HistoryType.delegating:
          return '위임';
        case HistoryType.unStaking:
          return '언스테이킹';
        case HistoryType.unDelegating:
          return '위임 종료';
      }
    }

    return InkWell(
      onTap: () {
        UiHelper().buildRoundBottomSheet(
          context: context,
          title: TR(getContentText(txHistory.type)),
          child: TradeDetailScreen(
            txHistory: txHistory,
            coin: txHistory.token,
            decimalNum: txHistory.decimalNum,
            onExplorer: (networkModel.isRigo &&
              STR(networkModel.exploreUrl).isNotEmpty) ? (target, type) {
              showExplorer(networkModel.exploreUrl!, target, type,
                  isRigo: networkModel.isRigo);
            } : null,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              txHistory.time,
              style: typo12medium100.copyWith(color: GRAY_30),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Text(
                  TR(getContentText(txHistory.type)),
                  style: typo16semibold,
                ),
                Spacer(),
                Row(
                  children: [
                    BalanceRow(
                      balance: txHistory.amount,
                      tokenUnit: txHistory.token,
                      decimalSize: txHistory.decimalNum,
                      fontSize: 16,
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              TR('완료'),
              style: typo14semibold.copyWith(color: SUCCESS_90),
            ),
          ],
        ),
      ),
    );
  }
}
