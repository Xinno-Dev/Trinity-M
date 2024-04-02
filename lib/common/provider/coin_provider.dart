import 'dart:convert';

import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/provider/network_provider.dart';
import 'package:larba_00/domain/model/coin_model.dart';
import 'package:larba_00/domain/model/network_model.dart';
import 'package:larba_00/services/mdl_rpc_service.dart';
import 'package:http/http.dart';

import '../../domain/model/address_model.dart';
import '../../domain/model/rpc/account.dart';
import '../../services/json_rpc_service.dart';
import '../const/utils/convertHelper.dart';
import '../const/utils/userHelper.dart';
import '../trxHelper.dart';

final coinProvider = ChangeNotifierProvider<CoinProvider>((_) {
  return CoinProvider();
});

class CoinProvider extends ChangeNotifier {

  String? _selectCoinCode;
  String networkChainId = '';
  String walletAddress  = '';

  Map<String, CoinModel> coinMap = {};

  get coinList {
    return coinMap.entries.map((e) => e.value).toList();
  }

  getNetworkCoinList(bool isRigo) {
    List<CoinModel> result = [];
    for (var coin in coinList) {
      if (coin.isRigo) {
        result.add(coin);
      }
    }
    return result;
  }

  refreshView() {
    notifyListeners();
  }

  CoinModel? get currentCoin {
    // LOG('---> currentCoin : ${_selectCoinCode}');
    // 코인 리스트가 없을 경우 (최초 실행시)
    if (coinMap.isEmpty) {
      initCoins();
    }
    // 코인 리스트에 코인이 있을 경우.. (정상적인 경우)
    if (coinMap.containsKey(_selectCoinCode)) {
      // LOG('--> coinMap : ${coinMap[_selectCoinCode]!.toJson()}');
      return coinMap[_selectCoinCode]!;
    }
    // 코인 리스트에 코인이 없을 경우.. (계정을 추가했을경우) -> 같은 네트워크의 최초 코인 반환..
    for (CoinModel item in coinList) {
      // LOG('--> check coin : ${item.mainNetChainId} / ${networkChainId}');
      if (item.mainNetChainId == networkChainId) {
        _selectCoinCode = item.code;
        UserHelper().setUser(selectedCoin: item.code);
        // LOG('-------> currentCoin select : ${_selectCoinCode}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return coinMap[_selectCoinCode]!;
      }
    }
    // 그 외.. 저장된 코인 선택정보 초기화..
    _selectCoinCode = '';
    UserHelper().setUser(selectedCoin: '');
    LOG('---> currentCoin refresh : empty');
    return null;
  }

  // 로컬 에서 코인 리스트, 마지막 선택 코인, 마지막 메인넷 정보를 가져 와서 코인 선택
  initCoins() {
    UserHelper().get_coinList().then((coinListLocal) {
      _clearCoins();
      if (coinListLocal != 'NOT_COIN_LIST') {
        final coinListJson = jsonDecode(coinListLocal);
        for (var item in coinListJson) {
          print('--> local coinListJson item : $item');
          _addCoin(CoinModel.fromJson(item));
        }
        UserHelper().get_selectedCoin().then((coinCode) {
          print('--> select coinCode : $coinCode');
          if (coinCode != 'NOT_SELECTED_COIN') {
            UserHelper().get_selectedMainNetId().then((mainNetId) {
              // print('--> select mainNetId : $mainNetId');
              if (mainNetId != 'NOT_SELECTED_MAIN') {
                if (coinMap[coinCode] != null && coinMap[coinCode]!.code == coinCode) {
                  _selectCoinCode = coinCode;
                  UserHelper().setUser(selectedCoin: coinCode).then((_) {
                    notifyListeners();
                  });
                }
              }
            });
          }
        });
      }
      // 로컬에 코인 정보가 없을 경우 디폴트 값 (최초 설치시)
      if (coinMap.isEmpty) {
        _setDefaultCoin();
      }
    });
  }

  // 기본값으로 coinMap 을 채움..
  _setDefaultCoin() {
    _clearCoins();
    for (var item in DEFAULT_COIN_LIST) {
      _addCoin(
        CoinModel(
          symbol: item[0],
          name:   item[1],
          mainNetChainId: item[2],
          decimal: item[3],
          walletAddress: '',
        )
      );
    }
    LOG('--> CoinProvider start : $coinMap');
    writeCoinList();
  }

  // 메인넷이 변경될 경우..
  setNetworkFromId(String? id) {
    LOG('--> setNetworkFromId : $networkChainId / $id');
    if (id == null || id.isEmpty) return false;
    if (networkChainId != id) {
      networkChainId = id;
      UserHelper().setUser(selectedMainNetId: id);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        refreshSelectCoin();
      });
    }
    return true;
  }

  setWalletAddress(String address) {
    LOG('--> setWalletAddress : $address');
    if (walletAddress != address) {
      walletAddress = address;
      UserHelper().setUser(address: address);
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        refreshSelectCoin();
      });
    }
  }

  // 메인넷, 계정이 변경될 경우 선택된 코인을 변경..
  refreshSelectCoin() {
    LOG('--> refreshSelectCoin : $networkChainId / $walletAddress');
    try {
      // // 메인넷 변경시, 변경된 메인넷과 연동된 코인 검색..(코인 우선)
      // for (CoinModel item in coinList) {
      //   LOG('--> refreshSelectCoin 1 check [${item.symbol}] : ${item.mainNetChainId} / ${item.walletAddress} / ${!item.isToken}');
      //   if (!item.isHide && item.mainNetChainId == networkChainId &&
      //       item.walletAddress == walletAddress && !item.isToken) {
      //     _selectCoinCode = item.code;
      //     UserHelper().setUser(selectedCoin: item.code);
      //     notifyListeners();
      //     LOG('--> refreshSelectCoin 1 : $_selectCoinCode / ${item.toJson()}');
      //     return _selectCoinCode;
      //   }
      // }
      // // 메인넷 변경시, 변경된 메인넷과 연동된 코인 검색..(토큰 우선)
      // for (CoinModel item in coinList) {
      //   LOG('--> refreshSelectCoin 2 check : ${item.walletAddress} / ${item.mainNetChainId}');
      //   if (!item.isHide && item.mainNetChainId == networkChainId &&
      //       item.walletAddress == walletAddress && item.isToken) {
      //     _selectCoinCode = item.code;
      //     UserHelper().setUser(selectedCoin: item.code);
      //     notifyListeners();
      //     LOG('--> refreshSelectCoin 2 : $_selectCoinCode / ${item.toJson()}');
      //     return _selectCoinCode;
      //   }
      // }
      // 같은 네트워크 코인 검색..
      for (CoinModel item in coinList) {
        if (!item.isHide && item.mainNetChainId == networkChainId &&
            (item.walletAddress.isEmpty || item.walletAddress == walletAddress) && !item.isToken) {
          _selectCoinCode = item.code;
          UserHelper().setUser(selectedCoin: item.code);
          notifyListeners();
          LOG('--> refreshSelectCoin 1 : $_selectCoinCode / ${item.toJson()}');
          return _selectCoinCode;
        }
      }
      // 코인이 없을경우, 같은 네트워크 토큰 검색..
      for (CoinModel item in coinList) {
        if (!item.isHide && item.mainNetChainId == networkChainId &&
            (item.walletAddress.isEmpty || item.walletAddress == walletAddress)) {
          _selectCoinCode = item.code;
          UserHelper().setUser(selectedCoin: item.code);
          notifyListeners();
          LOG('--> refreshSelectCoin 2 : $_selectCoinCode / ${item.toJson()}');
          return _selectCoinCode;
        }
      }
    } catch (e) {
      LOG('--> refreshSelectCoin error : $e');
    }
    _selectCoinCode = null;
    notifyListeners();
    return _selectCoinCode;
  }

  // 코인 선택을 변경 했을 경우..
  selectCoinModel(coinCode) {
    _selectCoinCode = coinCode;
    LOG('--> setCoinModel : $_selectCoinCode');
    if (_selectCoinCode != null) {
      UserHelper().setUser(selectedCoin: _selectCoinCode!);
      notifyListeners();
    }
  }

  // 코인을 숨기기 했을 경우..
  hideCoinModel(coinCode) {
    LOG('--> hideCoinModel : $coinCode / $_selectCoinCode');
    if (!coinMap.containsKey(coinCode)) return;
    // 선택된 코인이 숨기기 했을경우, 선택된 코인 변경..
    if (_selectCoinCode == coinCode) {
      for (CoinModel item in coinList) {
        if (item.code != coinCode &&
            item.mainNetChainId == coinMap[coinCode]!.mainNetChainId) {
          _selectCoinCode = item.code;
          LOG('----> changeCoinModel : $_selectCoinCode');
          if (_selectCoinCode != null) {
            UserHelper().setUser(selectedCoin: _selectCoinCode!);
          }
          break;
        }
      }
    }
    coinMap[coinCode]!.hideToken = !(coinMap[coinCode]!.isHide);
    writeCoinList();
    notifyListeners();
  }

  // 특정 코인정보 가져오기..
  CoinModel? getCoin(String code) {
    return coinMap[code];
  }

  setCurrentCoinCode(String? code) {
    _selectCoinCode = code;
    refreshSelectCoin();
  }

  // 코인 추가..
  _addCoin(CoinModel coinModel) {
    coinMap[coinModel.code] = coinModel;
    _selectCoinCode ??= coinModel.code;
  }

  // 코인 추가후 저장 & 공지..
  addNewCoin(CoinModel coinModel) {
    coinMap[coinModel.code] = coinModel;
    writeCoinList();
    notifyListeners();
  }

  _clearCoins() {
    coinMap.clear();
  }

  // 로컬에 코인 목록 저장..
  writeCoinList() {
    var coinListJson = [];
    for (var item in coinList) {
      coinListJson.add(item.toJson());
    }
    final coinListStr = jsonEncode(coinListJson);
    // print('--> writeCoinList : $coinListStr');
    UserHelper().setUser(coinList: coinListStr);
  }

  // 선택된 코인의 발란스 가져오기..
  Future<String> getBalance(
    NetworkModel networkModel, {CoinModel? coin}) async {
    final targetCoin = coin ?? currentCoin;
    // print('--> getBalance [${networkModel.isRigo}] : $walletAddress / ${targetCoin != null ? targetCoin.toJson() : 'null'}');
    var balance = '0';
    if (walletAddress.isEmpty) return '0.0';
    try {
      if (networkModel.isRigo) {
        if (targetCoin != null && STR(targetCoin.contract).isNotEmpty) {
          // Rigo token...
          balance = await JsonRpcService().runVmCall(networkModel,
            'balanceOf', targetCoin.contract!,fromAddr: walletAddress) ?? '0.0';
        } else {
          // Rigo coin...
          Account account = await JsonRpcService().getAccountInfo(networkModel, walletAddress);
          balance = await TrxHelper().getAmount(account.balance!, scale: DECIMAL_PLACES);
        }
      } else {
        if (targetCoin != null) {
          // MDL token..
          balance = await MdlRpcService().balanceOf(networkModel, targetCoin);
        } else {
          return '0.0';
        }
      }
    } catch (e) {
      print('---> getBalance error : $e');
    }
    // print('--> getBalance result [${networkModel.isRigo} / ${targetCoin == null}] : $balance');
    if (coinMap.isEmpty) {
      initCoins();
    }

    if (targetCoin != null) {
      if (coinMap[targetCoin.code] == null) {
        _addCoin(CoinModel(
            symbol: currentCoin!.symbol,
            name: currentCoin!.name,
            mainNetChainId: currentCoin!.mainNetChainId,
            walletAddress: walletAddress,
            decimal: currentCoin!.decimal,
            balance: balance
        ));
      }
      coinMap[targetCoin.code]!.balance = balance;
      coinMap[targetCoin.code]!.balanceUpdateTime = DateTime.now();
      writeCoinList();
    }
    return balance;
  }
}
