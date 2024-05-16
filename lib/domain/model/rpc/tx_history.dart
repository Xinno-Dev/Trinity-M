import 'dart:convert';
import 'dart:typed_data';

import '../../../../common/const/constants.dart';
import '../../../../common/const/utils/convertHelper.dart';
import '../../../../common/trxHelper.dart';
import '../../../../services/json_rpc_service.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:intl/intl.dart';

import '../../../common/const/utils/walletHelper.dart';
import '../../../common/dartapi/lib/trx_pb.pb.dart';

enum HistoryType {
  sent,
  received,
  staking,
  delegating,
  unStaking,
  unDelegating,
  sentToken,
  receivedToken,
}

class TxHistory {
  final String token, time, from, to, gas, payloadTx;
  final int transactionType;
  String amount;
  String? decimal;
  HistoryType type;
  // TrxPayloadContractProto? contractInfo;
  late String txId;
  late String peeToken;

  TxHistory(
    {
      required this.token,
      required this.time,
      required this.from,
      required this.to,
      required this.amount,
      required this.gas,
      required this.transactionType,
      required this.payloadTx,
      // this.contractInfo,
      this.decimal,
      this.type = HistoryType.sent,
      this.txId = '',
      this.peeToken = '',
    });

  get decimalNum {
    if (decimal == null || decimal!.isEmpty) return 0;
    return int.parse(decimal!);
  }

  get isRigo {
    return token.toLowerCase() == 'rigo';
  }

  factory TxHistory.fromTrxProto(TrxProto proto) {
    String date = fromNanoSecond(proto.time).toString();
    DateTime createdDate = DateTime.parse(date);
    date = DateFormat('yy.MM.dd. HH:mm').format(createdDate);

    String from = fromListIntToString(proto.from);
    String to = fromListIntToString(proto.to);

    BigInt bigAmount;
    if (proto.amount.isNotEmpty) {
      bigAmount = BigInt.parse(bytesToHex(proto.amount), radix: 16);
    } else {
      // 언스테이킹, 위임 종료의 경우 amount값이 없음
      bigAmount = BigInt.parse('0');
    }
    String amount = TrxHelper().getAmount(bigAmount.toString());

    BigInt bigProtoGas = BigInt.parse(proto.gas.toString());
    BigInt bigGasPrice = BigInt.parse(bytesToHex(proto.gasPrice), radix: 16);
    String gasFee = (bigProtoGas * bigGasPrice).toString();
    gasFee = TrxHelper().getAmount(gasFee, scale: 8);

    List<int> payloadTxHashList =
        TrxHelper().decodeTxHashFromPayloadBytes(proto.payload);
    String payloadTx = fromListIntToString(payloadTxHashList);

    // TrxPayloadContractProto contractProto =
    // TrxHelper().decodeTxDataFromPayloadBytes(proto.payload);
    String token = 'RIGO';
    String decimal = DECIMAL_PLACES.toString();
    if (proto.type == 6) {
      TrxPayloadContractProto contractInfo =
      TrxHelper().decodeTxDataFromPayloadBytes(proto.payload);
      token = utf8.decode(contractInfo.token);
      to = utf8.decode(contractInfo.to);
      amount = contractInfo.amount.isNotEmpty ? utf8.decode(contractInfo.amount) : '0';
      decimal = utf8.decode(contractInfo.decimal);
    }

    return TxHistory(
        token: token,
        time: date,
        from: from,
        to: to,
        amount: amount,
        gas: gasFee,
        transactionType: proto.type,
        payloadTx: payloadTx,
        decimal: decimal,
        peeToken: 'RIGO',
        // contractInfo: contractProto,
    );
  }

  // get contractJson {
  //   return {
  //     'tokenSymbol': contractInfo != null ? utf8.decode(contractInfo!.token) : '',
  //     'toAddress': contractInfo != null ? utf8.decode(contractInfo!.to) : '',
  //     'amount': contractInfo != null ? utf8.decode(contractInfo!.token) : '',
  //   };
  // }

  get log {
    return '[$transactionType] $amount, $from -> $to / $token / $decimal';
  }
}

String fromListIntToString(List<int> list) {
  Uint8List byte = Uint8List.fromList(list);
  return formatBytesAsHexString(byte);
}

class TxHistoryList {
  List<TxHistory> txHistories;
  TxHistoryList(this.txHistories);

  factory TxHistoryList.fromJson(List<dynamic> json) {
    List<TxHistory> list = [];
    list = json.map((e) => TxHistory.fromTrxProto(e)).toList();
    return TxHistoryList(list);
  }
}
