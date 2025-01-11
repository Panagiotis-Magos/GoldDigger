import 'package:flutter/material.dart';
import '../screens/intro.dart';
import '../screens/editprofile.dart';
import '../screens/login.dart';
import '../screens/profile.dart';
import '../utils/appstate.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String editprofile = '/editprofile';
  static const String intro = '/';
  static const String profile = '/profile';
  static const String mystuff = '/mystuff';
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Home Screen Placeholder'),
            ),
            body: const Center(
              child: Text('Welcome to the Home Screen!'),
            ),
          ),
    intro: (context) => IntroScreen(),
    login: (context) => LoginScreen(),
    profile: (context) => ProfileScreen(userId:  AppState().globaluserId),
    editprofile: (context) => EditProfileScreen(),
  };
}
