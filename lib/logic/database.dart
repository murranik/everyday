import 'dart:io';

import 'package:everyday/logic/models/alarm.dart';
import 'package:everyday/logic/models/event.dart';
import 'package:everyday/logic/models/financemodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database? _db;

  Future<Database?> get database async {
    if (_db != null) return _db;
    _db = await initDB();
    return _db;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = documentsDirectory.path + "EveryDay2.db";
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("""
          CREATE TABLE Events (
            id INTEGER PRIMARY KEY,
            label TEXT,
            text TEXT,
            startDate TEXT,
            endDate TEXT,
            calendarColor TEXT
      )""");
      await db.execute("""
          CREATE TABLE AlarmDatas (
            id INTEGER PRIMARY KEY,
            label TEXT,
            dateTime TEXT,
            rangeOfDateForRepeat TEXT,
            isRepeat INTEGER,
            isActive INTEGER
      )""");
      await db.execute("""
          CREATE TABLE FinanceModels (
            id INTEGER PRIMARY KEY,
            label TEXT,
            eventId INTEGER,
            price REAL,
            isIncome INTEGER,
            FOREIGN KEY (eventId) REFERENCES FinanceModels (id)
              ON DELETE CASCADE ON UPDATE NO ACTION  
      )""");
    });
  }

  //Strings
  String getTableNameFromType(dynamic type) {
    return type.toString().replaceAll("Instance of ", "").replaceAll("'", "") +
        "s";
  }

  //Clear
  Future<void> clearDatabase() async {
    final db = await database;
    db!.delete("Events");
    db.delete("AlarmDatas");
    db.delete("FinanceModels");
  }

  Future<void> clearDatabaseTable<T>(T type) async {
    final db = await database;
    db!.delete(getTableNameFromType(type));
  }

  //Generic
  List<T> getModelsList<T>(T type, List<Map<String, Object?>> data) {
    dynamic objectsList;
    if (type is Event) {
      objectsList = data.map((e) => Event.fromMap(e)).toList();
    } else if (type is AlarmData) {
      objectsList = data.map((e) => AlarmData.fromMap(e)).toList();
    } else if (type is FinanceModel) {
      objectsList = data.map((e) => FinanceModel.fromMap(e)).toList();
    }
    return objectsList;
  }

  Future<List<dynamic>> getListById<T>(int id, T type) async {
    final db = await database;
    var res = await db!.query(
      getTableNameFromType(T),
      where: "eventId = ?",
      whereArgs: [id],
    );

    List<T> data = getModelsList<T>(type, res);

    return data;
  }

  Future<void> deleteModels<T>(T type) async {
    final db = await database;
    db!.delete(getTableNameFromType(type));
  }

  Future<void> deleteModelById(int? id, String collectionName) async {
    final db = await database;
    db!.delete(collectionName, where: "id = ?", whereArgs: [id]);
  }

  Future<T> getModelById<T>(int id, type) async {
    final db = await database;
    var res = await db!.query(
      getTableNameFromType(type),
      where: "id = ?",
      whereArgs: [id],
    );
    List<T> data = getModelsList(type, res);
    return data.first;
  }

  Future<List<T>> getModels<T>(type) async {
    final db = await database;
    var res = await db!.query(
      getTableNameFromType(type),
    );
    List<T> data = getModelsList(type, res);
    return data;
  }

  Future<T> upsertModel<T>(dynamic model) async {
    final db = await database;
    if (model.id == null) {
      model.id = await db!.insert(
        getTableNameFromType(model),
        model.toMap(),
      );
    } else {
      await db!.update(
        getTableNameFromType(model),
        model.toMap(),
        where: "id = ?",
        whereArgs: [model.id],
      );
    }
    return model;
  }
}
