import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../endpoint.dart';
import '../../models/machine.dart';
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
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 2);
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
    //Widget wid = machine.type == "W" ? new Washers() ? new Dryers();
    return GestureDetector(
      key: Key('room_detail_item_${machine.appliance_desc_key}'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        height: 75.0,
        child: Row(
          children: [
            Image.network(
                'https://www.flaticon.com/premium-icon/icons/svg/2211/2211255.svg'),
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
                        style: Theme.of(context).textTheme.caption)
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBuilder(BuildContext context, String tab_name, List items) {
    return GestureDetector();
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
