import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();
  static Database? _database;

  DatabaseService._();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'golddigger.db');

  // Check if the database already exists
  final exists = await databaseExists(path);

  if (!exists) {
    print('Database does not exist. Creating it now.');

    // Load SQL schema from assets
    final schema = await rootBundle.loadString('assets/database/goaldigger_schema.sql');
    print('Loaded schema: $schema');

    // Open or create the database
    final db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      List<String> commands = schema.split(';');
      for (String command in commands) {
        if (command.trim().isNotEmpty) {
          print('Executing command: $command');
          await db.execute(command);
        }
      }
    });
    // Query for tables in the database
    final tables = await db.rawQuery("SELECT * FROM sqlite_master WHERE type='table'");
    print('Tables in the database: $tables');

    return db;
  } else {
      print('Database already exists at $path.');
      // Open the database
      final db = await openDatabase(path);

      // Query for tables in the database
      final tables = await db.rawQuery("SELECT * FROM sqlite_master WHERE type='table'");
      print('Tables in the database: $tables');

    return db;
    }
  }
}

