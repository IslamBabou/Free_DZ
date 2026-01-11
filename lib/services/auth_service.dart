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
  }

  // Store current user ID (from login response)
  static String? _currentUserId;

  // Call this when user logs in
  static void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  // Get the current logged-in user ID
  static String? get currentUserId => _currentUserId;

 
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
