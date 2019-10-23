import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => new SettingsState();
}

class SettingsState extends State<Settings> {
  SharedPreferences prefs;
  bool show_progress_bars = true;
  bool dark_mode = false;
  bool funky_mode = false;
  bool ultra_funky_mode = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      prefs = sp;
      setState(() {
        show_progress_bars = prefs.getBool('show_progress_bars');
        dark_mode = prefs.getBool('dark_mode');
        funky_mode = prefs.getBool('funky_mode');
        ultra_funky_mode = prefs.getBool('ultra_funky_mode');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Show progress bars'),
            trailing: Switch(
                value: show_progress_bars,
                onChanged: (val) {
                  _onChanged('show_progress_bars', val);
                }),
          ),
          ListTile(
            title: Text('Dark Mode'),
            trailing: Switch(
                value: dark_mode,
                onChanged: (val) {
                  _onChanged('dark_mode', val);
                  DynamicTheme.of(context)
                      .setBrightness(!val ? Brightness.light : Brightness.dark);
                }),
          ),
          ListTile(
            title: Text('Funky Mode'),
            trailing: Switch(
                value: funky_mode,
                onChanged: (val) {
                  _onChanged('funky_mode', val);
                }),
          ),
          ListTile(
            title: Text('Dark Mode'),
            trailing: Switch(
                value: ultra_funky_mode,
                onChanged: (val) {
                  _onChanged('ultra_funky_mode', val);
                }),
          ),
        ],
      ),
    );
  }

  _onChanged(String key, bool val) async {
    setState(() {
      switch (key) {
        case 'show_progress_bars':
          show_progress_bars = val;
          break;
        case 'dark_mode':
          dark_mode = val;
          break;
        case 'funky_mode':
          funky_mode = val;
          break;
        case 'ultra_funky_mode':
          ultra_funky_mode = val;
          break;
        default:
          break;
      }
    });
    prefs.setBool(key, val);
  }
}
