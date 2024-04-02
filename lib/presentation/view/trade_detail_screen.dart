import 'package:auto_size_text_plus/auto_size_text.dart';
import 'package:larba_00/domain/model/network_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../common/common_package.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/custom_toast.dart';
import '../../common/const/widget/detail_row.dart';
import '../../common/const/widget/gray_5_round_container.dart';
import '../../domain/model/rpc/tx_history.dart';

class TradeDetailScreen extends StatelessWidget {
  const TradeDetailScreen({
    super.key,
    required this.txHistory,
    required this.coin,
    required this.decimalNum,
    this.onExplorer,
  });

  final TxHistory txHistory;
  final String coin;
  final int decimalNum;
  final Function(String, String)? onExplorer;

  String get amount {
    try {
      return double.parse(txHistory.amount).toStringAsFixed(decimalNum);
    } catch (_) {}
    return txHistory.amount;
  }

  String get totalAmount {
      try {
        if (txHistory.type == HistoryType.sent) {
          return (double.parse(txHistory.amount) + (txHistory.isRigo ?
          double.parse(txHistory.gas) : 0)).toStringAsFixed(decimalNum);
        }
        return double.parse(txHistory.amount).toStringAsFixed(decimalNum);
      } catch (_) {}
    return txHistory.amount;
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DetailRow(
          title: TR(context, '상태'),
          content: Text(
            TR(context, '완료'),
            style: typo18semibold.copyWith(color: SUCCESS_90),
          ),
        ),
        DetailRow(
          title: TR(context, '날짜'),
          content: Text(
            txHistory.time,
            style: typo16regular,
          ),
        ),
        SizedBox(
          height: 16,
        ),
        Gray5RoundContainer(
          child: Column(
            children: [
              DetailQuantityRow(
                title: TR(context, '수량'),
                quantity: amount,
                unit: coin,
                isBalanceRow: true,
              ),
              DetailQuantityRow(
                title: TR(context, '수수료'),
                quantity: txHistory.gas,
                unit: txHistory.peeToken,
                isBalanceRow: true,
              ),
              Divider(),
              DetailQuantityRow(
                title: TR(context, '총 수량'),
                quantity: totalAmount,
                unit: coin,
                color: PRIMARY_90,
                isBalanceRow: true,
              ),
              SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
        AddressColumn(title: TR(context, '보내는 주소'), content: '0x' + txHistory.from),
        AddressColumn(title: TR(context, '받는 주소'), content: '0x' + txHistory.to),
        AddressColumn(
          title: 'TXID',
          content: '0x' + txHistory.txId,
          onExplorer: () {
            if (onExplorer != null) {
              onExplorer!(txHistory.txId, 'transactions');
            }
          },
        ),
      ],
    );
  }
}

class AddressColumn extends StatelessWidget {
  AddressColumn({
    super.key,
    required this.title,
    required this.content,
    this.isCanCopy = false,
    this.onExplorer,
  });
  final String title;
  final String content;
  var isCanCopy;
  final Function()? onExplorer;

  _showToast(String msg) {
    FToast().showToast(
      child: CustomToast(
        msg: msg,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onExplorer != null) {
          onExplorer!();
        } else if (isCanCopy) {
          await Clipboard.setData(ClipboardData(text: content));
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (defaultTargetPlatform == TargetPlatform.iOS ||  androidInfo.version.sdkInt < 32)
          _showToast(TR(context, '복사를 완료했습니다'));
        }
      },
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: typo14medium.copyWith(color: GRAY_50),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            content,
            style: typo14regular.copyWith(decoration: onExplorer != null ? TextDecoration.underline : null),
          ),
        ],
      ),
    ));
  }
}

class RowWithUnit extends StatelessWidget {
  const RowWithUnit({
    super.key,
    required this.quantity,
    required this.coin,
  });

  final String coin, quantity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          quantity,
          style: typo16medium,
        ),
        SizedBox(
          width: 4,
        ),
        Text(
          coin,
          style: typo16regular,
        )
      ],
    );
  }
}
