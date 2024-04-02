class HistoryModel {
  int? code;
  String? msg;
  Data? data;

  HistoryModel({this.code, this.msg, this.data});

  HistoryModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    msg = json['Msg'];
    data = json['Data'] != null ? new Data.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['Msg'] = this.msg;
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? length;
  List<History>? history;

  Data({this.length, this.history});

  Data.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    if (json['history'] != null) {
      history = <History>[];
      json['history'].forEach((v) {
        history!.add(new History.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['length'] = this.length;
    if (this.history != null) {
      data['history'] = this.history!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class History {
  String? sId;
  String? uid;
  String? time;
  String? service;
  bool? result;
  int? iV;

  History({this.sId, this.uid, this.time, this.service, this.result, this.iV});

  History.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    uid = json['uid'];
    time = json['time'];
    service = json['service'];
    result = json['result'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['uid'] = this.uid;
    data['time'] = this.time;
    data['service'] = this.service;
    data['result'] = this.result;
    data['__v'] = this.iV;
    return data;
  }
}
