import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  // Getter για την βάση δεδομένων
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Αρχικοποίηση της βάσης δεδομένων
  Future<Database> _initDatabase() async {
    String dbPath = join(await getDatabasesPath(), 'goaldigger.db');

    // Αν η βάση δεν υπάρχει, τη δημιουργούμε
    if (!await File(dbPath).exists()) {
      await _createDatabaseFromSQL(dbPath);
    }

    return openDatabase(dbPath);
  }

  // Δημιουργία της βάσης από το SQL αρχείο
  Future<void> _createDatabaseFromSQL(String dbPath) async {
    String sqlScript = await rootBundle.loadString('assets/sql/goaldigger_schema.sql');
    List<String> sqlStatements = sqlScript.split(';'); // Διαχωρισμός εντολών με βάση το `;`

    final db = await openDatabase(dbPath, version: 1);
    Batch batch = db.batch();

    for (String statement in sqlStatements) {
      if (statement.trim().isNotEmpty) {
        batch.execute(statement);
      }
    }

    await batch.commit(noResult: true);
  }
}
