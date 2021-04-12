import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences _sharedPrefs;

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  String get username => _sharedPrefs.getString('username') ?? "";

  String get token => _sharedPrefs.getString('token') ?? "";

  int get userId => _sharedPrefs.getInt('userId');
}
