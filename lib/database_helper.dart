import 'dart:io';
import 'dart:async';
import 'package:laundryview/models/alarm.dart';
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

  String alarmsTable = 'alarms_table';
  String applianceDescKeyCol = 'appliance_desc_key';
  String endTimeCol = 'end_time';

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
    String path = directory.path + 'laundryview.db';
    var database = await openDatabase(path, version: 1, onCreate: _createDb);
    return database;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $favoritesTable($schoolDescKeyCol TEXT, $laundryRoomLocationCol TEXT, $laundryRoomNameCol TEXT)');
    await db.execute(
        'CREATE TABLE $alarmsTable($applianceDescKeyCol TEXT, $endTimeCol TEXT)');
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

  Future<int> getFavoritesCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $favoritesTable');
    var result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Favorite>> getFavorites() async {
    var favoritesMapList = await getFavoritesMapList();
    List<Favorite> favoritesList = List<Favorite>();
    favoritesMapList.forEach((fav) {
      favoritesList.add(Favorite.fromMapObject(fav));
    });

    return favoritesList;
  }

  Future<List<Map<String, dynamic>>> getAlarmsMapList() async {
    Database db = await this.database;
    var result = await db.query(alarmsTable);
    return result;
  }

  Future<int> insertAlarm(Alarm alarm) async {
    Database db = await this.database;
    var result = await db.insert(alarmsTable, alarm.toMap());
    return result;
  }

  Future<int> deleteAlarm(String appliance_desc_key) async {
    Database db = await this.database;
    var result = await db.rawDelete(
        'DELETE FROM $alarmsTable WHERE $applianceDescKeyCol = $appliance_desc_key');
    return result;
  }

  Future<int> getAlarmsCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $alarmsTable');
    var result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Alarm>> getAlarms() async {
    var alarmsMapList = await getAlarmsMapList();
    List<Alarm> alarmsList = List<Alarm>();
    alarmsMapList.forEach((alarm) {
      alarmsList.add(Alarm.fromMapObject(alarm));
    });

    return alarmsList;
  }
}
