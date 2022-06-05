class Mechanism{

  int mechanism_id;
  String user_phone;
  int lock_status;
  int auto_lock;

  Mechanism(this.mechanism_id, this.user_phone, this.lock_status, this.auto_lock);

  Mechanism.fromJson(Map<String, dynamic> json)
      : mechanism_id = json['mechanism_id'] as int,
        user_phone = json['user_phone'] as String,
        lock_status = json['lock_status'] as int,
        auto_lock = json['auto_lock'] as int;

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['mechanism_id'] = this.mechanism_id;
    data['user_phone'] = this.user_phone;
    data['lock_status'] = this.lock_status;
    data['auto_lock'] = this.auto_lock;

    return data;
  }

}
