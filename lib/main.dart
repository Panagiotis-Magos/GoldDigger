import 'package:flutter/material.dart';
import './routes/app_routes.dart';
import 'utils/theme.dart';
import 'services/database_service.dart'; 
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';



Future<void> clearDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'golddigger.db');

  print('Deleting database at $path...');
  await deleteDatabase(path);
  print('Database deleted.');
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Clear database for development/testing purposes
  //await clearDatabase();
  final dbService = DatabaseService();
  await dbService.database; // Ensure the database is initialized
  runApp(GoldDiggerApp());
}

class GoldDiggerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoldDigger',
      theme: AppTheme.lightTheme, // Apply custom theme
      initialRoute: AppRoutes.intro,//Start with the Intro screen
      routes: AppRoutes.routes, // Use centralized routes
    );
  }
}
