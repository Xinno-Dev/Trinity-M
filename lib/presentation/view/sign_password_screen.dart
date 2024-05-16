import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import '../../../common/common_package.dart';
import '../../../common/const/utils/userHelper.dart';
import '../../../common/const/widget/PinBox.dart';
import '../../../common/const/widget/dialog_utils.dart';
import '../../../common/const/widget/num_pad.dart';
import '../../../common/const/widget/wrong_password_dialog.dart';
import '../../../common/dartapi/lib/trx_pb.pb.dart';
import '../../../common/provider/coin_provider.dart';
import '../../../common/provider/stakes_data.dart';
import '../../../common/provider/temp_provider.dart';
import '../../../common/rlp/rlpEncoder.dart';
import '../../../common/trxHelper.dart';
import '../../../domain/model/rpc/governance_rule.dart';
import '../../../presentation/view/asset/send_completed_screen.dart';
import '../../../presentation/view/main_screen.dart';
import '../../../services/bridge_service.dart';
import '../../../services/json_rpc_service.dart';
import '../../../services/mdl_rpc_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider;
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

import '../../common/const/utils/aesManager.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../common/const/utils/eccManager.dart';
import '../../common/const/utils/languageHelper.dart';
import '../../common/const/widget/back_button.dart';
import '../../common/provider/network_provider.dart';
import '../../domain/model/ecckeypair.dart';
import '../../domain/model/network_model.dart';
import '../../domain/model/rpc/account.dart';
import '../../domain/model/rpc/delegateInfo.dart';
import '../../domain/model/rpc/staking_type.dart';
import '../../services/localization_service.dart';

class SignPasswordScreen extends ConsumerStatefulWidget {
  const SignPasswordScreen({
    this.receivedAddress,
    this.sendAmount,
  });
  static String get routeName => 'sign_password';
  final String? receivedAddress;
  final String? sendAmount;

  @override
  ConsumerState<SignPasswordScreen> createState() => _SignPasswordScreenState();
}

class _SignPasswordScreenState extends ConsumerState<SignPasswordScreen> {
  TrxHelper trxHelper = TrxHelper();

  List<int> pin = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  String inputPin = '';
  late String receivedAddress;
  late String sendAmount;
  bool isChecked = false;
  bool isReset = false;
  bool isSending = false;

  @override
  void initState() {
    pin.shuffle();

    if (widget.receivedAddress != null) {
      receivedAddress = widget.receivedAddress!;
    }
    if (widget.sendAmount != null) {
      sendAmount = widget.sendAmount!;
    }

    super.initState();
  }

  void _deletePress() {
    setState(() {
      if (inputPin.length > 0) {
        inputPin = inputPin.substring(0, inputPin.length - 1);
      }
    });
  }

  void _refreshPress() {
    setState(() {
      inputPin = '';
    });
  }

  Future<String> getPrivateKey() async {
    final keyData = await UserHelper().get_key();
    final shaConvert = sha256.convert(utf8.encode(inputPin));
    final keyStr = await AesManager().decrypt(shaConvert.toString(), keyData);
    final keyJson = EccKeyPair.fromJson(jsonDecode(keyStr));
    return keyJson.d;
  }

  String getLoadingText(StakingType stakingType) {
    switch (stakingType) {
      case StakingType.staking:
        return '스테이킹이 진행중 입니다.';
      case StakingType.unStaking:
        return '스테이킹이 종료중 입니다.';
      case StakingType.delegate:
        return '위임이 진행중 입니다.';
      case StakingType.unDelegate:
        return '위임이 종료중 입니다.';
      case StakingType.setDoc:
        return '계정 이름 변경을 변경중 입니다.';
      case StakingType.bridge:
        return '스왑을 요청중 입니다.';
    }
    return '전송 요청중 입니다.';
  }

  SimpleCheckDialog getDialog(
      {required BuildContext context,
      required Stakes stakes,
      required StakingType stakingType}) {

    final lang = AppLocalization.of(context)!.locale.languageCode;
    String amount = stakes.power ?? '0';
    amount = getFormattedText(value: double.parse(amount));

    switch (stakingType) {
      case StakingType.staking:
        return SimpleCheckDialog(
          infoString: lang == 'ko' ?
          '$amount개의 RIGO 코인의 스테이킹이 완료되었습니다' :
          '$amount RIGO coins staking has been completed.',
        );
      case StakingType.unStaking:
        return SimpleCheckDialog(
          hasTitle: true,
          titleString: lang == 'ko' ?
            '$amount개의 RIGO 코인의 스테이킹이 종료되었습니다' :
            '$amount RIGO coins staking has ended.',
          infoString: TR(context, '락업 종료일 이후에\n자동으로 입금됩니다.'),
        );
      case StakingType.delegate:
        String shortTo = getShortAddressText(stakes.to!, 6);
        return SimpleCheckDialog(
          infoString: lang == 'ko' ?
            '$shortTo 검증인에게\n $amount개의 RIGO 코인을 위임하였습니다.' :
            '$amount RIGO coins\nhave been delegated to\nthe $shortTo validator.',
        );
      case StakingType.unDelegate:
        return SimpleCheckDialog(
          hasTitle: true,
          titleString: lang == 'ko' ?
            '$amount개의 RIGO 코인의 위임이 종료되었습니다.' :
            '$amount RIGO coins delegation has ended.',
          infoString: TR(context, '락업 종료일 이후에\n자동으로 입금됩니다.'),
        );
      case StakingType.setDoc:
        return SimpleCheckDialog(
          infoString: lang == 'ko' ?
          '계정 이름 변경이 완료되었습니다.' :
          'Your account name change has been completed.',
        );
      case StakingType.bridge:
        return SimpleCheckDialog(
          infoString: lang == 'ko' ?
          '스왑이 요청되었습니다.' :
          'Swap has been requested.',
        );
      default:
        return SimpleCheckDialog(
          infoString: lang == 'ko' ?
            '$amount개의 RIGO 코인의 전송 요청이 완료되었습니다' :
            'The request to transfer $amount RIGO coins has been completed',
        );
    }
  }

  void _inputPin(BuildContext context, String pinNum) async {
    if (isSending) return;
    NetworkModel networkModel =
        provider.Provider.of<NetworkProvider>(context, listen: false)
            .networkModel;

    setState(() {
      inputPin += pinNum;
    });

    if (inputPin.length >= 6) {
      var utf8List = utf8.encode(inputPin);
      var shaConvert = sha256.convert(utf8List);

      StakingType stakingType =
          provider.Provider.of<StakesData>(context, listen: false).stakingType;
      Stakes stakes =
          provider.Provider.of<StakesData>(context, listen: false).stakes;

      final currentCoin =
          await ref.read(coinProvider).currentCoin;

      // showLoadingDialog(context, TR(context, getLoadingText(stakingType)));
      var address = await UserHelper().get_address();

      // if (networkModel.isRigo && stakingType != StakingType.bridge) {
      if (networkModel.isRigo) {
        // RIGO transactions..
        GovernanceRule governanceRule =
        await JsonRpcService().getGovernanceRule(networkModel);
        var account = await ref
            .read(jsonRpcServiceProvider)
            .getAccountInfo(networkModel, '0x' + address);

        TrxProto trx = TrxProto();

        switch (stakingType) {
          case StakingType.staking:
          case StakingType.delegate:
            trx = await trxHelper.BuildTransferTrx(
                account: account,
                type: TransactionType.TRX_STAKING,
                toAddress: stakes.to!,
                gasPrice: governanceRule.gasPrice!,
                minTrxFee: governanceRule.minTrxGas ?? '0',
                amount: stakes.power!);
            break;
          case StakingType.unStaking:
          case StakingType.unDelegate:
            trx = await trxHelper.BuildTransferTrx(
                account: account,
                type: TransactionType.TRX_UNSTAKING,
                toAddress: stakes.to!,
                gasPrice: governanceRule.gasPrice!,
                minTrxFee: governanceRule.minTrxGas ?? '0',
                payload: stakes.txhash!);
            break;
          case StakingType.contract:
            if (currentCoin == null) return;
            var sendBigAmount = getSendAmount(sendAmount, currentCoin.decimalNum);
            var contractAddress = currentCoin.contract!.substring(2,
                currentCoin.contract!.length);
            trx = await trxHelper.BuildContractTrx(
                account: account,
                toAddress: contractAddress,
                gasPrice: '250000000000',
                minTrxFee: '1000000',
                arg: [
                  EthereumAddress.fromHex(receivedAddress),
                  sendBigAmount,
                ]);
            break;
          case StakingType.setDoc:
            trx = await trxHelper.BuildSetDocTrx(
              account: account,
              type: TransactionType.TRX_SETDOC,
              gasPrice: governanceRule.gasPrice!,
              minTrxFee: governanceRule.minTrxGas ?? '0',
              payload: rlpEncodeList([
                stakes.payloadName ?? '',
                stakes.payloadUrl  ?? ''
              ])
            );
            break;
          case StakingType.bridge:
            if (currentCoin == null) return;
            sendAmount = STR(stakes.power);
            receivedAddress = STR(stakes.to);
            var contractAddress = '18dee342247fe60eed10d37d9f45e1442214094a';
            // var contractAddress = STR(currentCoin.contract);
            // if (contractAddress.substring(0, 2) == '0x') {
            //   contractAddress = contractAddress.substring(2, contractAddress.length);
            // }
            final wrigoAddr = await BridgeService().getWRIGO();
            if (wrigoAddr == null) return;
            final matchingInfo = await BridgeService().getChaincodeMatchingInfo(
                STR(stakes.toChainId), STR(stakes.toTokenAddress));
            if (matchingInfo == null) return;
            final tokenAddr    = STR(matchingInfo['addr']);
            final wrigoAddress = EthereumAddress.fromHex(wrigoAddr);
            final tokenAddress = EthereumAddress.fromHex(tokenAddr);
            final userAddress  = EthereumAddress.fromHex(receivedAddress);
            trx = await trxHelper.BuildBridgeTrx(
                account: account,
                toAddress: contractAddress,
                gasPrice: '250000000000',
                minTrxFee: '1000000',
                amount: sendAmount,
                arg: [
                  BigInt.zero,
                  ['rigo', 'rigo'],
                  [wrigoAddress, tokenAddress],
                  userAddress,
                  BigInt.zero
                ]);
            break;
          default:
            trx = await trxHelper.BuildTransferTrx(
                account: account,
                type: TransactionType.TRX_TRANSFER,
                toAddress: receivedAddress,
                gasPrice: governanceRule.gasPrice!,
                minTrxFee: governanceRule.minTrxGas ?? '0',
                amount: sendAmount);
        }

        print('-----------------------------------------------------');
        print(trx);
        print(networkModel.chainId);
        print(shaConvert.toString());
        print(account.address);
        print('-----------------------------------------------------');

        Uint8List sign = await trxHelper.SignTrx3(
            message: networkModel.chainId,
            pin: shaConvert.toString(),
            trxProto: trx,
            isRlpEncode: stakingType != StakingType.setDoc,
          );

          if (sign.length != 0 && currentCoin != null) {
            var signedTrx = trxHelper.BuildSignedTrx(stakingType, trx, sign,
                toAddress: receivedAddress,
                amount: sendAmount,
                tokenName: currentCoin.symbol,
                decimal: currentCoin.decimal,
                name: stakes.payloadName,
                url: stakes.payloadUrl
            );

            print('=====================================================');
            print(signedTrx);
            print('=====================================================');

            var broadcastTxResultCode = await ref
                .read(jsonRpcServiceProvider)
                .broadcast_tx_commit(
                networkModel, base64Encode(signedTrx.writeToBuffer()));
            LOG('---> resultJsonSuccess : [$stakingType] -> '
                '${broadcastTxResultCode.jsonResult}');

            hideLoadingDialog();
            if (broadcastTxResultCode.checkTx == 0 &&
                broadcastTxResultCode.deliverTx == 0) {
              if (stakingType == StakingType.contract ||
                  stakingType == StakingType.transfer) {
                context.goNamed(SendCompletedScreen.routeName,
                    queryParams: {
                      'sendAmount': sendAmount,
                      'symbol': currentCoin.symbol
                    });
              } else {
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return getDialog(
                        context: context,
                        stakes: stakes,
                        stakingType: stakingType);
                  },
                );
                if (stakingType == StakingType.setDoc) {
                  Navigator.of(context).pop(true);
                } else {
                  provider.Provider.of<NavigationProvider>(
                    context, listen: false).navigateBack();
                  context.goNamed(MainScreen.routeName, queryParams: {
                    'selectedPage': '0',
                  });
                }
              }
            } else {
              //실패
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleCheckDialog(
                    hasTitle: true,
                    titleString: TR(context, '전송이 실패했습니다.'),
                    infoString: TR(context, '다시 시도해주세요.'),
                  );
                },
              );
            }
          } else {
            hideLoadingDialog();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return WrongPasswordDialog();
              },
            );
            setState(() {
              inputPin = '';
              pin.shuffle();
            });
          }
        Future.delayed(Duration(microseconds: 500)).then((_) {
          setState(() {
            isSending = false;
          });
        });
      } else {
        final privateKey = await getPrivateKey();
        var transferResult = false;
        JSON resultJson = {};
        if (stakingType == StakingType.bridge) {
          if (stakes.to!.substring(0, 2) == '0x') {
            stakes.to = stakes.to!.substring(2, stakes.to!.length);
          }
          LOG('---> networkModel.isRigo : ${currentCoin?.toJson()}');
          if (networkModel.isRigo) {
            // var contractAddress = currentCoin!.contract!.substring(2,
            //     currentCoin.contract!.length);
            transferResult = await BridgeService().runVmCall(
              networkModel,
              STR(stakes.toChainId),
              STR(stakes.toTokenAddress),
              STR(currentCoin?.contract),
              STR(stakes.to),
              getSendAmount(STR(stakes.power)).toString()
            );
          } else {
            transferResult = await MdlRpcService().burn(
              privateKey,
              networkModel,
              currentCoin!,
              STR(stakes.toChainId),
              STR(stakes.toTokenAddress),
              STR(stakes.to),
              getSendAmount(STR(stakes.power)).toString(),
            );
          }
          resultJson['sendAmount'] = STR(stakes.power);
          resultJson['symbol'] = STR(currentCoin!.symbol);
        } else {
          // MDL transactions..
          if (receivedAddress.substring(0, 2) == '0x') {
            receivedAddress =
                receivedAddress.substring(2, receivedAddress.length);
          }
          transferResult = await MdlRpcService().transfer(
            networkModel,
            currentCoin!,
            privateKey,
            receivedAddress,
            getSendAmount(sendAmount).toString(),
          );
          resultJson['sendAmount'] = sendAmount;
        }
        hideLoadingDialog();
        LOG('---> transferResult : $transferResult');
        if (transferResult) {
          context.goNamed(SendCompletedScreen.routeName,
              queryParams: resultJson);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SimpleCheckDialog(
                hasTitle: true,
                titleString: '전송이 실패했습니다.',
                infoString: '다시 시도해주세요.',
              );
            },
          );
        }
      }
      // setState(() {
      //   inputPin = ''; // 연속 입력시 오류 발생 > 결과 체크후 초기화
      //   isSending = true; // 연속 전송 방지
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHITE,
      appBar: AppBar(
        backgroundColor: WHITE,
        leading: CustomBackButton(
          onPressed: context.pop,
        ),
        centerTitle: true,
        title: Text(
          TR(context, '본인확인'),
          style: typo18semibold,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),
                    Padding(
                      padding: EdgeInsets.only(left: 20.r, right: 20.r),
                      child: Text(
                        TR(context, '비밀번호를 입력해주세요'),
                        style: typo24bold150,
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.only(left: 20.r, right: 20.r),
                      child: Text(
                        TR(context, '사용중인 비밀번호를 입력합니다.'),
                        style: typo16medium.copyWith(color: GRAY_70),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    PinBox(pinLength: inputPin.length),
                    Spacer(),
                    NumPad(
                      initialPin: pin,
                      delete: _deletePress,
                      refresh: _refreshPress,
                      hasAuth: false,
                      isEnable: !isSending,
                      onChanged: ((pinNum) => _inputPin(context, pinNum)),
                    ),
                    SizedBox(height: 40.h)
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
