class Favorite {
  String school_desc_key;
  String laundry_room_location;
  String laundry_room_name;

  Favorite(
      this.school_desc_key, this.laundry_room_location, this.laundry_room_name);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['school_desc_key'] = school_desc_key;
    map['laundry_room_location'] = laundry_room_location;
    map['laundry_room_name'] = laundry_room_name;
    return map;
  }

  Favorite.fromMapObject(Map<String, dynamic> map) {
    this.school_desc_key = map['school_desc_key'];
    this.laundry_room_location = map['laundry_room_location'];
    this.laundry_room_name = map['laundry_room_name'];
  }
}
