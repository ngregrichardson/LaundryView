class Alarm {
  String appliance_desc_key;
  DateTime end_time;

  Alarm(this.appliance_desc_key, this.end_time);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['appliance_desc_key'] = appliance_desc_key;
    map['end_time'] = end_time.toString();
    return map;
  }

  Alarm.fromMapObject(Map<String, dynamic> map) {
    this.appliance_desc_key = map['appliance_desc_key'];
    this.end_time = DateTime.parse(map['end_time']);
  }
}
