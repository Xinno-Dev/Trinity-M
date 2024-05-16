import '../../common/const/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../common/const/utils/convertHelper.dart';

part 'network_model.g.dart';

@JsonSerializable(
  includeIfNull: false
)
class NetworkModel {
  int     index;
  String  name;
  String  url;
  String  httpUrl;
  String  chainId;
  String? id;       // unique id..
  String? channel;
  String? symbol;
  String? exploreUrl;
  int?    networkType;  // 0:rigo  1:mdl..

  // from MDL RPC server..
  List?   chainList;  // 서버 선택 목록..
  String? nameOrg;    // 서버에서 보내준 이름..

  NetworkModel({
    required this.index,
    required this.name,
    required this.url,
    required this.httpUrl,
    required this.chainId,
    this.id,
    this.channel,
    this.symbol,
    this.exploreUrl,
    this.networkType,

    this.chainList,
    this.nameOrg,
  });

  static create({
    int    index = 0,
    String url = '',
    String httpUrl = '',
    String name = '',
    String chainId = '',
    String id = '',
    String channel = '',
    String symbol = '',
    String exploreUrl = '',
    int    networkType = 0,
  }) {
    return NetworkModel(
      index:    index,
      name:     name,
      url:      url,
      httpUrl:  httpUrl,
      chainId:  chainId,
      id:       id,
      channel:  channel,
      symbol:   symbol,
      exploreUrl: exploreUrl,
      networkType: networkType
    );
  }

  get isRigo {
    if (symbol == 'mdl') return false;
    return INT(networkType) == 0 || chainId == MAIN_NET_CHAIN_ID || chainId == TEST_NET_CHAIN_ID;
  }

  get isValidated {
    return name.isNotEmpty && (url.isNotEmpty || httpUrl.isNotEmpty) && chainId.isNotEmpty;
  }

  get currencySymbol {
    return symbol ?? '';
  }

  get createUrlFromHttps {
    return httpUrl.replaceAll('https:', 'wss:') + '/websocket';
  }

  getIconImage([double? size]) {
    var iconSize = size ?? 40.0;
    if (isRigo) {
      return SvgPicture.asset('assets/svg/logo_rigo.svg',
          width: iconSize, height: iconSize);
    }
    return Image.asset('assets/images/icon_mdl.png',
        width: iconSize, height: iconSize);
  }

  factory NetworkModel.fromJson(JSON json) => _$NetworkModelFromJson(json);
  JSON toJson() => _$NetworkModelToJson(this);
}