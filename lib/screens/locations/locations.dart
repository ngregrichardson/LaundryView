import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/location.dart';
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
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
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
          title: Text(filteredLocations[index].school_name),
          onTap: () {
            _onLocationTap(context, filteredLocations[index].school_desc_key);
          },
        );
      },
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Locations');
        filteredLocations = locations;
        _filter.clear();
      }
    });
  }

  _onLocationTap(BuildContext context, String school_desc_key) {
    Navigator.pushNamed(context, RoomsRoute,
        arguments: {"school_desc_key": school_desc_key});
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
