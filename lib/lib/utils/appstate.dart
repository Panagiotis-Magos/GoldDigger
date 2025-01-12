class AppState {
  static final AppState _instance = AppState._internal();

  int globaluserId=-1; // To store the user's ID globally

  factory AppState() {
    return _instance;
  }

  AppState._internal();
}