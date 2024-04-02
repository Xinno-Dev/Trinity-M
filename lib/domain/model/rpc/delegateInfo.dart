class DelegateInfo {
  String? address;
  String? pubKey;
  String? selfPower;
  String? totalPower;
  String? slashedPower;

  List<Stakes>? stakes;

  DelegateInfo(
      {this.address,
      this.pubKey,
      this.selfPower,
      this.totalPower,
      this.slashedPower,
      this.stakes});

  DelegateInfo.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    pubKey = json['pubKey'];
    selfPower = json['selfPower'];
    totalPower = json['totalPower'];
    slashedPower = json['slashedPower'];
    if (json['stakes'] != null) {
      stakes = <Stakes>[];
      json['stakes'].forEach((v) {
        stakes!.add(new Stakes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['pubKey'] = this.pubKey;
    data['selfPower'] = this.selfPower;
    data['totalPower'] = this.totalPower;
    data['slashedPower'] = this.slashedPower;
    if (this.stakes != null) {
      data['stakes'] = this.stakes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Stakes {
  String? owner;
  String? to;
  String? power;
  String? txhash;
  String? startHeight;
  String? refundHeight;
  String? payloadName;
  String? payloadUrl;
  int?    index;

  // String? httpUrl;
  // String? channel;
  // String? chaincode;
  // String? fromChainId;
  // String? fromTokenAddress;
  // String? fromSymbol;
  String? toChainId;
  String? toTokenAddress;
  String? toSymbol;

  Stakes(
      {this.owner,
      this.to,
      this.power,
      this.txhash,
      this.startHeight,
      this.refundHeight,
      this.payloadName,
      this.payloadUrl,
      this.index,

      // this.httpUrl,
      // this.channel,
      // this.chaincode,
      // this.fromChainId,
      // this.fromTokenAddress,
      // this.fromSymbol,
      this.toChainId,
      this.toTokenAddress,
      this.toSymbol,
    });

  Stakes.fromJson(Map<String, dynamic> json) {
    owner = json['owner'];
    to = json['to'];
    power = json['power'];
    txhash = json['txhash'];
    startHeight = json['startHeight'];
    refundHeight = json['refundHeight'];
    payloadName = json['payloadName'];
    payloadUrl = json['payloadUrl'];
    index = json['index'];
    // httpUrl = json['httpUrl'];
    // channel = json['channel'];
    // chaincode = json['chaincode'];
    // fromChainId = json['fromChainId'];
    // fromTokenAddress = json['fromTokenAddress'];
    // fromSymbol = json['fromSymbol'];
    toChainId = json['toChainId'];
    toTokenAddress = json['toTokenAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['owner'] = this.owner;
    data['to'] = this.to;
    data['power'] = this.power;
    data['txhash'] = this.txhash;
    data['startHeight'] = this.startHeight;
    data['refundHeight'] = this.refundHeight;
    data['payloadName'] = this.payloadName;
    data['payloadUrl'] = this.payloadUrl;
    data['index'] = this.index;
    // data['httpUrl'] = this.httpUrl;
    // data['channel'] = this.channel;
    // data['chaincode'] = this.chaincode;
    // data['fromChainId'] = this.fromChainId;
    // data['fromTokenAddress'] = this.fromTokenAddress;
    // data['fromSymbol'] = this.fromSymbol;
    data['toChainId'] = this.toChainId;
    data['toTokenAddress'] = this.toTokenAddress;
    return data;
  }
}

class StakesAndReward {
  Stakes stakes;
  String? reward;
  int?   index;
  String ratio;

  StakesAndReward(
      this.stakes,
      this.ratio,
      {
        this.reward,
      });
}