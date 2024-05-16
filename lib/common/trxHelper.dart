import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';

import '../data/repository/ecc_repository_impl.dart';
import '../domain/model/coin_model.dart';
import '../domain/model/rpc/account.dart';
import '../domain/model/rpc/staking_type.dart';
import '../domain/repository/ecc_repository.dart';
import '../domain/usecase/ecc_usecase.dart';
import '../domain/usecase/ecc_usecase_impl.dart';
import 'const/utils/convertHelper.dart';
import 'const/utils/userHelper.dart';
import 'dartapi/lib/trx_pb.pb.dart';
import 'rlp/rlpEncoder.dart';

import 'package:big_decimal/big_decimal.dart';
// import 'package:eth_sig_util/util/utils.dart';
import 'package:fixnum/fixnum.dart';
import 'package:fixnum/src/int64.dart';

import '../../../common/common_package.dart';
import 'package:web3dart/crypto.dart';

enum TransactionType {
  TRX_TRANSFER(1), //transfer
  TRX_STAKING(2), //staking
  TRX_UNSTAKING(3), //unstaking
  TRX_PROPOSAL(4), //proposal
  TRX_VOTING(5), //voting
  TRX_CONTRACT(6), //for contract
  TRX_SETDOC(7), //execute
  TRX_WITHDRAW(8), //execute
  TRX_ETC(9); //execute

  final int value;

  const TransactionType(this.value);
}

class ResultTrx {
  final TrxProto trxProto;
  final String errString;
  ResultTrx({
    required this.trxProto,
    required this.errString,
  });
}

class TrxHelper {
  TrxHelper();

  Future<TrxProto> decodeTrx(String trxString) async {
    var decode_tx = base64Decode(trxString);

    TrxProto trxs = TrxProto.fromBuffer(decode_tx.toList());

    return trxs;
  }

  //
  //
  //
  //
  //
  //

  List<int> decodeTxHashFromPayloadBytes(List<int> payloadBytes) {
    var payload = TrxPayloadUnstakingProto.fromBuffer(payloadBytes);
    return payload.txHash;
  }

  Uint8List encodeTrxPayloadUnstakingProto(String txHash) {
    var payload = TrxPayloadUnstakingProto();
    payload.txHash = createUint8ListFromHexString(txHash);
    var mergedPayload = payload.writeToBuffer();
    return Uint8List.fromList(mergedPayload);
  }

  TrxPayloadContractProto decodeTxDataFromPayloadBytes(List<int> payloadBytes) {
    var payload = TrxPayloadContractProto.fromBuffer(payloadBytes);
    return payload;
  }

  Uint8List encodeTrxPayloadContractProto(String txHash) {
    var payload = TrxPayloadContractProto();
    payload.data = createUint8ListFromHexString(txHash);
    var mergedPayload = payload.writeToBuffer();
    return Uint8List.fromList(mergedPayload);
  }

  Uint8List encodeTrxPayloadSetDocProto(String name, String url) {
    var payload = TrxPayloadSetDocProto();
    payload.name = name;
    payload.url = url;
    var mergedPayload = payload.writeToBuffer();
    return Uint8List.fromList(mergedPayload);
  }

  Future<TrxProto> BuildTransferTrx(
      {required Account account,
      required TransactionType type,
      required String toAddress,
      required String gasPrice,
      required String minTrxFee,
      String amount = '',
      String payload = ''}) async {
    String myAddress = await UserHelper().get_address();
    //print(test3); //보여줄때 뒤에 0은 빼야함, 자리수 얼마나표현할건지 정책필요.
    //print((test4 * test2).toString()); //보낼때 String 을 바꿔서 .을 기준으로 뒤를 제거

    var accountNonce = int.parse(account.nonce!);

    TrxProto trx = TrxProto();
    trx.version = 1;
    trx.time = getNanoSecond(DateTime.now());
    trx.from = createUint8ListFromHexString(myAddress);
    trx.to   = createUint8ListFromHexString(toAddress);

    // gas
    var gas = int.parse(minTrxFee);
    trx.gas = Int64(gas);

    // gas price
    var hexGasPrice = BigInt.parse(gasPrice).toRadixString(16);
    if (hexGasPrice.length % 2 != 0) {
      hexGasPrice = "0" + hexGasPrice;
    }
    var bytesGasPrice = createUint8ListFromHexString(hexGasPrice);
    trx.gasPrice = bytesGasPrice;

    trx.type = type.value;

    if (amount != '') {
      trx.amount = _calculateAmount(amount);
    } else {
      trx.amount = Uint8List(0);
    }

    if (accountNonce != 0) trx.nonce = Int64(accountNonce);

    if (payload != '') {
      trx.payload = createUint8ListFromHexString(payload);
    } else {
      trx.payload = Uint8List(0);
    }

    return trx;
  }

  Future<TrxProto> BuildMDLTransferTrx(
      {required String toAddress,
        required String gasPrice,
        required String minTrxFee,
        int nonce = 0,
        String amount = '',
        String payload = ''}) async {
    String myAddress = await UserHelper().get_address();
    //print(test3); //보여줄때 뒤에 0은 빼야함, 자리수 얼마나표현할건지 정책필요.
    //print((test4 * test2).toString()); //보낼때 String 을 바꿔서 .을 기준으로 뒤를 제거

    TrxProto trx = TrxProto();
    trx.version = 1;
    trx.time = getNanoSecond(DateTime.now());
    trx.from = createUint8ListFromHexString(myAddress);
    trx.to   = createUint8ListFromHexString(toAddress);

    // gas
    var gas = int.parse(minTrxFee);
    trx.gas = Int64(gas);

    // gas price
    var hexGasPrice = BigInt.parse(gasPrice).toRadixString(16);
    if (hexGasPrice.length % 2 != 0) {
      hexGasPrice = "0" + hexGasPrice;
    }
    var bytesGasPrice = createUint8ListFromHexString(hexGasPrice);
    trx.gasPrice = bytesGasPrice;

    trx.type = 1;

    if (amount != '') {
      trx.amount = _calculateAmount(amount);
    } else {
      trx.amount = Uint8List(0);
    }

    trx.nonce = Int64(nonce);

    if (payload != '') {
      trx.payload = createUint8ListFromHexString(payload);
    } else {
      trx.payload = Uint8List(0);
    }

    return trx;
  }

  Future<TrxProto> BuildContractTrx(
      {required Account account,
        required String toAddress,
        required String gasPrice,
        required String minTrxFee,
        required List arg,
      }) async {
    String myAddress = await UserHelper().get_address();
    var accountNonce = int.parse(account.nonce!);

    TrxProto trx = TrxProto();
    trx.version = 1;
    trx.time    = getNanoSecond(DateTime.now());
    trx.from    = createUint8ListFromHexString(myAddress);
    trx.to      = createUint8ListFromHexString(toAddress);
    trx.type    = TransactionType.TRX_CONTRACT.value;
    trx.amount  = Uint8List(0);

    // gas
    var gas = int.parse(minTrxFee);
    trx.gas = Int64(gas);

    // gas price
    var hexGasPrice = BigInt.parse(gasPrice).toRadixString(16);
    if (hexGasPrice.length % 2 != 0) {
      hexGasPrice = "0" + hexGasPrice;
    }
    var bytesGasPrice = createUint8ListFromHexString(hexGasPrice);
    trx.gasPrice = bytesGasPrice;

    if (accountNonce != 0) trx.nonce = Int64(accountNonce);

    try {
      final vmAbi = await rootBundle.loadString('assets/abi/erc20_abi.json');
      final contract = DeployedContract(
          ContractAbi.fromJson(vmAbi, 'Erc20Token'),
          EthereumAddress.fromHex(toAddress));
      final encodeData = contract.function('transfer').encodeCall(arg);
      trx.payload = encodeData;
    } catch (e) {
      log('--> BuildContractTrx error : $e');
    }
    return trx;
  }

  Future<TrxProto> BuildBridgeTrx(
      {required Account account,
        required String toAddress,
        required String gasPrice,
        required String minTrxFee,
        required String amount,
        required List arg,
      }) async {
    String myAddress = await UserHelper().get_address();
    var accountNonce = int.parse(account.nonce!);

    TrxProto trx = TrxProto();
    trx.version = 1;
    trx.time    = getNanoSecond(DateTime.now());
    trx.from    = createUint8ListFromHexString(myAddress);
    trx.to      = createUint8ListFromHexString(toAddress);
    trx.type    = TransactionType.TRX_CONTRACT.value;
    // trx.amount  = Uint8List(0);

    if (amount != '') {
      trx.amount = _calculateAmount(amount);
    } else {
      trx.amount = Uint8List(0);
    }

    // gas
    var gas = int.parse(minTrxFee);
    trx.gas = Int64(gas);

    // gas price
    var hexGasPrice = BigInt.parse(gasPrice).toRadixString(16);
    if (hexGasPrice.length % 2 != 0) {
      hexGasPrice = "0" + hexGasPrice;
    }
    var bytesGasPrice = createUint8ListFromHexString(hexGasPrice);
    trx.gasPrice = bytesGasPrice;

    if (accountNonce != 0) trx.nonce = Int64(accountNonce);

    try {
      final vmAbi = await rootBundle.loadString('assets/abi/bridge_abi.json');
      final contract = DeployedContract(
          ContractAbi.fromJson(vmAbi, 'Bridge'),
          EthereumAddress.fromHex(toAddress));
      final encodeData = contract.function('swapExactRIGOForTokensWithBridge').encodeCall(arg);
      trx.payload = encodeData;
    } catch (e) {
      log('--> BuildContractTrx error : $e');
    }
    return trx;
  }

  Future<TrxProto> BuildUndelegateTrx(Account account, String toAddress,
      String amount, String minTxGas, String gasPrice) async {
    String myAddress = await UserHelper().get_address();
    var accountNonce = int.parse(account.nonce!);
    var gas = Int64(int.parse(minTxGas));

    if (accountNonce == 0) {
      return TrxProto(
        version: 1,
        time: getNanoSecond(DateTime.now()),
        from: createUint8ListFromHexString(myAddress),
        to: createUint8ListFromHexString(toAddress),
        amount: _calculateAmount(amount),
        gas: gas,
        gasPrice: _calculateAmount(gasPrice),
        type: TransactionType.TRX_UNSTAKING.value,
      );
    } else {
      return TrxProto(
        version: 1,
        time: getNanoSecond(DateTime.now()),
        nonce: Int64(accountNonce),
        from: createUint8ListFromHexString(myAddress),
        to: createUint8ListFromHexString(toAddress),
        amount: _calculateAmount(amount),
        gas: gas,
        gasPrice: _calculateAmount(gasPrice),
        type: TransactionType.TRX_UNSTAKING.value,
      );
    }
  }

  Future<TrxProto> BuildSetDocTrx(
      {required Account account,
        required TransactionType type,
        required String gasPrice,
        required String minTrxFee,
        Uint8List? payload,
        // String name = '',
        // String url = ''
    }) async {
    // String myAddress = await UserHelper().get_address();

    TrxProto trx = TrxProto();
    trx.version = 1;
    trx.time = getNanoSecond(DateTime.now());
    trx.from = createUint8ListFromHexString(account.address!);
    trx.to   = createUint8ListFromHexString(account.address!);

    // gas
    var gas = int.parse(minTrxFee);
    trx.gas = Int64(gas);

    // gas price
    var hexGasPrice = BigInt.parse(gasPrice).toRadixString(16);
    if (hexGasPrice.length % 2 != 0) {
      hexGasPrice = "0" + hexGasPrice;
    }
    var bytesGasPrice = createUint8ListFromHexString(hexGasPrice);
    trx.gasPrice = bytesGasPrice;
    trx.type = type.value;
    trx.amount = Uint8List(0);

    var accountNonce = int.parse(account.nonce!);
    if (accountNonce != 0) trx.nonce = Int64(accountNonce);

    LOG('--> BuildSetDocTrx : $payload');
    // var jsonStr = jsonEncode({
    //   'name': name ?? '',
    //   'url': url ?? '',
    // });
    // trx.payload = createUint8ListFromString(jsonStr);
    // var proto = TrxPayloadSetDocProto();
    // proto.name = name;
    // proto.url  = url;
    if (payload != null) {
      trx.payload = payload;
    } else {
      trx.payload = Uint8List(0);
    }
    return trx;
  }

  Future<ResultTrx> SignTrx(String pin, TrxProto trxProto) async {
    final EccRepository _repository = EccRepositoryImpl();
    final EccUseCase _usecase = EccUseCaseImpl(_repository);
    var signString =
        await _usecase.authSign(pin, base64Encode(trxProto.writeToBuffer()));

    if (signString == 'fail') {
      return ResultTrx(trxProto: TrxProto(), errString: 'fail');
    }
    var sign = hexToBytes(signString);

    TrxProto trx = TrxProto();
    trx.version = trxProto.version;
    trx.time = trxProto.time;
    trx.from = trxProto.from;
    trx.to = trxProto.to;
    trx.amount = trxProto.amount;
    trx.gas = trxProto.gas;
    trx.type = trxProto.type;
    if (trxProto.nonce != 0) trx.nonce = trxProto.nonce;
    if (trxProto.payload.isNotEmpty) trx.payload = trxProto.payload;

    trx.sig = sign;

    return ResultTrx(trxProto: trx, errString: '');
  }

  String getAmount(String amount, {int scale = 4}) {
    var defaultValue = BigDecimal.fromBigInt(BigInt.from(1000000000000000000));
    var parseAmount = BigDecimal.parse(amount);

    var divideAmount = parseAmount.divide(defaultValue,
        roundingMode: RoundingMode.HALF_UP, scale: scale);
    return divideAmount.toPlainString();
  }

  Uint8List _calculateAmount(String amount) {
    var getAmount = amount.replaceAll(',', '');
    var defaultValue = BigDecimal.fromBigInt(BigInt.from(1000000000000000000));
    var parseAmount = BigDecimal.parse(getAmount);
    var stringAmount = (defaultValue * parseAmount).toString();
    var splitAmount = stringAmount.split('.').first; // .00 제거
    var decimalAmount =
        BigDecimal.parse(splitAmount).toBigInt().toRadixString(16);
    var finAmount = '';
    if (decimalAmount.length % 2 == 1) {
      finAmount = '0' + decimalAmount;
    } else {
      finAmount = decimalAmount;
    }


    var returnAmount = hexToBytes(finAmount);

    return returnAmount;
    //16진수로 바꿔서
    //hexString 으로 변환
  }

  Future<ResultTrx> SignTrx2(
      {required String chainId,
      required String pin,
      required TrxProto trxProto}) async {
    final EccRepository _repository = EccRepositoryImpl();
    final EccUseCase _usecase = EccUseCaseImpl(_repository);

    var msg = createMsg(chainId, trxProto);
    var signString = await _usecase.authSign(pin, base64Encode(msg));

    if (signString == 'fail') {
      return ResultTrx(trxProto: TrxProto(), errString: 'fail');
    }
    var sign = hexToBytes(signString);

    TrxProto trx = TrxProto();
    trx.version = trxProto.version;
    trx.time = trxProto.time;
    trx.from = trxProto.from;
    trx.to = trxProto.to;
    trx.amount = trxProto.amount;
    trx.gas = trxProto.gas;
    trx.gasPrice = trxProto.gasPrice;
    trx.type = trxProto.type;
    if (trxProto.nonce != 0) trx.nonce = trxProto.nonce;
    if (trxProto.payload.isNotEmpty) trx.payload = trxProto.payload;

    trx.sig = sign;

    return ResultTrx(trxProto: trx, errString: '');
  }

  Future<Uint8List> SignTrx3(
      { required String message,
        required String pin,
        required TrxProto trxProto, bool isRlpEncode = true}) async {
    final EccRepository _repository = EccRepositoryImpl();
    final EccUseCase _usecase = EccUseCaseImpl(_repository);

    var msg = createMsg(message, trxProto, isRlpEncode);

    var signString = await _usecase.authSign(pin, base64Encode(msg));
    if (signString == 'fail') {
      return Uint8List(0);
    }
    return hexToBytes(signString);
  }

  TrxProto BuildSignedTrx(StakingType type, TrxProto trxProto, Uint8List sign,
    {String? tokenName, String? toAddress, String? amount, String? decimal,
     String? name, String? url}) {
    TrxProto signedTrx = TrxProto();
    signedTrx.version = trxProto.version;
    signedTrx.time = trxProto.time;
    signedTrx.from = trxProto.from;
    signedTrx.to = trxProto.to;
    signedTrx.amount = trxProto.amount;
    signedTrx.gas = trxProto.gas;
    signedTrx.gasPrice = trxProto.gasPrice;
    signedTrx.type = trxProto.type;
    if (trxProto.nonce != 0) signedTrx.nonce = trxProto.nonce;
    signedTrx.sig = sign;

    switch (type) {
      case StakingType.staking:
      case StakingType.delegate:
        break;

      case StakingType.unStaking:
      case StakingType.unDelegate:
        if (trxProto.payload.isNotEmpty) {
         var proto = TrxPayloadUnstakingProto();
         proto.txHash = trxProto.payload; // txHash
         signedTrx.payload = proto.writeToBuffer();
        }
        break;

      case StakingType.contract:
      case StakingType.bridge:
        if (trxProto.payload.isNotEmpty) {
          var proto = TrxPayloadContractProto();
          proto.token    = (tokenName ?? '').codeUnits;
          proto.from     = trxProto.from;
          proto.to       = (toAddress ?? '').codeUnits;
          proto.amount   = (amount ?? '').codeUnits;
          proto.decimal  = (decimal ?? '').codeUnits;
          proto.data     = trxProto.payload;
          signedTrx.payload = proto.writeToBuffer();
        }
        break;

      case StakingType.setDoc:
        var proto = TrxPayloadSetDocProto();
        proto.name = name ?? '';
        proto.url  = url ?? '';
        signedTrx.payload = proto.writeToBuffer();
        // signedTrx.payload = trxProto.payload;
        break;

      // case StakingType.transfer:
      //   break;
    }

    return signedTrx;
  }
}

Int64 getNanoSecond([DateTime? dt]) {
  if (dt == null) {
    dt = DateTime.now();
  }
  return Int64(dt.millisecondsSinceEpoch) * Int64(1000000);
}

DateTime fromNanoSecond(Int64 nsec) {
  return DateTime.fromMicrosecondsSinceEpoch(nsec.toInt() ~/ 1000);
}
