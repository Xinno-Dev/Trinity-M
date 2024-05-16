import '../../common/common_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../common/const/constants.dart';
import '../../common/const/utils/convertHelper.dart';
import '../../common/provider/network_provider.dart';

part 'coin_model.g.dart';

@JsonSerializable(
  includeIfNull: false
)
class CoinModel {
  String  symbol;   // A ticker symbol or shorthand, up to 5 chars.
  String  name;     // token name
  String  mainNetChainId; // added network
  String  walletAddress;  // added wallet
  String? contract;   // The address that the token is at.
  String? decimal;    // The number of decimals in the token
  String? channel;
  String? chainCode;
  String? balance;
  String? logo;
  String? logo_flat;
  String? logo_hash;
  String? color;
  bool?   hideToken;
  int?    networkType; // 0: rigo, 1: mdl
  DateTime? balanceUpdateTime;

  CoinModel({
    required this.symbol,
    required this.name,
    required this.mainNetChainId,
    required this.walletAddress,
    this.contract,
    this.channel,
    this.chainCode,
    this.decimal,
    this.balance,
    this.logo,
    this.logo_flat,
    this.logo_hash,
    this.color,
    this.hideToken,
    this.networkType,
    this.balanceUpdateTime,
  });

  get code {
    return symbol + mainNetChainId + walletAddress;
  }

  get isRigo {
    return INT(networkType) == 0;
  }

  get isRigoCoin {
    return isRigo && symbol.toLowerCase() == 'rigo';
  }

  get isMDL {
    return INT(networkType) == 1;
  }

  get isMDLCoin {
    return !isRigoCoin;
  }

  get isHide {
    return hideToken ?? false;
  }

  get isToken {
    return symbol.toLowerCase() != 'rigo' && symbol.toLowerCase() != 'mdl';
  }

  int get decimalNum {
    return int.parse(decimal ?? DECIMAL_PLACES.toString());
  }

  get decimalEmptyStr {
    return '0' * decimalNum;
  }

  get formattedBalance {
    balance ??= '0.0';
    // if (balance!.contains('.')) {
    //   var zeroCount = balance!.length - balance!.indexOf('.') - 1;
    //   if (zeroCount < 8) {
    //     for (var i=0; i<8 - zeroCount; i++) {
    //       balance = '${balance}0';
    //     }
    //   }
    // }
    return balance;
  }

  double get fontSize {
    if (balance == null) return 24;
    return balance!.length > 24 ? 22 : balance!.length > 18 ? 22 : 24;
  }

  static CoinModel newCoin([contract]) {
    return CoinModel(
      symbol: '',
      name: '',
      mainNetChainId: '',
      walletAddress: '',
      contract: contract,
      networkType: 0,
    );
  }

  static CoinModel newMDLCoin([chainCode, channel]) {
    return CoinModel(
      symbol: '',
      name: '',
      mainNetChainId: '',
      chainCode: chainCode,
      walletAddress: '',
      channel: channel,
      networkType: 1,
    );
  }

  factory CoinModel.fromJson(JSON json) => _$CoinModelFromJson(json);
  JSON toJson() => _$CoinModelToJson(this);
}
