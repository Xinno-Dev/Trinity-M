class AuthModel {
  int? code;
  String? msg;
  Data? data;

  AuthModel({this.code, this.msg, this.data});

  AuthModel.fromJson(Map<String, dynamic> json) {
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
  bool? exist;
  String? service;
  String? aPI;
  String? uID;
  String? rN;
  num? createAt;

  Data({this.exist, this.service, this.aPI, this.uID, this.rN, this.createAt});

  Data.fromJson(Map<String, dynamic> json) {
    exist = json['Exist'];
    service = json['Service'];
    aPI = json['API'];
    uID = json['UID'];
    rN = json['RN'];
    createAt = json['CreateAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Exist'] = this.exist;
    data['Service'] = this.service;
    data['API'] = this.aPI;
    data['UID'] = this.uID;
    data['RN'] = this.rN;
    data['CreateAt'] = this.createAt;
    return data;
  }
}
