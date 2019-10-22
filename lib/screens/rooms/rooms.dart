import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../models/room.dart';
import '../../endpoint.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Rooms extends StatelessWidget {
  final String _school_desc_key;

  Rooms(this._school_desc_key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rooms'),
      ),
      body: FutureBuilder(
        future: fetchAll(_school_desc_key),
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

  Widget _itemBuilder(BuildContext context, Room room) {
    return GestureDetector(
      key: Key('room_list_item_${room.laundry_room_location}'),
      child: Container(
        height: 50.0,
        child: Stack(
          children: [Text(room.laundry_room_name)],
        ),
      ),
    );
  }

  static Future<List<Room>> fetchAll(String school_desc_key) async {
    var url =
        Endpoint.uri('/c_room', queryParameters: {'loc': school_desc_key});
    http.Response resp = await http.get(url.toString());
    List resJson = json.decode(resp.body)['room_data'];
    return resJson.map((loc) => new Room(loc)).toList();
  }
}
