import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  AuthController(this._preferences, {required String? initialUsername})
    : username = (initialUsername?.trim() ?? '').obs,
      isAuthenticated = isValidNim(initialUsername ?? '').obs;

  static final _nimPattern = RegExp(r'^\d{9}$');
  static const _usernameKey = 'username';
  static const _loggedInKey = 'isLoggedIn';

  final SharedPreferences _preferences;
  final RxString username;
  final RxBool isAuthenticated;

  static bool isValidNim(String nim) => _nimPattern.hasMatch(nim.trim());

  Future<bool> login({required String nim, required String password}) async {
    final normalizedNim = nim.trim();
    if (!isValidNim(normalizedNim) || password != '123') {
      return false;
    }

    await _preferences.setString(_usernameKey, normalizedNim);
    await _preferences.setBool(_loggedInKey, true);
    username.value = normalizedNim;
    isAuthenticated.value = true;
    return true;
  }

  Future<void> logout() async {
    await _preferences.remove(_usernameKey);
    await _preferences.remove(_loggedInKey);
    username.value = '';
    isAuthenticated.value = false;
  }
}
