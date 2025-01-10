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
      // Load SQL schema from assets
      String schema = await rootBundle.loadString('assets/database/goaldigger_schema.sql');

      // Open or create the database
      final db = await openDatabase(path, version: 1, onCreate: (db, version) async {
        List<String> commands = schema.split(';');
        for (String command in commands) {
          if (command.trim().isNotEmpty) {
            await db.execute(command);
          }
        }
      });

      return db;
    } else {
      return openDatabase(path);
    }
  }
}
