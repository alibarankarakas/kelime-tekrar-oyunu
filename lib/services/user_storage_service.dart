import 'package:shared_preferences/shared_preferences.dart';

class UserStorageService {
  static const String nameKey = 'user_name';
  static const String emailKey = 'user_email';
  static const String passwordKey = 'user_password';

  static Future<void> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(nameKey, name);
    await prefs.setString(emailKey, email);
    await prefs.setString(passwordKey, password);
  }

  static Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString(emailKey);
    final savedPassword = prefs.getString(passwordKey);

    return email == savedEmail && password == savedPassword;
  }

  static Future<String?> getPasswordByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString(emailKey);
    final savedPassword = prefs.getString(passwordKey);

    if (email == savedEmail) {
      return savedPassword;
    }

    return null;
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(nameKey);
  }
}