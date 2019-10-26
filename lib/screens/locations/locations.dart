import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/location.dart';
import '../../screens/rooms/text_section.dart';
import '../../endpoint.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Locations extends StatefulWidget {
  @override
  LocationsState createState() => new LocationsState();
}

class LocationsState extends State<Locations> {
  final TextEditingController _filter = new TextEditingController();
  String _searchTerm = "";
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Locations');
  List<Location> locations = new List();
  List<Location> filteredLocations = new List();

  String about =
      'After about a month at college, I got fed up with the LaundryView app I was using. I would continue to get notifications even once the machine had ended, not see when a machine was in "Idle" mode, and a few other things. So I made LaundryTwo with a modern, easy-to-use interface, while still maintaining all the necessary features (and adding some!).';
  String help =
      'From the Locations page, you can search for your school/apartment building. Once there, find the laundry room your would like to view. There may only be one for some properties. There you will be able to see each washer and dryer, set an alarm for specific machines, and mark the room as a favorite using the star in the top left.';

  LocationsState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchTerm = "";
          filteredLocations = locations;
        });
      } else {
        setState(() {
          _searchTerm = _filter.text;
        });
      }
    });
  }

  @override
  void initState() {
    this.fetchAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildBar(context),
      body: Container(child: _buildList()),
      drawer: Drawer(
        child: Column(children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: Text("v1.0"),
            accountName: Text("LaundryTwo"),
          ),
          ListTile(
              leading: Icon(Icons.face),
              title: Text("About"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text("About LaundryTwo",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            )),
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Text(
                              about,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      );
                    });
              }),
          ListTile(
              leading: Icon(Icons.stars),
              title: Text("Favorites"),
              onTap: () {
                _onFavoritesTap(context);
              }),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                _onSettingsTap(context);
              }),
          Divider(),
          ListTile(
              leading: Icon(Icons.help),
              title: Text("Help"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text("LaundryTwo Help",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            )),
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Text(
                              help,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      );
                    });
              }),
          ListTile(
            leading: Icon(Icons.email),
            title: Text("Contact us"),
            onTap: () {
              _onContactTap(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.announcement),
            title: Text("Report a bug"),
            onTap: () {
              _onReportBugTap(context);
            },
          ),
        ]),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      actions: <Widget>[
        new IconButton(
            icon: _searchIcon,
            onPressed: () {
              setState(() {
                if (this._searchIcon.icon == Icons.search) {
                  this._searchIcon = new Icon(Icons.close);
                  this._appBarTitle = new TextField(
                      textAlignVertical: TextAlignVertical.center,
                      style: new TextStyle(color: Colors.white),
                      controller: _filter,
                      decoration: new InputDecoration(
                          border: InputBorder.none,
                          prefixIcon:
                              new Icon(Icons.search, color: Colors.white),
                          hintText: "Search...",
                          labelStyle: new TextStyle(color: Colors.white),
                          hintStyle: new TextStyle(color: Colors.white)));
                } else {
                  setState(() {
                    this._searchIcon = new Icon(Icons.search);
                    this._appBarTitle = new Text('Locations');
                    filteredLocations = locations;
                    _filter.clear();
                  });
                }
              });
            }),
      ],
    );
  }

  Widget _buildList() {
    if (_searchTerm.isNotEmpty) {
      List<Location> tempList = new List();
      for (int i = 0; i < filteredLocations.length; i++) {
        if (filteredLocations[i]
            .school_name
            .toLowerCase()
            .contains(_searchTerm.toLowerCase())) {
          tempList.add(filteredLocations[i]);
        }
      }
      filteredLocations = tempList;
    }
    return ListView.builder(
      itemCount: locations == null ? 0 : filteredLocations.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: TextSection(filteredLocations[index].school_name),
          onTap: () {
            _onLocationTap(context, filteredLocations[index].school_desc_key,
                filteredLocations[index].school_name);
          },
        );
      },
    );
  }

  _onLocationTap(
      BuildContext context, String school_desc_key, String school_name) {
    Navigator.pushNamed(context, RoomsRoute, arguments: {
      "school_desc_key": school_desc_key,
      "school_name": school_name
    });
  }

  _onFavoritesTap(BuildContext context) {
    Navigator.pushNamed(context, FavoritesRoute);
  }

  _onSettingsTap(BuildContext context) {
    Navigator.pushNamed(context, SettingsRoute);
  }

  _onContactTap(BuildContext context) async {
    const url = 'mailto:contact@nrdesign.xyz';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch url';
    }
  }

  _onReportBugTap(BuildContext context) async {
    const url = 'https://github.com/ngregrichardson/LaundryView/issues';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch url';
    }
  }

  Future<List<Location>> fetchAll() async {
    var url = Endpoint.uri('/c_locations');
    http.Response resp = await http.get(url.toString());
    List resJson = json.decode(resp.body);
    setState(() {
      locations = resJson.map((loc) => new Location(loc)).toList();
      filteredLocations = locations;
    });
    return resJson.map((loc) => new Location(loc)).toList();
  }
}
