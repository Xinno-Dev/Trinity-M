import '../../../../common/trxHelper.dart';
import '../../../../domain/model/coin_model.dart';
import '../../../../services/mdl_rpc_service.dart';

import '../../../../common/common_package.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/const/utils/languageHelper.dart';
import '../../../../common/const/utils/userHelper.dart';
import '../../../../common/const/widget/trade_history_column.dart';
import '../../../../common/provider/coin_provider.dart';
import '../../../../common/provider/network_provider.dart';
import '../../../../domain/model/network_model.dart';
import '../../../../domain/model/rpc/tx_history.dart';
import '../../../../services/json_rpc_service.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:infinite_scroll_pagination/src/ui/default_indicators/first_page_exception_indicator.dart';
import 'package:provider/provider.dart' as provider;

class TrxHistoryListScreen extends ConsumerStatefulWidget {
  const TrxHistoryListScreen({
    super.key,
    this.isEmpty = false,
  });

  final bool isEmpty;

  @override
  ConsumerState<TrxHistoryListScreen> createState() => _TrxHistoryListScreenState();
}

class _TrxHistoryListScreenState extends ConsumerState<TrxHistoryListScreen> {
  static const _pageSize = 5;
  late NetworkModel networkModel;
  CoinModel? currentCoin;
  final _pagingController = PagingController<int, TxHistory>(
    firstPageKey: 1,
  );

  Future<void> _getHistory(int pageKey) async {
    String address = await UserHelper().get_address();
    networkModel =
      provider.Provider.of<NetworkProvider>(context, listen: false)
      .networkModel;
    var coinPv = ref.read(coinProvider);
    currentCoin = coinPv.currentCoin;
    LOG('--> _getHistory : $pageKey / $networkModel / $currentCoin');
    try {
      List<TxHistory> newItems = [];
      var isLastPage = true;
      if (networkModel.isRigo) {
        newItems = await JsonRpcService()
            .getHistory(networkModel, address, pageKey, _pageSize);
        isLastPage = newItems.length < _pageSize;
      } else if (currentCoin != null) {
        newItems = await MdlRpcService()
            .getHistory(networkModel, currentCoin!);
      }
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _getHistory(pageKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    _pagingController.refresh();
    // var coinPv = ref.watch(coinProvider);
    // currentCoin = coinPv.currentCoin;

    if (widget.isEmpty) {
      return Center(
        child: Text(
          TR('거래내역이 없습니다'),
          style: typo16medium.copyWith(color: GRAY_70),
        ),
      );
    }
    return PagedListView<int, TxHistory>.separated(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<TxHistory>(
        itemBuilder: (context, txHistory, index) =>
          TradeHistoryColumn(
              txHistory: txHistory,
              networkModel: networkModel
          ),
        firstPageErrorIndicatorBuilder: (_) => FirstPageExceptionIndicator(
          title: TR('에러가 발생했습니다'),
          onTryAgain: () {
            setState(() {
            });
          },
        ),
        newPageErrorIndicatorBuilder: (_) => Container(),
        noItemsFoundIndicatorBuilder: (_) => Center(
          child: Text(
            TR('거래내역이 없습니다'),
            style: typo16medium.copyWith(color: GRAY_70),
          ),
        ),
      ),
      separatorBuilder: (context, index) => Divider(
        height: 1,
      ),
    );
  }
}
