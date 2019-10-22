class Location {
  String school_desc_key;
  String school_name;

  Location(Map<String, dynamic> data) {
    school_desc_key = data['school_desc_key'];
    school_name = data['school_name'];
  }
}
