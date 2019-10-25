import 'package:flutter/material.dart';
import 'package:laundryview/models/favorite.dart';
import '../../main.dart';
import '../../screens/rooms/text_section.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../database_helper.dart';

class Favorites extends StatefulWidget {
  @override
  FavoritesState createState() => new FavoritesState();
}

class FavoritesState extends State<Favorites> {
  final TextEditingController _filter = new TextEditingController();
  String _searchTerm = "";
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Favorites');
  List<Favorite> favorites;
  List<Favorite> filteredFavorites = new List();
  DatabaseHelper databaseHelper = DatabaseHelper();

  FavoritesState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchTerm = "";
          filteredFavorites = favorites;
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (favorites == null) {
      favorites = List<Favorite>();
      updateFavorites();
    }
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
                    this._appBarTitle = new Text('Favorites');
                    filteredFavorites = favorites;
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
      List<Favorite> tempList = new List();
      for (int i = 0; i < filteredFavorites.length; i++) {
        if (filteredFavorites[i]
            .laundry_room_name
            .toLowerCase()
            .contains(_searchTerm.toLowerCase())) {
          tempList.add(filteredFavorites[i]);
        }
      }
      filteredFavorites = tempList;
    }
    return ListView.builder(
      itemCount: favorites == null ? 0 : filteredFavorites.length,
      itemBuilder: (BuildContext context, int index) {
        return new ListTile(
          title: TextSection(filteredFavorites[index].laundry_room_name),
          onTap: () {
            _onFavoritesTap(
                context,
                filteredFavorites[index].school_desc_key,
                filteredFavorites[index].laundry_room_location,
                filteredFavorites[index].laundry_room_name);
          },
        );
      },
    );
  }

  _onFavoritesTap(BuildContext context, String school_desc_key,
      String laundry_room_location, String laundry_room_name) {
    Navigator.pushNamed(context, RoomDetailRoute, arguments: {
      "school_desc_key": school_desc_key,
      "laundry_room_location": laundry_room_location,
      "laundry_room_name": laundry_room_name
    });
  }

  void updateFavorites() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Favorite>> favoritesListFuture =
          databaseHelper.getFavorites();
      favoritesListFuture.then((favoriteList) {
        setState(() {
          this.favorites = favoriteList;
          this.filteredFavorites = favoriteList;
        });
      });
    });
  }
}
