import 'package:laundryview/models/favorite.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../endpoint.dart';
import '../../models/machine.dart';
import '../../models/alarm.dart';
import 'package:sqflite/sqflite.dart';
import '../../database_helper.dart';
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  SharedPreferences prefs;
  TabController _tabController;
  List<Alarm> alarms = [];
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  RefreshController _refreshController;
  bool _loaded = false;
  List<Machine> machines = [];
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Favorite> favoritesList;

  Map<int, Color> color = {
    50: Color.fromRGBO(136, 14, 79, .1),
    100: Color.fromRGBO(136, 14, 79, .2),
    200: Color.fromRGBO(136, 14, 79, .3),
    300: Color.fromRGBO(136, 14, 79, .4),
    400: Color.fromRGBO(136, 14, 79, .5),
    500: Color.fromRGBO(136, 14, 79, .6),
    600: Color.fromRGBO(136, 14, 79, .7),
    700: Color.fromRGBO(136, 14, 79, .8),
    800: Color.fromRGBO(136, 14, 79, .9),
    900: Color.fromRGBO(136, 14, 79, 1),
  };

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
    WidgetsBinding.instance.addObserver(this);
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      prefs = sp;
    });
    _tabController = new TabController(vsync: this, length: 2);
    _refreshController = RefreshController();
    initializeNotifications();
    _onRefresh();
  }

  _onRefresh() async {
    machines =
        await getMachines(widget.school_desc_key, widget.laundry_room_location);
    _refreshController.refreshCompleted();
    setState(() {
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (favoritesList == null) {
      favoritesList = List<Favorite>();
      updateFavorites();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.laundry_room_name),
        bottom: new TabBar(
          controller: _tabController,
          tabs: <Widget>[
            new Tab(icon: new Icon(Icons.broken_image)),
            new Tab(icon: new Icon(Icons.wb_sunny)),
          ],
        ),
        actions: <Widget>[
          new Builder(builder: (BuildContext context) {
            return IconButton(
              icon: _favoritesIcon(),
              onPressed: () {
                toggleFavorite(context);
              },
            );
          }),
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          if (!_loaded) {
            return new Container(
                child: new Center(child: new CircularProgressIndicator()));
          }
          List washers = machines.where((mach) => mach.type == 'W').toList();
          List dryers = machines.where((mach) => mach.type == 'D').toList();
          return new TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: <Widget>[
                new SmartRefresher(
                  enablePullDown: true,
                  header: BezierCircleHeader(
                    circleColor: prefs.getBool('dark_mode')
                        ? MaterialColor(0xFFCF57E4, color)
                        : Colors.white,
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                      itemCount: washers.length,
                      itemBuilder: (context, index) =>
                          _listBuilder(context, washers[index])),
                ),
                new SmartRefresher(
                  enablePullDown: true,
                  header: BezierCircleHeader(
                    circleColor: prefs.getBool('dark_mode')
                        ? MaterialColor(0xFFCF57E4, color)
                        : Colors.white,
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                      itemCount: dryers.length,
                      itemBuilder: (context, index) =>
                          _listBuilder(context, dryers[index])),
                ),
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
                                  backgroundColor: prefs.getBool('dark_mode')
                                      ? Colors.white
                                      : Colors.grey[400],
                                  progressColor: prefs.getBool('dark_mode')
                                      ? MaterialColor(0xFFCF57E4, color)
                                      : Colors.blue,
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

  void toggleFavorite(BuildContext context) {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    if (favoritesList.any((fav) {
      return fav.laundry_room_location == widget.laundry_room_location;
    })) {
      dbFuture.then((database) {
        databaseHelper
            .deleteFavorite(widget.laundry_room_location)
            .then((result) {
          if (result != 0) {
            _showSnackBar(context,
                '${widget.laundry_room_name} has been removed from favorites');
            updateFavorites();
          } else {
            _showSnackBar(context,
                'There was a problem removing ${widget.laundry_room_name} from favorites');
          }
        });
      });
    } else {
      dbFuture.then((database) {
        databaseHelper
            .insertFavorite(Favorite(widget.school_desc_key,
                widget.laundry_room_location, widget.laundry_room_name))
            .then((result) {
          if (result != 0) {
            _showSnackBar(context,
                '${widget.laundry_room_name} has been added to favorites');
            updateFavorites();
          } else {
            _showSnackBar(context,
                'There was a problem adding ${widget.laundry_room_name} to favorites');
          }
        });
      });
    }
  }

  Icon _favoritesIcon() {
    if (favoritesList.any((fav) {
      return fav.laundry_room_location == widget.laundry_room_location;
    })) {
      return Icon(
        Icons.star,
        color: prefs.getBool('dark_mode')
            ? MaterialColor(0xFFCF57E4, color)
            : Colors.white,
      );
    }
    return Icon(Icons.star_border);
  }

  void updateFavorites() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Favorite>> favoritesListFuture =
          databaseHelper.getFavorites();
      favoritesListFuture.then((favoriteList) {
        setState(() {
          this.favoritesList = favoriteList;
        });
      });
    });
  }

  _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
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

  Future<List<Machine>> getMachines(
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
