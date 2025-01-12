import 'package:flutter/material.dart';
import 'package:golddigger/screens/shop.dart';
import '../screens/intro.dart';
import '../screens/editprofile.dart';
import '../screens/login.dart';
import '../screens/profile.dart';
import '../screens/mystuff.dart';
import '../utils/appstate.dart';
import '../screens/searchscreen.dart';
import '../screens/home.dart';
import '../screens/camerascreen.dart';

class AppRoutes {
  static const String intro = '/';
  static const String profile = '/profile';
  static const String mystuff = '/mystuff';
  static const String editprofile = '/editprofile';
  static const String login = '/login';
  static const String searchscreen = '/searchscreen';
  static const String shop = '/shop';
  static const String home = '/home';
  //static const String camera = '/camera';

  static final Map<String, WidgetBuilder> routes = {
    intro: (context) => IntroScreen(),
    login: (context) => LoginScreen(),
    profile: (context) => ProfileScreen(userId: AppState().globaluserId),
    editprofile: (context) => EditProfileScreen(userId: AppState().globaluserId),
    mystuff: (context) => MyStuffScreen(userId: AppState().globaluserId),
    searchscreen: (context) => SearchScreen(userId: AppState().globaluserId),
    home: (context) => HomeScreen(userId:AppState().globaluserId),
    shop: (context) => ShopScreen(userId: AppState().globaluserId),
    //camera: (context) => CameraScreen(), // Add the CameraScreen route
  };
}