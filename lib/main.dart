import 'package:flutter/material.dart';
import './routes/app_routes.dart';
import 'utils/theme.dart';
import 'utils/database_helper.dart'; 

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; 
  runApp(GoldDiggerApp());
}

class GoldDiggerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoldDigger',
      theme: AppTheme.lightTheme, // Apply custom theme
      initialRoute: AppRoutes.intro, // Start with the Intro screen
      routes: AppRoutes.routes, // Use centralized routes
    );
  }
}