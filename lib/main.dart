import 'package:flutter/material.dart';
import 'screens/locations/locations.dart';
import 'screens/rooms/rooms.dart';
import 'screens/roomDetail/roomDetail.dart';
import 'screens/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

const LocationsRoute = '/';
const RoomsRoute = '/rooms';
const RoomDetailRoute = '/roomDetail';
const SettingsRoute = '/settings';

class App extends StatefulWidget {
  @override
  AppState createState() => new AppState();
}

class AppState extends State<App> {
  SharedPreferences prefs;

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
  }

  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
              primarySwatch: Colors.blue,
              brightness: brightness,
            ),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
              home: Locations(), onGenerateRoute: _routes(), theme: theme);
        });
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
        case SettingsRoute:
          screen = Settings();
          break;
        default:
          return null;
      }
      return MaterialPageRoute(builder: (BuildContext context) => screen);
    };
  }
}

void main() => runApp(App());
