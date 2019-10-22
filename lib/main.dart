import 'package:flutter/material.dart';
import 'screens/locations/locations.dart';
import 'screens/rooms/rooms.dart';
import 'screens/roomDetail/roomDetail.dart';

const LocationsRoute = '/';
const RoomsRoute = '/rooms';
const RoomDetailRoute = '/roomDetail';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Locations(),
      onGenerateRoute: _routes(),
    );
  }

  RouteFactory _routes() {
    return (settings) {
      final Map<String, dynamic> arguments = settings.arguments;
      Widget screen;
      switch (settings.name) {
        case LocationsRoute:
          screen = Locations();
          break;
        case RoomsRoute:
          screen =
              Rooms(arguments['school_desc_key'], arguments['school_name']);
          break;
        case RoomDetailRoute:
          screen = RoomDetail(
              school_desc_key: arguments['school_desc_key'],
              laundry_room_location: arguments['laundry_room_location'],
              laundry_room_name: arguments['laundry_room_name']);
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}

void main() => runApp(App());
