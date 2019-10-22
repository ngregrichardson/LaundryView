import 'package:flutter/material.dart';
import '../../endpoint.dart';
import '../../models/machine.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RoomDetail extends StatelessWidget {
  final String _school_desc_key;
  final String _laundry_room_location;
  final String _laundry_room_name;

  RoomDetail(this._school_desc_key, this._laundry_room_location,
      this._laundry_room_name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_laundry_room_name),
      ),
      body: FutureBuilder(
        future: fetchAll(_school_desc_key, _laundry_room_location),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (!snapshot.hasData) {
            return new Container();
          }
          return new ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) =>
                  _itemBuilder(context, snapshot.data[index]));
        },
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, Machine machine) {
    return GestureDetector(
      key: Key('room_detail_item_${machine.appliance_desc_key}'),
      child: Container(
        height: 50.0,
        child: Stack(
          children: [Text(machine.status)],
        ),
      ),
    );
  }

  Future<List<Machine>> fetchAll(
      String school_desc_key, String laundry_room_location) async {
    var url = Endpoint.uri('/currentRoomData', queryParameters: {
      'school_desc_key': school_desc_key,
      'location': laundry_room_location
    });
    http.Response resp = await http.get(url.toString());
    List resJson = json.decode(resp.body)['objects'];
    resJson = resJson.where((el) => el['appliance_desc_key'] != null).toList();
    return resJson.map((mach) => new Machine(mach)).toList();
  }
}
