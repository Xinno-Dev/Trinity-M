class RWF {
  String? version;
  String? address;
  String? origin;
  String? algo;
  Cp? cp;
  Dkp? dkp;

  RWF({this.version, this.address, this.origin, this.algo, this.cp, this.dkp});

  RWF.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    address = json['address'];
    origin = json['origin'];
    algo = json['algo'];
    cp = json['cp'] != null ? new Cp.fromJson(json['cp']) : null;
    dkp = json['dkp'] != null ? new Dkp.fromJson(json['dkp']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = this.version;
    data['address'] = this.address;
    data['origin'] = this.origin;
    data['algo'] = this.algo;
    if (this.cp != null) {
      data['cp'] = this.cp!.toJson();
    }
    if (this.dkp != null) {
      data['dkp'] = this.dkp!.toJson();
    }
    return data;
  }
}

class Cp {
  String? ca;
  String? ct;
  String? ci;

  Cp({this.ca, this.ct, this.ci});

  Cp.fromJson(Map<String, dynamic> json) {
    ca = json['ca'];
    ct = json['ct'];
    ci = json['ci'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ca'] = this.ca;
    data['ct'] = this.ct;
    data['ci'] = this.ci;
    return data;
  }
}

class Dkp {
  String? ka;
  String? kh;
  String? kc;
  String? ks;
  String? kl;

  Dkp({this.ka, this.kh, this.kc, this.ks, this.kl});

  Dkp.fromJson(Map<String, dynamic> json) {
    ka = json['ka'];
    kh = json['kh'];
    kc = json['kc'];
    ks = json['ks'];
    kl = json['kl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ka'] = this.ka;
    data['kh'] = this.kh;
    data['kc'] = this.kc;
    data['ks'] = this.ks;
    data['kl'] = this.kl;
    return data;
  }
}

final randomCont = 60000;