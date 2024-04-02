import 'dart:convert';
import 'dart:developer';

import 'package:larba_00/common/common_package.dart';
import 'package:larba_00/common/const/constants.dart';
import 'package:larba_00/common/const/utils/userHelper.dart';
import 'package:larba_00/domain/model/network_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../const/utils/convertHelper.dart';

// final networkProvider = ChangeNotifierProvider<NetworkProvider>((_) {
//   return NetworkProvider();
// });

class NetworkProvider extends ChangeNotifier {
  NetworkProvider() {
    UserHelper().get_networkList().then((networkListStr) {
      log('---> local networkList : $networkListStr');
      if (networkListStr.isNotEmpty && networkListStr != 'NOT_NETWORK_LIST') {
        var networkListJson = jsonDecode(networkListStr);
        networkList.clear(); // reset..
        for (var i=0; i<networkListJson.length; i++) {
          var item = networkListJson[i];
          LOG('---> local networkList item add [$i]: $item');
          var networkModel = NetworkModel.fromJson(item);
          if (networkModel.httpUrl.contains('3.38.199.57')) {
            networkModel.httpUrl = 'http://52.78.111.39:3001';
          }
          networkList.add(networkModel);
        }
      }
      UserHelper().get_selectedMainNetId().then((id) {
        LOG('---> local chainId : $id');
        var result = setNetworkFromId(id);
        if (result != null) {
          return;
        }
        // set default..
        LOG('---> local setMainnet');
        setMainnet();
        return;
      });
    });
  }

  late NetworkModel _networkModel = staticNetworkList[0];

  NetworkModel get networkModel {
    return _networkModel;
  }

  // 네트워크 이름 중복 체크..
  checkNetworkName(String name) {
    for (var item in networkList) {
      if (item.name.toLowerCase() == name.toLowerCase()) return false;
    }
    return true;
  }

  // 네트워크 중복 체크..
  checkNetwork(NetworkModel network) {
    for (var item in networkList) {
      if (item.chainId == network.chainId && (network.isRigo ||
          item.channel == network.channel)) return false;
    }
    return true;
  }

  List<NetworkModel> staticNetworkList = [
    NetworkModel(
        index: 1,
        name: 'RIGO Mainnet',
        url: MAIN_NET_URI,
        httpUrl: MAIN_HTTP_URL,
        chainId: MAIN_NET_CHAIN_ID
    ),
    NetworkModel(
        index: 2,
        name: 'RIGO Testnet',
        url: TEST_NET_URI,
        httpUrl: TEST_HTTP_URL,
        chainId: TEST_NET_CHAIN_ID
    )
  ];

  late List<NetworkModel> networkList = [
    ...staticNetworkList
  ];

  get networkListJson {
    final result = [];
    for (var item in networkList) {
      result.add(item.toJson());
    }
    return jsonEncode(result);
  }

  updateNetwork(NetworkModel networkModel) {
    _networkModel = networkModel;
    print('------------------ updateNetwork ------------------');
    print('- index   : ${_networkModel.index}');
    print('- name    : ${_networkModel.name}');
    print('- url     : ${_networkModel.url}');
    print('- http    : ${_networkModel.httpUrl}');
    print('- chainId : ${_networkModel.chainId}');
    print('---------------------------------------------------');
    notifyListeners();
  }

  void setMainnet() {
    updateNetwork(staticNetworkList[0]);
  }

  void setTestnet() {
    updateNetwork(staticNetworkList[1]);
  }

  NetworkModel? setNetworkFromId(String? id) {
    if (id == null || id.isEmpty || id == 'NOT_SELECTED_MAIN') return null;
    for (var item in networkList) {
      if (item.id != null && item.id == id) {
        UserHelper().setUser(selectedMainNetId: item.id!);
        updateNetwork(item);
        return item;
      }
    }
    for (var item in networkList) {
      // LOG('---> setNetworkFromId : ${item.chainId} / $id');
      if (item.chainId.isNotEmpty && item.chainId == id) {
        UserHelper().setUser(selectedMainNetId: item.chainId);
        updateNetwork(item);
        return item;
      }
    }
    return null;
  }

  NetworkModel? getNetwork(String chainId) {
    for (var item in networkList) {
      if (item.chainId == chainId) {
        return item;
      }
    }
    return null;
  }

  bool addNewNetwork(NetworkModel newNetwork) {
    LOG('---> addNewNetwork : [${newNetwork.toJson()}]');
    var isAdd = true;
    for (var item in networkList) {
      if (item.id == newNetwork.id) {
        newNetwork.index = item.index;
        networkList[networkList.indexOf(item)] =
          NetworkModel.fromJson(newNetwork.toJson());
        isAdd = false;
        break;
      }
    }
    if (isAdd) {
      newNetwork.index = networkList.length + 1;
      networkList.add(newNetwork);
    }
    LOG('--> write networkListJson [$isAdd] : $networkListJson');
    UserHelper().setUser(networkList: networkListJson);
    var result = setNetworkFromId(newNetwork.id);
    return result != null;
  }

  bool setNetwork(NetworkModel networkModel) {
    LOG('---> setNetwork : ${networkModel.toJson()}');
    for (var item in networkList) {
      LOG('---> check : ${item.chainId} / ${networkModel.chainId}');
      if (item.chainId == networkModel.chainId) {
        networkList[networkList.indexOf(item)] =
            NetworkModel.fromJson(networkModel.toJson());
        UserHelper().setUser(networkList: networkListJson);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  bool removeNetwork(NetworkModel networkModel) {
    LOG('---> removeNetwork : ${networkModel.toJson()}');
    for (var item in networkList) {
      LOG('---> check : ${item.chainId} / ${networkModel.chainId}');
      if (item.chainId == networkModel.chainId) {
        networkList.removeAt(networkList.indexOf(item));
        UserHelper().setUser(networkList: networkListJson);
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}
