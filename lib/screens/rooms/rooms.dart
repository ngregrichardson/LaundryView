import 'package:flutter/material.dart';
import 'package:laundryview/main.dart';
import './text_section.dart';
import '../../models/room.dart';
import '../../endpoint.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Rooms extends StatelessWidget {
  final String _school_desc_key;
  final String _school_name;

  Rooms(this._school_desc_key, this._school_name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_school_name),
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
      onTap: () {
        _onLocationTap(
            context, room.laundry_room_location, room.laundry_room_name);
      },
      key: Key('room_list_item_${room.laundry_room_location}'),
      child: Container(
        height: 50.0,
        child: Stack(
          children: [TextSection(room.laundry_room_name)],
        ),
      ),
    );
  }

  _onLocationTap(BuildContext context, String laundry_room_location,
      String laundry_room_name) {
    Navigator.pushNamed(context, RoomDetailRoute, arguments: {
      "school_desc_key": _school_desc_key,
      "laundry_room_location": laundry_room_location,
      "laundry_room_name": laundry_room_name
    });
  }

  static Future<List<Room>> fetchAll(String school_desc_key) async {
    var url =
        Endpoint.uri('/c_room', queryParameters: {'loc': school_desc_key});
    http.Response resp = await http.get(url.toString());
    List resJson = json.decode(resp.body)['room_data'];
    return resJson.map((loc) => new Room(loc)).toList();
  }
}
