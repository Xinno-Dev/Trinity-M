
import 'dart:ffi';

class Reward {
  String? address;
  String? issued;
  String? withdrawn;
  String? slashed;
  String? cumulated;
  String? height;

  Reward(
      { this.address,
        this.issued,
        this.withdrawn,
        this.slashed,
        this.cumulated,
        this.height
      });

  Reward.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    issued = json['issued'];
    withdrawn = json['withdrawn'];
    slashed = json['slashed'];
    cumulated = json['cumulated'];
    height = json['height'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['issued'] = this.issued;
    data['withdrawn'] = this.withdrawn;
    data['slashed'] = this.slashed;
    data['cumulated'] = this.cumulated;
    data['height'] = this.height;
    return data;
  }
}
