import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
  }

  // Store current user ID (from login response)
  static String? _currentUserId;
  static const _userIdKey = 'user_id';

  // Call this when user logs in
  static Future<void> setCurrentUserId(String userId) async {
    _currentUserId = userId;
    await _storage.write(key: _userIdKey, value: userId);
  }

  // Get the current logged-in user ID
  static String? get currentUserId => _currentUserId;

 
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<dynamic> getCurrentUserId() async {
      _currentUserId = await _storage.read(key: _userIdKey);
      return _currentUserId;

  }
}
