class Profile {
  String? email;
  String? name;
  String? mobile;
  String? apikey;
  int? status;
  String? createdAt;
  String? lastName;
  String? fatherName;
  String? birthDate;
  String? bcity;
  String? bstate;
  String? nationalCode;
  String? notifToken;

  Profile(
      {this.name,
      this.email,
      this.mobile,
      this.apikey,
      this.status,
      this.createdAt,
      this.lastName,
      this.fatherName,
      this.birthDate,
      this.bcity,
      this.bstate,
      this.nationalCode,
      this.notifToken});

  Profile.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    apikey = json['apikey'];
    status = json['status'];
    createdAt = json['created_at'];
    lastName = json['lastName'];
    fatherName = json['fatherName'];
    birthDate = json['birthDate'];
    bcity = json['bcity'];
    bstate = json['bstate'];
    nationalCode = json['national_code'];
    notifToken = json['notif_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['apikey'] = this.apikey;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['lastName'] = this.lastName;
    data['fatherName'] = this.fatherName;
    data['birthDate'] = this.birthDate;
    data['bcity'] = this.bcity;
    data['bstate'] = this.bstate;
    data['national_code'] = this.nationalCode;
    data['notif_token'] = this.notifToken;
    return data;
  }
}