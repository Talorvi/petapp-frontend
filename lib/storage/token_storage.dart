import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petapp/models/user.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'api_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'api_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'api_token');
  }

  static Future<void> saveUser(User user) async {
    await _storage.write(key: 'user_id', value: user.id.toString());
    await _storage.write(key: 'user_name', value: user.name);
    await _storage.write(key: 'user_avatar_url', value: user.avatarUrl ?? '');
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: 'user_name');
  }

  static Future<String?> getUserAvatarUrl() async {
    return await _storage.read(key: 'user_avatar_url');
  }

  static Future<void> deleteUser() async {
    await _storage.delete(key: 'user_id');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_avatar_url');
  }
}
