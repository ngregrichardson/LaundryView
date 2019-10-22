import 'package:flutter/material.dart';
import 'screens/locations/locations.dart';
import 'screens/rooms/rooms.dart';

const LocationsRoute = '/';
const RoomsRoute = '/rooms';

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
          screen = Rooms(arguments['school_desc_key']);
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}

void main() => runApp(App());
