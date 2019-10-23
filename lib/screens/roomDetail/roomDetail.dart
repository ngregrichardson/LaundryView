import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../endpoint.dart';
import '../../models/machine.dart';
import '../../models/alarm.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RoomDetail extends StatefulWidget {
  final String school_desc_key;
  final String laundry_room_location;
  final String laundry_room_name;

  const RoomDetail(
      {Key key,
      this.school_desc_key,
      this.laundry_room_location,
      this.laundry_room_name})
      : super(key: key);

  @override
  RoomDetailState createState() => new RoomDetailState();
}

class RoomDetailState extends State<RoomDetail>
    with SingleTickerProviderStateMixin {
  SharedPreferences prefs;
  TabController controller;
  List<Alarm> alarms = [];
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  initializeNotifications() async {
    var initializeAndroid = AndroidInitializationSettings('app_icon');
    var initializeIOS = IOSInitializationSettings();
    var initializeSettings =
        InitializationSettings(initializeAndroid, initializeIOS);
    await localNotificationsPlugin.initialize(initializeSettings);
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      prefs = sp;
      if (prefs.getBool('setup') == null) {
        prefs.setBool('show_progress_bars', true);
        prefs.setBool('dark_mode', false);
        prefs.setBool('funky_mode', false);
        prefs.setBool('ultra_funky_mode', false);
        prefs.setBool('setup', true);
      }
    });
    controller = new TabController(vsync: this, length: 2);
    initializeNotifications();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.laundry_room_name),
        bottom: new TabBar(
          controller: controller,
          tabs: <Widget>[
            new Tab(icon: new Icon(Icons.broken_image)),
            new Tab(icon: new Icon(Icons.wb_sunny)),
          ],
        ),
      ),
      body: FutureBuilder(
        future: fetchAll(widget.school_desc_key, widget.laundry_room_location),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) {
            return new Container();
          }
          List washers =
              snapshot.data.where((mach) => mach.type == 'W').toList();
          List dryers =
              snapshot.data.where((mach) => mach.type == 'D').toList();
          return new TabBarView(controller: controller, children: <Widget>[
            new ListView.builder(
                itemCount: washers.length,
                itemBuilder: (context, index) =>
                    _listBuilder(context, washers[index])),
            new ListView.builder(
                itemCount: dryers.length,
                itemBuilder: (context, index) =>
                    _listBuilder(context, dryers[index])),
          ]);
        },
      ),
    );
  }

  Widget _listBuilder(BuildContext context, Machine machine) {
    alarms.add(Alarm(false, machine.appliance_desc_key, null));
    return Container(
      padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      height: 75.0,
      child: Row(
        children: [
          Image.network(
              'https://cdn1.iconfinder.com/data/icons/appliancesets/28/wm_front-512.png'),
          Padding(
            padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      (machine.type == 'W' ? 'Washer ' : 'Dryer ') +
                          machine.appliance_desc,
                      style: Theme.of(context).textTheme.title),
                  Text(machine.status,
                      style: Theme.of(context).textTheme.caption),
                  machine.status.toLowerCase().contains("remaining")
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
                          child: prefs.getBool('show_progress_bars')
                              ? new LinearPercentIndicator(
                                  width: 150.0,
                                  lineHeight: 6.0,
                                  percent: (machine.avg_run_time -
                                          machine.time_remaining) /
                                      (machine.avg_run_time),
                                  backgroundColor: Colors.grey[400],
                                  progressColor: Colors.blue,
                                )
                              : Container(),
                        )
                      : Container(),
                ]),
          ),
          Expanded(
            flex: 1,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              machine.status.toLowerCase().contains("remaining")
                  ? Switch(
                      value: alarms
                          .firstWhere((alarm) =>
                              alarm.appliance_desc_key ==
                              machine.appliance_desc_key)
                          .active,
                      onChanged: (val) async {
                        this.setState(() {
                          alarms
                              .firstWhere((alarm) =>
                                  alarm.appliance_desc_key ==
                                  machine.appliance_desc_key)
                              .active = val;
                        });
                        if (val) {
                          await _setAlarm(
                              (machine.type == 'W' ? 'Washer ' : 'Dryer ') +
                                  machine.appliance_desc,
                              machine.appliance_desc_key,
                              machine.appliance_desc,
                              machine.time_remaining);
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Alarm set for ${(machine.type == "W" ? "Washer " : "Dryer ") + machine.appliance_desc}')));
                        }
                      },
                      activeTrackColor: Colors.lightGreenAccent,
                      activeColor: Colors.green)
                  : Container(),
            ]),
          ),
        ],
      ),
    );
  }

  Future _setAlarm(String name, String appliance_desc_key,
      String appliance_desc, int time_remaining) async {
    var androidChannel = AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        importance: Importance.Max, priority: Priority.Max);
    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);
    localNotificationsPlugin.schedule(
        int.parse(appliance_desc),
        '$name is done!',
        'The laundry in $name is done!',
        new DateTime.now().add(new Duration(minutes: time_remaining)),
        platformChannel);
  }

  Future<List<Machine>> fetchAll(
      String school_desc_key, String laundry_room_location) async {
    var url = Endpoint.uri('/currentRoomData', queryParameters: {
      'school_desc_key': school_desc_key,
      'location': laundry_room_location
    });
    print(url);
    http.Response resp = await http.get(url.toString());
    List resJson = json.decode(resp.body)['objects'];
    resJson = resJson.where((el) => el['appliance_desc_key'] != null).toList();
    return resJson.map((mach) => new Machine(mach)).toList();
  }
}
