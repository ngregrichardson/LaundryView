import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import './models/favorite.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String favoritesTable = 'favorites_table';
  String schoolDescKeyCol = 'school_desc_key';
  String laundryRoomLocationCol = 'laundry_room_location';
  String laundryRoomNameCol = 'laundry_room_name';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'favorites.db';

    var favoritesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return favoritesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $favoritesTable($schoolDescKeyCol TEXT, $laundryRoomLocationCol TEXT, $laundryRoomNameCol TEXT)');
  }

  Future<List<Map<String, dynamic>>> getFavoritesMapList() async {
    Database db = await this.database;
    var result = await db.query(favoritesTable);
    return result;
  }

  Future<int> insertFavorite(Favorite favorite) async {
    Database db = await this.database;
    var result = await db.insert(favoritesTable, favorite.toMap());
    return result;
  }

  Future<int> deleteFavorite(String laundry_room_location) async {
    Database db = await this.database;
    var result = await db.rawDelete(
        'DELETE FROM $favoritesTable WHERE $laundryRoomLocationCol = $laundry_room_location');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $favoritesTable');
    var result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Favorite>> getFavorites() async {
    var favoritesMapList = await getFavoritesMapList();
    int count = favoritesMapList.length;

    List<Favorite> favoritesList = List<Favorite>();
    favoritesMapList.forEach((fav) {
      favoritesList.add(Favorite.fromMapObject(fav));
    });

    return favoritesList;
  }
}
