import 'package:flutter/material.dart';
import '../screens/intro.dart';
import '../screens/editprofile.dart';
import '../screens/login.dart';
import '../screens/profile.dart';
import '../screens/mystuff.dart';
import '../utils/appstate.dart';
import '../screens/searchscreen.dart';

class AppRoutes {
  static const String intro = '/';
  static const String profile = '/profile';
  static const String mystuff = '/mystuff';
  static const String editprofile = '/editprofile';
  static const String login = '/login';

  static final Map<String, WidgetBuilder> routes = {
    intro: (context) => IntroScreen(),
    login: (context) => LoginScreen(),
    profile: (context) => ProfileScreen(userId: AppState().globaluserId),
    editprofile: (context) => EditProfileScreen(userId: AppState().globaluserId),
    mystuff: (context) => MyStuffScreen(userId: AppState().globaluserId),
    searchscreen: (context) => SearchScreen(userId: AppState().globaluserId),
  };
}

