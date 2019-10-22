class Room {
  String school_desc_key;
  String school_name;
  String laundry_room_location;
  String laundry_room_name;

  Room(Map<String, dynamic> data) {
    school_desc_key = data['school_desc_key'];
    school_name = data['school_name'];
    laundry_room_location = data['laundry_room_location'];
    laundry_room_name = data['laundry_room_name'];
  }
}
