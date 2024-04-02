import 'dart:convert';
import 'dart:math';

import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/domain/model/coin_model.dart';
import 'package:larba_00/domain/model/network_model.dart';
import 'package:larba_00/domain/model/rpc/tx_history.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import '../common/const/utils/aesManager.dart';
import '../common/const/utils/convertHelper.dart';
import '../common/const/utils/eccManager.dart';
import '../common/trxHelper.dart';
import '../domain/model/address_model.dart';
import '../domain/model/mdl_history_model.dart';

class MdlRpcService {

  //////////////////////////////////////////////////////////////////////////
  //
  //  MDL methods
  //


  // Auto Check Network..
  Future<JSON?> checkNetworkAuto(String checkUrl, String method,
      {String url = '', String chainId = ''}) async {
    if (url.isEmpty && chainId.isEmpty) return null;
    final sendUrl = '$checkUrl/$method?${
        url.isNotEmpty ? 'url=$url' : 'chainId=$chainId'
    }';
    print('--> checkNetworkInfo : $sendUrl');
    final response = await http.get(Uri.parse(sendUrl));
    print('--> checkNetworkInfo response : ${response.statusCode} / ${response.body}');
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<JSON?> getTokenInfo(NetworkModel networkModel, String chainCode, String channel) async {
    try {
      print('--> getTokenInfo : $chainCode / $channel');
      final http.Response response = await http.get(
        Uri.parse(networkModel.httpUrl + '/api/v1/token/getTokenInfo?chaincode=$chainCode&channel=$channel'),
        headers: {'accept': 'application/json'},
      );
      print('--> getTokenInfo response : [${networkModel.httpUrl}] ${response.statusCode} / ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('--> getTokenInfo error : $e');
    }
  }

  Future<String> balanceOf(NetworkModel networkModel, CoinModel coin) async {
    try {
      print('--> MDL balanceOf : ${coin.channel} / ${coin.chainCode} / ${coin.walletAddress}');
      final http.Response response = await http.post(
        Uri.parse(networkModel.httpUrl + '/api/v1/token/balanceOf'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "chaincode": coin.chainCode,
          "channel":   coin.channel,
          "address": '0x${coin.walletAddress}',
        }),
      );
      print('--> MDL balanceOf response : [${networkModel.httpUrl}] ${response.statusCode} / ${response.body}');
      // return response.body;
      return getTokenBalanceNo64(response.body, coin.decimalNum);
    } catch (e) {
      print('--> balanceOf error : $e');
    }
    return '0.0';
  }

  Future<String?> createTransaction(
    String httpUrl, String channel, String chainCode, {String function = "Transfer"}) async {
    try {
      final jsonBody = {
        "channel"  : channel,
        "chaincode": chainCode,
        "function" : function
      };
      print('--> createTransaction : $jsonBody');
      final http.Response response = await http.post(
        Uri.parse(httpUrl + '/api/v1/chaincode/createTransaction'),
        headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonBody),
      );
      print('--> createTransaction response : ${response.statusCode} / ${response.body}');
      return response.body;
    } catch (e) {
      print('--> createTransaction error : $e');
    }
    return null;
  }

  Future<String?> encodeSign(String httpUrl, String channel, String sign) async {
    try {
      print('--> encodeSign : $httpUrl / $channel / $sign');
      final http.Response response = await http.post(
        Uri.parse(httpUrl + '/api/v1/utils/encodeSign?sign=$sign'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      print('--> encodeSign response : ${response.statusCode} / ${response.body}');
      return response.body;
    } catch (e) {
      print('--> encodeSign error : $e');
    }
    return null;
  }

  Future<bool> transfer(
      NetworkModel networkModel,
      CoinModel coin,
      String privateKey,
      String to,
      String amount
    ) async {
    try {
      print('--> transfer privateKey : $privateKey');
      final txId = await createTransaction(networkModel.httpUrl, STR(networkModel.channel), STR(coin.chainCode));
      if (txId == null) return false;
      final sign = await getSignature(privateKey, txId);
      if (sign == null) return false;
      final encodedSign = await encodeSign(networkModel.httpUrl, STR(networkModel.channel), sign);
      print('--> transfer : ${networkModel.channel} / ${coin.chainCode} -> $to, $encodedSign, $amount');
      if (encodedSign == null) return false;
      final bodyJson = jsonEncode({
        "channel": networkModel.channel,
        "chaincode": coin.chainCode,
        "txId": txId,
        "encodedSenderSign": encodedSign,
        "to": '0x$to',
        "amount": amount,
      });
      final http.Response response = await http.post(
        Uri.parse(networkModel.httpUrl + '/api/v1/token/transfer'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: bodyJson
      );
      print('--> transfer response : [${networkModel.httpUrl}] ${response.statusCode} / ${response.body}');
      return (response.statusCode == 200 || response.statusCode == 201) ? BOL(response.body) : false;
      // return getTokenBalanceNo64(response.body, coin.decimalNum);
    } catch (e) {
      print('--> transfer error : $e');
    }
    return false;
  }

  Future<bool> burn(
      String privateKey,
      NetworkModel network,
      CoinModel coin,
      String toChainId,
      String toTokenAddressxxx,
      String toAddress,
      String amount
    ) async {
    try {
      print('--> burn: $toAddress, $amount');
      final txId = await createTransaction(network.httpUrl, STR(network.channel), 'Minter', function: "Burn");
      if (txId == null) return false;
      final sign = await getSignature(privateKey, txId);
      if (sign == null) return false;
      final encodedSign = await encodeSign(network.httpUrl, STR(network.channel), sign);
      if (encodedSign == null) return false;
      final toTokenAddress = await getToTokenAddress(STR(network.chainId), STR(coin.chainCode));
      if (toTokenAddress == null) return false;
      final bodyJson = {
        "channel": STR(network.channel),
        "chaincode": STR(coin.chainCode),
        "txId": txId,
        "encodedSenderSign": encodedSign,
        "fromChainId": STR(network.chainId),
        "fromTokenAddress": STR(coin.chainCode),
        "toChainId": "rigo",
        "toTokenAddress": toTokenAddress,
        "toUserAddress": '0x$toAddress',
        "amount": amount,
      };
      print('--> burn body : $bodyJson');
      final http.Response response = await http.post(
        Uri.parse(network.httpUrl + '/api/v1/swap/burn'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyJson),
      );
      print('--> burn response : ${response.statusCode} / ${response.body}');
      return (response.statusCode == 200 || response.statusCode == 201) ? BOL(response.body) : false;
      // return getTokenBalanceNo64(response.body, coin.decimalNum);
    } catch (e) {
      print('--> burn error : $e');
    }
    return false;
  }

  Future<List<TxHistory>> getHistory(NetworkModel networkModel, CoinModel coin) async {
    List<TxHistory> result = [];
    try {
      print('--> MDL getHistory : ${networkModel.channel} / ${coin.chainCode} / ${coin.walletAddress}');
      final http.Response response = await http.post(
        Uri.parse(networkModel.httpUrl + '/api/v1/token/getTransferHistory'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'channel': networkModel.channel,
          'chaincode': coin.chainCode,
          'address': '0x${coin.walletAddress}',
        })
      );
      print('--> MDL getHistory response : [${networkModel.httpUrl}] ${response.statusCode} / ${response.body} / ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = jsonDecode(response.body);
        for (var item in jsonData) {
          var historyModel = MDLHistoryModel.fromJson(item);
          var historyType = await getHistoryType(historyModel, coin.walletAddress);
          var txId = historyModel.txId.contains('0x') ? historyModel.txId.substring(2, historyModel.txId.length) : historyModel.txId;
          var txItem = TxHistory(
            token:  coin.symbol,
            time:   historyModel.time,
            from:   getVoidAddress(historyModel.from),
            to:     getVoidAddress(historyModel.to),
            amount: getTokenBalanceNo64(historyModel.value),
            gas:    '0',
            type:   historyType,
            txId:       txId,
            payloadTx:  txId,
            transactionType: TransactionType.TRX_TRANSFER.index,
            peeToken: coin.symbol,
          );
          // print('--> historyItem ${txItem.payloadTx}');
          result.insert(0, txItem);
        }
      }
    } catch (e) {
      LOG('--> getHistory error : $e');
    }
    return result;
  }

  Future<String?> getToTokenAddress(String fromChainId, String fromTokenAddress) async {
    final rigo_api_url = "http://52.78.111.39:3003";
    try {
      print('--> getTokenAddress : $fromChainId / $fromTokenAddress');
      final http.Response response = await http.get(
        Uri.parse(rigo_api_url +
            '/api/v1/dex/getChaincodeMatchingInfo?chanId=$fromChainId&address=$fromTokenAddress'),
      );
      print('--> getTokenAddress response : ${response.statusCode} / ${response.body}');
      if (response.statusCode == 200) {
        final resultJson = jsonDecode(response.body);
        return STR(resultJson['addr']);
      }
    } catch (e) {
      LOG('--> getTokenAddress error : ${e.toString()}');
    }
  }

  // 실제 사용가능한 메인넷인지 체크..
  Future<bool> validateNetwork(NetworkModel networkModel) async {
    if (networkModel.httpUrl.isEmpty && networkModel.chainId.isEmpty) return false;
    final sendUrl = '${networkModel.httpUrl}/api/v1/common/ping';
    print('--> validateNetwork : $sendUrl');
    final response = await http.get(Uri.parse(sendUrl));
    print('--> validateNetwork response : ${response.statusCode} / ${response.body}');
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return true;
    }
    return false;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  MDL utils
  //

  getVoidAddress(String address) {
    if (address.substring(0, 2) == '0x') {
      return address.substring(2);
    }
    return address;
  }

  Future<HistoryType> getHistoryType(MDLHistoryModel historyModel, String address) async {
    if (getVoidAddress(address) == getVoidAddress(historyModel.from)) {
      return HistoryType.sent;
    }
    if (getVoidAddress(address) == getVoidAddress(historyModel.to)) {
      return HistoryType.received;
    }
    var accountStr  = await UserHelper().get_addressList();
    var accountJson = jsonDecode(accountStr);
    for (var item in accountJson) {
      AddressModel model = AddressModel.fromJson(item);
      // LOG('--> getHistoryType check : '
      //     '${getVoidAddress(model.address ?? '')} / '
      //     '${getVoidAddress(historyModel.from)}');
      if (getVoidAddress(model.address ?? '') == getVoidAddress(historyModel.from)) {
        LOG('-----> is SEND');
        return HistoryType.sent;
      }
    }
    LOG('-----> is RECEIVED');
    return HistoryType.received;
  }

  Future<String> getPublicKey(String privateKey) async {
    final privateKeyObject = EthPrivateKey.fromHex(privateKey); // Create a private key object from the provided private key string
    final address = await privateKeyObject.address; // Get the public address associated with the private key
    return address.hex; // Return the public address as a hexadecimal string
  }

  Future<String?> getSignature(
      String privateKey,
      String msg,
      ) async {
    try {
      final eccManager = EccManager();
      var signature = await eccManager.signingEx(privateKey, msg);
      LOG('---> getSignature : $signature <= $privateKey');
      return signature;
    } catch (e) {
      LOG('--> getSignature error : ${e.toString()}');
    }
    return null;
  }

  String getTokenBalanceNo64(String decodedText, [var decimals = 18]) {
    var result = '0';
    try {
      result = (double.parse(decodedText) / pow(10, decimals)).toStringAsFixed(decimals);
      // print('---> getTokenBalanceNo64 : $decodedText -> $result');
    } catch (e) {
      print('---> getTokenBalanceNo64 error : $e');
    }
    return result;
  }
}