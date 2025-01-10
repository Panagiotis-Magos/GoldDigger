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
    // Get the path to the database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'golddigger.db');

    // Check if the database already exists
    final exists = await databaseExists(path);

    if (!exists) {
      // Load the SQL schema from the assets folder
      String sqlScript = await rootBundle.loadString('assets/database/goaldigger_schema.sql');

      // Open the database and execute the schema
      final db = await openDatabase(path, version: 1, onCreate: (db, version) async {
        List<String> commands = sqlScript.split(';');
        for (String command in commands) {
          if (command.trim().isNotEmpty) {
            await db.execute(command);
          }
        }
      });

      return db;
    } else {
      // Open the existing database
      return openDatabase(path);
    }
  }

  // Example: Insert a task
  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    return db.insert('tasks', task);
  }

  // Example: Get all tasks
  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return db.query('tasks');
  }
}