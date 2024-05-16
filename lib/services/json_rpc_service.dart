import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:big_decimal/big_decimal.dart';
import '../../../common/const/constants.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../domain/model/coin_model.dart';
import '../../../domain/model/network_model.dart';
import '../../../domain/model/rpc/account.dart';
import '../../../domain/model/rpc/delegateInfo.dart';
import '../../../domain/model/rpc/governance_rule.dart';
import '../../../domain/model/rpc/validator.dart';
import '../../../domain/model/rpc/reward.dart';
import '../../../services/bridge_service.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/extensions/string_extensions.dart';
// import 'package:helpers/helpers.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../common/common_package.dart';

import '../common/const/utils/convertHelper.dart';
import '../common/dartapi/lib/trx_pb.pb.dart';
import '../common/trxHelper.dart';
import '../domain/model/rpc/tx_history.dart';

class ResultStake {
  final List<Stakes> stakes;
  final String receivedReward;
  ResultStake({
    required this.stakes,
    required this.receivedReward,
  });
}

class ResultStakesAndReward {
  final List<StakesAndReward> stakesAndReward;
  final String receivedReward;

  ResultStakesAndReward({
    required this.stakesAndReward,
    required this.receivedReward,
  });
}

class BroadcastTxResultCode {
  final int checkTx;
  final int deliverTx;
  Map checkResultTx;
  Map deliverResultTx;

  BroadcastTxResultCode(this.checkTx, this.deliverTx,
      this.checkResultTx, this.deliverResultTx);

  get jsonResult {
    var result = '';
    if (STR(deliverResultTx['events']).isNotEmpty) {
      for (var event in deliverResultTx['events']) {
        var type = event['type'];
        if (event['attributes'] != null && event['attributes'].isNotEmpty) {
          result += '[$type : ';
          for (var item in event['attributes']) {
            var key   = utf8.decode(base64Decode(item['key'] ?? ''));
            var value = utf8.decode(base64Decode(item['value'] ?? ''));
            var index = item['index'];
            result += '{$key : $value, ${index}}';
          }
        }
        result += ']';
      }
    }
    String data = deliverResultTx['data'] ?? '';
    // print('---> data [${JsonRpcService().getBase64String(data)}]');
    return result;
  }
}

class JsonRpcService {
  String? vmAbi;

  Future<Account> getAccountInfo(
      NetworkModel networkModel, String address) async {
    //  print('---> getAccount ${networkModel.name} / $address');
      var socket = WebSocketChannel.connect(
        Uri.parse(networkModel.url),
      );
      Client client = Client(socket.cast<String>());
      unawaited(client.listen());
      var accountInfo = await client.sendRequest(
          'account', {'addr': '$address'});
      // print('--> getAccountInfo : $accountInfo');
      client.close();
      return Account.fromJson(accountInfo['value']);
  }

  Future<int> broadcast_tx_sync(
      NetworkModel networkModel, String tx) async {
    //
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());
    var txResult = await client.sendRequest('broadcast_tx_sync', {'tx': tx});
    client.close();
     print('--> txResult : $txResult');
    return txResult['code'];
  }

  Future<BroadcastTxResultCode> broadcast_tx_commit(
      NetworkModel networkModel, String tx) async {
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());
    var txResult = await client.sendRequest('broadcast_tx_commit', {'tx': tx});
    client.close();
    print('--> txResult : [$txResult]');
    var checkTx   = txResult['check_tx'];
    var deliverTx = txResult['deliver_tx'];
    return BroadcastTxResultCode(checkTx["code"], deliverTx["code"], checkTx, deliverTx);
  }

  Future<String> getPayloadAmount(
      NetworkModel networkModel, String hash) async {
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());
    String encodedHash = base64Encode(createUint8ListFromHexString(hash));
    var result = await client.sendRequest('tx', {'hash': encodedHash});
    client.close();

    String payLoadTx = result['tx'];
    TrxProto decodedPayload = await TrxHelper().decodeTrx(payLoadTx);
    BigInt bigInt = BigInt.parse(bytesToHex(decodedPayload.amount), radix: 16);
    String amount = TrxHelper().getAmount(bigInt.toString());
    return amount;
  }

  Future<List<TxHistory>> getHistory(NetworkModel networkModel,
      String address, int page, int countPerPage) async {
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());
    var txData = await client.sendRequest('tx_search', {
      "query": "tx.addrpair CONTAINS '$address'",
      "page": "$page",
      "per_page": "$countPerPage",
      "order_by": "desc"
    });
    List searchList = txData['txs'];

    List<TxHistory> txHistoryList = [];

    for (var search in searchList) {
      TrxProto decoded = await TrxHelper().decodeTrx(search['tx']);
      TxHistory txHistory = TxHistory.fromTrxProto(decoded);
      // print('--> getHistory item : ${txHistory.log}');
      if (txHistory.transactionType < 4 || txHistory.transactionType == 6) {
        String from = txHistory.from;
        String to = txHistory.to;
        int transactionType = txHistory.transactionType;
        String payloadTx = txHistory.payloadTx;
        // var contractJson = txHistory.contractJson;
        //  print('--> searchList item : ${txHistory.log} / ${contractJson.toString()}');

        if (payloadTx != '' && txHistory.transactionType != 6) {
          String stakingTxHash = base64Encode(createUint8ListFromHexString(payloadTx));
          var result = await client.sendRequest('tx', {'hash': stakingTxHash});
          TrxProto stakingTrx = await TrxHelper().decodeTrx(result['tx']);
          BigInt bigAmount = BigInt.parse(bytesToHex(stakingTrx.amount), radix: 16);
          String unstakingAmount = TrxHelper().getAmount(bigAmount.toString());
          txHistory.amount = unstakingAmount;
        }

        // txHistory.amount = getFormattedText(
        //     value: double.parse(txHistory.amount),
        //     decimalPlaces: DECIMAL_PLACES);

        if (transactionType == 1) {
          if (from == address && to != address)
            txHistory.type = HistoryType.sent;
          if (to == address && from != address)
            txHistory.type = HistoryType.received;
        }
        else if (transactionType == 6) {
          if (from == address && to != address)
            txHistory.type = HistoryType.sentToken;
          if (to == address && from != address)
            txHistory.type = HistoryType.receivedToken;
        }

        if (to == address && from == address) {
          if (transactionType == 2) txHistory.type = HistoryType.staking;
          if (transactionType == 3) txHistory.type = HistoryType.unStaking;
        }

        if (to != address && from == address) {
          if (transactionType == 2) txHistory.type = HistoryType.delegating;
          if (transactionType == 3) txHistory.type = HistoryType.unDelegating;
        }

        // 거래내역 상세화면에서 보여 주는 TxId
        txHistory.txId = search['hash'];

        txHistoryList.add(txHistory);
      }
    }
    client.close();
    return txHistoryList;
  }

  Future<List<ValidatorList>> getValidators(
      NetworkModel networkModel) async {
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());
    var blockInfo = await client.sendRequest('block', {});

    String blockHeight = blockInfo['block']['last_commit']['height'];

    var validatorResult =
        await client.sendRequest('validators', {'height': blockHeight});
    var response_validator = Response_Validator.fromJson(validatorResult);

    List<ValidatorList> va = [];

    List<Validators> validatorList = response_validator.validators ?? [];

    for (Validators val in validatorList) {
      var delegateResult =
          await client.sendRequest('delegatee', {'addr': '0x' + val.address!});
      DelegateInfo delegateInfo =
          DelegateInfo.fromJson(delegateResult['value']);

      var rewardResult =
          await client.sendRequest('reward', {'addr': '0x' + val.address!});
      Reward reward = Reward.fromJson(rewardResult['value']);

      // 총 스테이킹 량 (위임+스테이킹)
      String strAmount =
          BigInt.parse(delegateInfo.totalPower ?? '0').toString();

      // 총 보상량
      String strReward = BigInt.parse(reward.cumulated ?? '0').toString();

      va.add(
        ValidatorList(
            validators: delegateInfo.address,
            amount: strAmount,
            rewardAmount: TrxHelper().getAmount(strReward)),
      );
    }
    client.close();
    return va;
  }

  //Delegatee rpc api 를 이용해 보상금액 총합과 스테이킹 수량을 알 수 있음.
  //스테이킹 과 위임 화면의 보상 총합은 해당 함수의 rewardAmout.
  //현재 스테이킹 수량은 selfAmount.
  Future<DelegateInfo> getDelegateInfo(
      NetworkModel networkModel) async {
    String address = await UserHelper().get_address();
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());

    var delegateResult =
        await client.sendRequest('delegatee', {'addr': address});
    client.close();
    DelegateInfo delegateInfo = DelegateInfo();
    if (delegateResult['value'] != null) {
      delegateInfo = DelegateInfo.fromJson(delegateResult['value']);
    } else {
      return DelegateInfo();
    }

    String seflPower = BigInt.parse(delegateInfo.selfPower ?? '0').toString();
    String totalPower = BigInt.parse(delegateInfo.totalPower ?? '0').toString();
    delegateInfo.selfPower = TrxHelper().getAmount(seflPower);
    delegateInfo.totalPower = TrxHelper().getAmount(totalPower);

    // var rewardResult = await client.sendRequest('reward', {'addr': '0x' + address});
    // Reward reward = Reward.fromJson(rewardResult['value']);
    // String cumulated = BigInt.parse(reward.cumulated ?? '0').toString(); // 총 보상량 (폰즈단위)
    // delegateInfo.rewardAmount = TrxHelper().getAmount(cumulated, scale: 2);

    return delegateInfo;
  }

  //스테이킹 리스트 TODO
  Future<ResultStake> getMyStakeList(NetworkModel networkModel) async {
    DelegateInfo delegateInfo = await getDelegateInfo(networkModel);
    List<Stakes> stakeList = [];
    BigInt cumulated = BigInt.zero;

    for (Stakes stake in delegateInfo.stakes ?? []) {
      TrxHelper trxHelper = TrxHelper();
      Reward rewardInfo = await getReward(networkModel, stake.to ?? "");
      cumulated += BigInt.parse(rewardInfo.cumulated ?? '0');

      if (stake.owner == stake.to) {
        var power = BigInt.parse(stake.power ?? '0').toString();
        stake.power = trxHelper.getAmount(power);
        stakeList.add(stake);
      }
    }
    String receivedReward = cumulated.toString();

    return ResultStake(
        stakes: stakeList,
        receivedReward: TrxHelper().getAmount(receivedReward, scale: 10));
  }

  //내가 한 위임 리스트
  Future<ResultStakesAndReward> getMyDelegateList(
      NetworkModel networkModel) async {
    String address = await UserHelper().get_address();
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());
    var stakeResult =
        await client.sendRequest('stakes', {'addr': '0x' + address});
    client.close();

    List<StakesAndReward> stakesAndReward = [];
    BigInt cumulated = BigInt.zero;

    List stakeList = stakeResult['value'] ?? [];
    String myAddress = await UserHelper().get_address();
    myAddress = myAddress.toUpperCase();

    for (var getStake in stakeList) {
      Stakes stake = Stakes.fromJson(getStake);

      if (stake.owner == myAddress) {
        if (stake.to != myAddress) {
          Reward rewardInfo = await getReward(networkModel, myAddress);
          cumulated += BigInt.parse(rewardInfo.cumulated ?? '0');
          var sr = StakesAndReward(stake, '0.0', reward: rewardInfo.cumulated);
          stakesAndReward.add(sr);
        }
      }
    }

    String receivedReward = cumulated.toString();
    return ResultStakesAndReward(
        stakesAndReward: stakesAndReward,
        receivedReward: TrxHelper().getAmount(receivedReward, scale: 18));
  }

  Future<List<Stakes>> getStakes(
      NetworkModel networkModel, StakeType type) async {
    String address = await UserHelper().get_address();
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());
    var delegateResult =
        await client.sendRequest('delegatee', {'addr': address});
    client.close();

    DelegateInfo delegateInfo = DelegateInfo.fromJson(delegateResult['value']);
    List<Stakes> stakeList = delegateInfo.stakes ?? [];
    List<Stakes> staking = [];
    List<Stakes> delegate = [];

    for (Stakes stake in stakeList) {
      /*
      // TODO
      TrxHelper trxHelper = TrxHelper();
      // 현재 블록에서 리워드량, 총 리워드 량
      var rewardResult = await client.sendRequest('reward', {'addr': stake.to});
      Reward reward = Reward.fromJson(rewardResult['value']);

      String cumulated = BigInt.parse(reward.cumulated ?? '0').toString(); // 총 위임량
      //var cumulated = TrxHelper().getAmount(cumulated, scale: 10); // 총 위임량

      var blockRewardUnit = BigInt.parse(reward.issued ?? '0').toString();
      var receivedReward = BigInt.parse(reward.cumulated ?? '0').toString();

      // var amount = BigInt.parse(stake.power ?? '0').toString();
      // var blockRewardUnit = BigInt.parse(stake.blockRewardUnit ?? '0').toString();
      // var receivedReward = BigInt.parse(stake.receivedReward ?? '0').toString();

      // stake.power = trxHelper.getAmount(amount);
      // stake.blockRewardUnit = trxHelper.getAmount(blockRewardUnit, scale: 10);
      // stake.receivedReward = trxHelper.getAmount(receivedReward, scale: 10);
      */

      if (stake.owner == stake.to) {
        // 본인이 본인한테 스테이킹
        staking.add(stake);
      } else {
        delegate.add(stake); // 본인이 검증인에게 위임
      }
    }

    if (type == StakeType.Stake) {
      return staking;
    } else {
      return delegate;
    }
  }

/*
  // TODO
  Future<List<Stakes>> getReward(
      NetworkModel networkModel, StakeType type) async {
    String address = await UserHelper().get_address();
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());
    var delegateResult =
    await client.sendRequest('delegatee', {'addr': address});
    client.close();

    DelegateInfo delegateInfo = DelegateInfo.fromJson(delegateResult['value']);
    List<Stakes> stakeList = delegateInfo.stakes ?? [];
    List<Stakes> staking = [];
    List<Stakes> delegate = [];

    for (Stakes stake in stakeList) {
      TrxHelper trxHelper = TrxHelper();

      // 현재 블록에서 리워드량, 총 리워드 량
      var rewardResult = await client.sendRequest('reward', {'addr': stake.owner});
      Reward reward = Reward.fromJson(rewardResult['value']);
      String cumulated = BigInt.parse(reward.cumulated ?? '0').toString(); // 총 위임량
      var cumulated = TrxHelper().getAmount(cumulated, scale: 10); // 총 위임량


      // var amount = BigInt.parse(stake.power ?? '0').toString();
      // var blockRewardUnit = BigInt.parse(stake.blockRewardUnit ?? '0').toString();
      // var receivedReward = BigInt.parse(stake.receivedReward ?? '0').toString();

      stake.power = trxHelper.getAmount(amount);
      stake.blockRewardUnit = trxHelper.getAmount(blockRewardUnit, scale: 10);
      stake.receivedReward = trxHelper.getAmount(receivedReward, scale: 10);

      if (stake.owner == stake.to) { // 본인이 본인한테 스테이킹
        staking.add(stake);
      } else {
        delegate.add(stake); // 본인이 검증인에게 위임
      }
    }

    if (type == StakeType.Stake) {
      return staking;
    } else {
      return delegate;
    }
  }
 */

  Future<String> getStakeReward(
      NetworkModel networkModel, StakeType type) async {
    List<Stakes> list = await getStakes(networkModel, type);

    BigInt bi = BigInt.zero;

    for (Stakes stake in list) {
      Reward reward = await getReward(networkModel, stake.to ?? '');
      bi += BigInt.parse(reward.cumulated ?? '0');
    }

    String strAmount = bi.toString();
    return TrxHelper().getAmount(strAmount);
  }

  // TODO
  Future<GovernanceRule> getGovernanceRule(
      NetworkModel networkModel) async {
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());
    var ruleInfo = await client.sendRequest('rule', {});
    client.close();

    GovernanceRule rule = GovernanceRule.fromJson(ruleInfo['value']);
    // String strAmountPerPower =
    //     BigInt.parse(rule.amountPerPower ?? '').toString();
    String strRewardPerPower =
        BigInt.parse(rule.rewardPerPower ?? '0').toString();
    //String strMinTrxFee = BigInt.parse(rule.minTrxGas ?? '').toString();

    // rule.amountPerPower = TrxHelper().getAmount(strAmountPerPower, scale: 4);
    rule.rewardPerPower = TrxHelper().getAmount(strRewardPerPower, scale: 18);
    // rule.minTrxFee = TrxHelper().getAmount(strMinTrxFee, scale: 4);

    //print(rule.toJson());
    return rule;
  }

  Future<String> getStakesAmount(NetworkModel networkModel) async {
    DelegateInfo delegateInfo = await getDelegateInfo(networkModel);
    double parsed = double.parse(delegateInfo.selfPower ?? '0.0');
    return parsed.toInt().toString();
  }

  /*
  Future<String> getDelegateAmount(NetworkModel networkModel) async {
    double delegateAmount = 0;
    ResultStake resultStake = await getMyDelegateList(networkModel);
    for (Stakes stakes in resultStake.stakes) {
      String biAmount = BigInt.parse(stakes.power!).toString();
      delegateAmount += double.parse(TrxHelper().getAmount(biAmount));
    }
    return delegateAmount.toInt().toString();
  }
  */

  Future<String> getDelegateAmount(NetworkModel networkModel) async {
    ResultStakesAndReward resultStakesAndReward =
        await getMyDelegateList(networkModel);
    BigInt delegateAmount = BigInt.from(0);

    for (StakesAndReward sr in resultStakesAndReward.stakesAndReward) {
      var biAmount = BigInt.parse(sr.stakes.power ?? '0.0');
      delegateAmount += biAmount;
    }
    return delegateAmount.toString();
  }

  Future<Reward> getReward(
      NetworkModel networkModel, String toAddress) async {
    if (toAddress == '') {
      String address = await UserHelper().get_address();
      toAddress = address;
    }
    var socket = WebSocketChannel.connect(
      Uri.parse(networkModel.url),
    );
    Client client = Client(socket.cast<String>());
    unawaited(client.listen());
    var rewardResult =
        await client.sendRequest('reward', {'addr': '0x' + toAddress});
    client.close();

    Reward rewardInfo = Reward.fromJson(rewardResult['value']);
    return rewardInfo;
  }

  Future<String?> getNetworkInfo(NetworkModel networkModel) async {
    try {
      final response = await http.get(
          Uri.parse('${networkModel.httpUrl}/genesis'));
      var result = jsonDecode(response.body);
      // LOG('---> getNetworkInfo response : ${response.statusCode} / '
      //   '${result['result'] != null} / ${result['result']['genesis'] != null}');
      if (response.statusCode == 200 && result['result'] != null && result['result']['genesis'] != null) {
        return result['result']['genesis']['chain_id'];
      }
    } catch (e) {
      LOG('---> getNetworkInfo error : $e');
    }
    return null;
  }

  //////////////////////////////////////////////////////////////////////////
  //
  //  TOKEN methods
  //

  Future<String> getTokenDetail(
      NetworkModel networkModel, String toAddress) async {
    try {
      var socket = WebSocketChannel.connect(
        Uri.parse(networkModel.url),
      );
      Client client = Client(socket.cast<String>());
      unawaited(client.listen());
      var rewardResult = await client.sendRequest(
          'token_detail', {'addr': '0x' + toAddress});
      client.close();

      return rewardResult['value'];
    } catch (e) {
      print('---> getTokenDetail error : $e');
    }
    return '';
  }

  Future<String?> runVmCall(
      NetworkModel networkModel,
      String functionName, String contractAddr, {
      String? fromAddr, String? toAddr, String? amount}) async {
    var result = '';
    if (contractAddr.length != 42) return null;
    vmAbi ??= await rootBundle.loadString('assets/abi/erc20_abi.json');
    final contractAddress = EthereumAddress.fromHex(contractAddr);
    final fromAddress = EthereumAddress.fromHex(fromAddr ?? contractAddr);
    final contract = new DeployedContract(
        new ContractAbi.fromJson(vmAbi!, 'Erc20Token'), contractAddress);
    try {
      Uint8List encodeData;
      switch (functionName) {
        case 'balanceOf':
          encodeData = contract.function(functionName).encodeCall([fromAddress]);
          break;
        case 'transfer':
          final toAddress = EthereumAddress.fromHex(
              toAddr ?? fromAddr ?? contractAddr);
          final bigAmount = getSendAmount(amount ?? '0');
          encodeData = contract.function(functionName).encodeCall(
              [toAddress, bigAmount]);
          break;
        default:
          encodeData = contract.function(functionName).encodeCall([]);
          break;
      }
      final response = await http.get(
          Uri.parse('${networkModel.httpUrl}/vm_call?'
              'addr=$fromAddress&'
              'to=$contractAddr&'
              'height=0&'
              'data=$encodeData'));
       // print('--> runVmCall [$functionName] response : ${response.statusCode} / ${response.body}');
      if (response.statusCode == 200) {
        final resultJson = jsonDecode(response.body);
        if (resultJson['error'] == null &&
            resultJson['result']['value']['returnData'] != null) {
          final jsonValue = resultJson['result']['value']['returnData'];
          final abiType = getAbiOutType(contract.function(functionName));
          //  print('---> runVmCall abiType : [$abiType]');
          switch (abiType) {
            case 'string':
              result = getBase64String(jsonValue);
              break;
            case 'uint8':
              result = getBase64Number(jsonValue, 0);
              break;
            default:
              result = getTokenBalance(jsonValue);
          }
        }
      }
      if (result.isEmpty) {
        final abiType = getAbiOutType(contract.function(functionName));
        switch (abiType) {
          case 'string': result = ''; break;
          case 'uint8': result = '0'; break;
          default: result = '0.0';
        }
      }
    } catch (e) {
       print('---> runVmCall error : $e');
    }
    //  print('---> runVmCall [$functionName] result : $result');
    return result;
  }

  // // for TEST..
  // Future<double> sendToken(
  //     NetworkModel networkModel,
  //     EthereumAddress contractAddr,
  //     EthereumAddress fromAddress, EthereumAddress toAddress, double amount) async {
  //   var result = 0.0;
  //   final abi = await rootBundle.loadString('assets/abi/erc20_abi.json');
  //   final contract = new DeployedContract(
  //       new ContractAbi.fromJson(abi, 'Erc20Token'), contractAddr);
  //   final bigAmount = getSendAmount(amount);
  //   final encodeData = contract.function('transfer').encodeCall([toAddress, BigInt.from(amount)]);
  //    print('--> sendToken : ${BigInt.from(amount)}');
  //
  //   final response = await http.get(
  //       Uri.parse('${networkModel.httpUrl}/vm_call?'
  //           'addr=${fromAddress.hexEip55}&'
  //           'to=${contractAddr.hexEip55}&'
  //           'height=0&'
  //           'data=$encodeData'));
  //    print('--> sendToken response.body : ${response.body}');
  //   if (response.statusCode == 200) {
  //     final resultJson = jsonDecode(response.body);
  //     if (resultJson['error'] == null) {
  //       final data = uint8ListToHexString(
  //           base64Decode(resultJson['result']['value']['returnData']));
  //       result = double.parse(data);
  //     }
  //   }
  //   return result;
  // }

  // Future<bool> addMDLToken(NetworkModel networkModel, String contractAddress) async {
  //   final response = await http.get(
  //       Uri.parse('${networkModel.httpUrl}/api/v1/account/addToken?'
  //           'channel=ch1&'
  //           'chaincode=${networkModel.chainCode}&'
  //           'address=$contractAddress'));
  //   // 'address=0xfef705700f04ccb3c722d12ba8217fc0b50529ac')); // for Test..
  //   print('--> addMDLToken [$contractAddress] response : ${response.statusCode} / ${response.body}');
  //   if (response.statusCode == 200 && response.body.isNotEmpty) {
  //     final resultJson = jsonDecode(response.body);
  //     return true;
  //   }
  //   return false;
  // }

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
      // print('---> getTokenBalance : $tmp -> $result');
      return result;
    } catch (e) {
      print('---> getBase64Number error : $e');
    }
    return '0';
  }

  String getTokenBalanceNo64(String decodedText, [var decimals = 18]) {
    var result = '0';
    try {
      if (decodedText.contains('.') || decodedText.length < decimals) {
        result = (double.parse(decodedText) / pow(10, decimals)).round().toStringAsFixed(decimals);
        // print('---> getTokenBalanceNo64 : ${double.parse(decodedText)} -> $result');
      } else {
        var integerStr = decodedText.substring(0, (decodedText.length - decimals).toInt());
        var decimalStr = decodedText.substring((decodedText.length - decimals).toInt(), decimals);
        var decimalNum = '';
        for (var i=decimalStr.length-1; i>=0; i--) {
          if (decimalNum.isNotEmpty || decimalStr[i] != '0') {
            decimalNum = decimalStr[i] + decimalNum;
          }
        }
        // return result.toString();
        // print('---> getTokenBalanceNo64 text1 : $integerStr / $decimalStr -> $decimalNum');
        return decimalNum.isNotEmpty ? '$integerStr.$decimalNum' : integerStr;
      }
    } catch (e) {
      print('---> getTokenBalanceNo64 error : $e');
    }
    return result;
  }

  String uint8ListToHexString(Uint8List uint8list) {
    var hex = "";
    for (var i in uint8list) {
      var x = i.toRadixString(16);
      if (x.length == 1) {
        x = "0$x";
      }
      hex += x;
    }
    return hex;
  }

  EthereumAddress Eip55Address(String addr) {
    try {
      return EthereumAddress.fromHex(addr, enforceEip55: true);
    } catch (e) {
      //  print('--> Eip55Address error : $e');
    }
    return EthereumAddress.fromHex(addr);
  }
}

final jsonRpcServiceProvider =
    Provider.autoDispose<JsonRpcService>((ref) => JsonRpcService());

enum StakeType {
  Stake,
  Delegate,
}
