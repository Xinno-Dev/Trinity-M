class ValidatorList {
  String? validators;
  String? amount;
  String? rewardAmount;
  int?    index;

  ValidatorList({this.validators, this.amount, this.rewardAmount});

  ValidatorList.fromJson(Map<String, dynamic> json) {
    validators = json['validators'];
    amount = json['amount'];
    rewardAmount = json['rewardAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['validators'] = this.validators;
    data['amount'] = this.amount;
    data['rewardAmount'] = this.rewardAmount;
    return data;
  }
}

class Response_Validator {
  String? blockHeight;
  List<Validators>? validators;
  String? count;
  String? total;

  Response_Validator(
      {this.blockHeight, this.validators, this.count, this.total});

  Response_Validator.fromJson(Map<String, dynamic> json) {
    blockHeight = json['block_height'];
    if (json['validators'] != null) {
      validators = <Validators>[];
      json['validators'].forEach((v) {
        validators!.add(new Validators.fromJson(v));
      });
    }
    count = json['count'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['block_height'] = this.blockHeight;
    if (this.validators != null) {
      data['validators'] = this.validators!.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    data['total'] = this.total;
    return data;
  }
}

class Validators {
  String? address;
  PubKey? pubKey;
  String? votingPower;
  String? proposerPriority;

  Validators(
      {this.address, this.pubKey, this.votingPower, this.proposerPriority});

  Validators.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    pubKey =
        json['pub_key'] != null ? new PubKey.fromJson(json['pub_key']) : null;
    votingPower = json['voting_power'];
    proposerPriority = json['proposer_priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    if (this.pubKey != null) {
      data['pub_key'] = this.pubKey!.toJson();
    }
    data['voting_power'] = this.votingPower;
    data['proposer_priority'] = this.proposerPriority;
    return data;
  }
}

class PubKey {
  String? type;
  String? value;

  PubKey({this.type, this.value});

  PubKey.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    return data;
  }
}
