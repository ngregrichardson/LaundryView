class Machine {
  String appliance_desc_key;
  String appliance_desc;
  String type;
  String status;
  int avg_run_time;
  int time_remaining;

  Machine(Map<String, dynamic> data) {
    appliance_desc_key = data["appliance_desc_key"];
    appliance_desc = data["appliance_desc"];
    type = data["appliance_type"];
    status = data["time_left_lite"];
    avg_run_time = data["average_run_time"];
    time_remaining = data["time_remaining"];
  }
}
