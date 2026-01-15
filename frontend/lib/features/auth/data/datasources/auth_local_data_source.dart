import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AuthLocalDataSource {
  void writeToken(String token);
  String? getToken();
  void logout();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  void writeToken(String token) {
    sharedPreferences.setString('x-auth-token', token);
  }

  @override
  String? getToken() {
    return sharedPreferences.getString('x-auth-token');
  }

  @override
  void logout() {
    sharedPreferences.remove('x-auth-token');
  }
}
