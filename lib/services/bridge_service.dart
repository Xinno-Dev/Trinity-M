import 'dart:convert';
import 'dart:math';

import 'package:big_decimal/big_decimal.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/domain/model/coin_model.dart';
import 'package:larba_00/domain/model/network_model.dart';
import 'package:larba_00/domain/model/rpc/tx_history.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/extensions/string_extensions.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import '../common/const/utils/aesManager.dart';
import '../common/const/utils/convertHelper.dart';
import '../common/const/utils/eccManager.dart';
import '../common/trxHelper.dart';
import '../domain/model/address_model.dart';
import '../domain/model/mdl_history_model.dart';
import '../presentation/view/account/user_info_screen.dart';

class BridgeService {

  //////////////////////////////////////////////////////////////////////////
  //
  //  MDL util methods
  //

  final httpUrl = 'http://52.78.111.39:3003';
  String? vmAbi;

  Future<bool> runVmCall(
      NetworkModel networkModel,
      String mdlChainId,
      String mdlTokenAddress,
      String contractAddr,
      String userAddr,
      String amount
    ) async {
    final functionName = 'swapExactRIGOForTokensWithBridge';
    try {
      vmAbi ??= await rootBundle.loadString('assets/abi/bridge_abi.json');
      LOG('---> runVmCall : $contractAddr');
      // contractAddr = '0x18dee342247fe60eed10d37d9f45e1442214094a';
      final contractAddress = EthereumAddress.fromHex(contractAddr);
      final userAddress     = EthereumAddress.fromHex(userAddr);
      final contract        = new DeployedContract(new ContractAbi.fromJson(
          vmAbi!, 'Bridge'), contractAddress);

      final wrigoAddr = await getWRIGO();
      if (wrigoAddr == null) return false;
      final matchingInfo = await getChaincodeMatchingInfo(mdlChainId, mdlTokenAddress);
      if (matchingInfo == null) return false;
      final chainId       = STR(matchingInfo['chainId']);
      final tokenAddr     = STR(matchingInfo['addr']);

      final wrigoAddress  = EthereumAddress.fromHex(wrigoAddr);
      final tokenAddress  = EthereumAddress.fromHex(tokenAddr);

      LOG('---> runVmCall encodeData : $chainId / $contractAddress / $wrigoAddress / $tokenAddress');
      Uint8List encodeData = contract.function(functionName).
        encodeCall([
          BigInt.zero,
          ['rigo', 'rigo'],
          [wrigoAddress, tokenAddress],
          userAddress,
          BigInt.zero
        ]);
      final response = await http.get(
        Uri.parse('${networkModel.httpUrl}/vm_call?'
            'addr=$userAddress&'
            'to=$contractAddr&'
            'height=0&'
            'data=$encodeData'));
      print('--> runVmCall response : ${response.statusCode} / ${response.body}');
      if (response.statusCode == 200) {
        final resultJson = jsonDecode(response.body);
        if (resultJson['error'] == null &&
            resultJson['result']['value']['returnData'] != null) {
          final jsonValue = resultJson['result']['value']['returnData'];
          print('---> runVmCall jsonValue : [$jsonValue]');
          final abiType = getAbiOutType(contract.function(functionName));
          var result = '';
          print('---> runVmCall abiType : [$abiType]');
          result = getBase64String(jsonValue);
          print('---> runVmCall result : $result');
        }
      }
      return true;
    } catch (e) {
      print('---> runVmCall error : $e');
    }
    //  print('---> runVmCall [$functionName] result : $result');
    return false;
  }

  Future<String?> getSwapRatio(
      String mdlChainId,
      String mdlTokenAddress,
      String checkAmount,
      [bool isRigo = true]
      ) async {
    try {
      LOG('--> getSwapRatio: $mdlChainId, $mdlTokenAddress');
      final wrigo = await getWRIGO();
      if (wrigo == null) return null;
      final factory = await getFactory();
      if (factory == null) return null;
      final matchingInfo = await getChaincodeMatchingInfo(mdlChainId, mdlTokenAddress);
      if (matchingInfo == null) return null;
      final chainId = STR(matchingInfo['chainId']);
      final tokenAddress = STR(matchingInfo['addr']);
      final pair = await calcPair(factory, wrigo, chainId, tokenAddress);
      if (pair == null) return null;
      final reserve = await getReserves(pair);
      if (reserve != null) {
        final reserveJson = jsonDecode(reserve);
        LOG('--> getSwapRatio reserve : $reserve');
      // String bodyJson = '';
      // if (isRigo) {
      //   // from RIGO..
      //   bodyJson = jsonEncode({
      //     "pairAddress": pair,
      //     "inputChainId": "rigo",
      //     "inputToken": wrigo,
      //     "inputAmount": checkAmount,
      //     "outputChainId": chainId,
      //     "outputToken": tokenAddress,
      //   });
      // } else {
      //   // from MDL..
      //   bodyJson = jsonEncode({
      //     "pairAddress": pair,
      //     "inputChainId": chainId,
      //     "inputToken": tokenAddress,
      //     "outputAmount": checkAmount,
      //     "outputChainId": "rigo",
      //     "outputToken": wrigo,
      //   });
      // }
      // LOG('--> getSwapRatio body [$isRigo] : $bodyJson');
      // final http.Response response = await http.post(
      //   Uri.parse(httpUrl + '/api/v1/dex/${
      //     isRigo ? 'estimateSwapOutput' : 'estimateSwapInput'}'),
      //   headers: {
      //     'accept': 'application/json',
      //     'Content-Type': 'application/json',
      //   },
      //   body: bodyJson,
      // );
      // LOG('--> getSwapRatio response : ${response.statusCode} / ${response.body}');
      // return (response.statusCode == 200 || response.statusCode == 201) ? STR(response.body) : null;
      if (reserveJson['_reserve0'] != null) {
        final value0 = double.parse(STR(reserveJson['_reserve0']));
        final value1 = double.parse(STR(reserveJson['_reserve1']));
        final result = (value0 / value1).toStringAsFixed(18);
        LOG('--> getSwapRatio response : $result / ${pow(10, 18)} (${value0 / value1})');
        return (result).toString();
        }
      }
    } catch (e) {
      LOG('--> getSwapRatio error : $e');
    }
    return null;
  }

  String shift(String input, [int count = 1]) {
    String result = '';

    return result;
  }

  String shiftBack(String input, [int count = 1]) =>
      String.fromCharCodes([for (var c in input.runes) c - count]);

  Future<String?> getWRIGO() async {
    try {
      final http.Response response = await http.get(
        Uri.parse(httpUrl + '/api/v1/dex/getWRIGO'),
        headers: {
          'accept': 'text/plain',
        },
      );
      LOG('--> getWRIGO response : ${response.statusCode} / ${response.body}');
      return (response.statusCode == 200) ? response.body : null;
    } catch (e) {
      LOG('--> getWRIGO error : ${e.toString()}');
    }
    return null;
  }

  Future<String?> getFactory() async {
    try {
      final http.Response response = await http.get(
        Uri.parse(httpUrl + '/api/v1/dex/getFactory'),
        headers: {
          'accept': 'text/plain',
        },
      );
      LOG('--> getFactory response : ${response.statusCode} / ${response.body}');
      return (response.statusCode == 200) ? response.body : null;
    } catch (e) {
      LOG('--> getFactory error : ${e.toString()}');
    }
    return null;
  }

  Future<JSON?> getChaincodeMatchingInfo(
    String mdlChainId,
    String mdlTokenAddress,
    ) async {
    try {
      LOG('--> getChaincodeMatchingInfo : $mdlChainId / $mdlTokenAddress');
      final http.Response response = await http.get(
        Uri.parse(httpUrl + '/api/v1/dex/getChaincodeMatchingInfo?'
            'chanId=$mdlChainId&address=$mdlTokenAddress'),
        headers: {
          'accept': '*/*',
        },
      );
      LOG('--> getChaincodeMatchingInfo response : ${response.statusCode} / ${response.body}');
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      LOG('--> getChaincodeMatchingInfo error : ${e.toString()}');
    }
    return null;
  }

  Future<String?> calcPair(
      String factory,
      String wrigo,
      String chainId,
      String tokenAddress,
    ) async {
    try {
      final bodyJson = jsonEncode({
        "name": "DexCalc",
        "factory": factory,
        "chainIdA": "rigo",
        "tokenA": wrigo,
        "chainIdB": chainId,
        "tokenB": tokenAddress,
      });
      LOG('--> calcPair body : $bodyJson');
      final http.Response response = await http.post(
        Uri.parse(httpUrl + '/api/v1/dex/calcPair'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: bodyJson
      );
      LOG('--> calcPair response : ${response.statusCode} / ${response.body}');
      return (response.statusCode == 200 || response.statusCode == 201) ? response.body : null;
    } catch (e) {
      LOG('--> calcPair error : ${e.toString()}');
    }
    return null;
  }

  Future<String?> getReserves(
      String pair,
      ) async {
    try {
      final bodyJson = jsonEncode({
        "pairAddress": pair,
      });
      LOG('--> getReserves body : $bodyJson');
      final http.Response response = await http.post(
          Uri.parse(httpUrl + '/api/v1/dex/getReserves'),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: bodyJson
      );
      LOG('--> getReserves response : ${response.statusCode} / ${response.body}');
      return (response.statusCode == 200 || response.statusCode == 201) ? response.body : null;
    } catch (e) {
      LOG('--> getReserves error : ${e.toString()}');
    }
    return null;
  }

  String getAbiOutType(ContractFunction function, [String name = '']) {
    for (var item in function.outputs) {
      if (name.isEmpty || item.name == name) {
        return item.type.name.toLowerCase();
      }
    }
    return 'string';
  }

  String getBase64String(String? decodedText) {
    if (decodedText != null && decodedText.isNotEmpty) {
      try {
        //  print('---> getBase64String : ${''}');
        String tmp = utf8.decode(
            base64Decode(decodedText), allowMalformed: true);
        String result = tmp.replaceAll(RegExp('[^A-Za-z -_]'), '');
        return result.removeCharAt(0); // remove garbage char ???
      } catch (e) {
        print('---> getBase64String error : $e');
      }
    }
    return '';
  }

  String getBase64Number(String decodedText, [int decimalLength = 8]) {
    try {
      var bytes = base64Decode(decodedText);
      var bytesInt = BigInt.parse(bytesToHex(bytes), radix: 16);
      var doubleStr = BigDecimal.parse(bytesInt.toString());
      var defaultValue = BigDecimal.fromBigInt(BigInt.from(1));
      return doubleStr.divide(defaultValue,
          roundingMode: RoundingMode.HALF_UP, scale: decimalLength).toString();
    } catch (e) {
      print('---> getBase64Number error : $e');
    }
    return '0';
  }

  String getTokenBalance(String decodedText, [var decimals = 18]) {
    try {
      var bytes = base64Decode(decodedText);
      var tmp = BigInt.parse(bytesToHex(bytes), radix: 16).toString();
      var result = (double.parse(tmp) / pow(10, decimals)).toStringAsFixed(decimals);
      print('---> getTokenBalance : $tmp -> $result');
      return result;
    } catch (e) {
      print('---> getBase64Number error : $e');
    }
    return '0';
  }
}