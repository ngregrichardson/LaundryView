import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/location.dart';
import '../../screens/rooms/text_section.dart';
import '../../endpoint.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
            accountName: Text("LaundryView"),
          ),
          ListTile(
              leading: Icon(Icons.face),
              title: Text("About"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text("About LaundryView"),
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                            child: Text(
                                "After trying out some other LaundryView apps when I got to college, I eventually found some shortcomings to all of them. To fix that, I decided to create my own. Use LaundryView to see laundry progress and get notifications when your laundry is done."),
                          ),
                        ],
                      );
                    });
              }),
          ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                _onSettingsTap(context);
              }),
          Divider(),
          ListTile(leading: Icon(Icons.help), title: Text("Help")),
          ListTile(leading: Icon(Icons.email), title: Text("Contact us")),
          ListTile(
              leading: Icon(Icons.announcement), title: Text("Report a bug")),
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
                      controller: _filter,
                      decoration: new InputDecoration(
                          prefixIcon:
                              new Icon(Icons.search, color: Colors.white),
                          hintText: "Search...",
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

  _onSettingsTap(BuildContext context) {
    Navigator.pushNamed(context, SettingsRoute);
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
