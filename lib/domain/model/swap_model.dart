import 'package:larba_00/domain/model/coin_model.dart';
import 'package:larba_00/domain/model/network_model.dart';

import '../../common/const/utils/convertHelper.dart';

class SwapModel {
  NetworkModel? fromNetwork;
  CoinModel?    fromCoin;
  String?       fromAmount;

  NetworkModel? toNetwork;
  CoinModel?    toCoin;
  String?       toAmount;
  String?       toAddress;

  String?       swapRate;       // 교환 비율
  String?       swapTxId;       // 신청 txID from MDL server
  String?       swapFee;        // 교환 수수료
  DateTime?     swapTime;       // 교환 신청 시간

  String?       resultTxId;   // 교환 완료 시간
  DateTime?     resultTime;   // 교환 완료 시간
  String?       resultAmount;

  SwapModel({
    this.fromNetwork,
    this.fromCoin,
    this.fromAmount,

    this.toNetwork,
    this.toCoin,
    this.toAmount,
    this.toAddress,

    this.swapRate,
    this.swapTxId,
    this.swapFee,
    this.swapTime,

    this.resultTxId,
    this.resultTime,
    this.resultAmount,
  });

  get isEnable {
    return fromNetwork != null && fromCoin != null && DBL(fromAmount) > 0 &&
      toNetwork != null && toCoin != null;
  }
}