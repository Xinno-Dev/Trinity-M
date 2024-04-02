class StorageModel {
  int? code;
  String? msg;
  String? data;

  StorageModel({this.code, this.msg, this.data});

  StorageModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    msg = json['Msg'];
    data = json['Data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['Msg'] = this.msg;
    data['Data'] = this.data;
    return data;
  }
}
