import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class _MemorySession {
  static String? name;
  static String? email;
  static String? photo;
  static String? phone;
}

class UserSession {
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyPhoto = 'user_photo';
  static const String _keyPhone = 'user_phone';
  static const String _keyActiveGroupId = 'active_group_id';

  static Future<void> saveActiveGroupId(String groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyActiveGroupId, groupId);
    } catch (_) {}
  }

  static Future<String?> getActiveGroupId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyActiveGroupId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearActiveGroupId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyActiveGroupId);
    } catch (_) {}
  }

  static Future<void> saveUser(UserModel user) async {
    _MemorySession.name = user.name;
    _MemorySession.email = user.email;
    _MemorySession.photo = user.photoUrl;
    _MemorySession.phone = user.phone;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyName, user.name);
      await prefs.setString(_keyEmail, user.email);
      if (user.photoUrl != null) {
        await prefs.setString(_keyPhoto, user.photoUrl!);
      } else {
        await prefs.remove(_keyPhoto);
      }
      if (user.phone != null) {
        await prefs.setString(_keyPhone, user.phone!);
      } else {
        await prefs.remove(_keyPhone);
      }
    } catch (e) {
      debugPrint("UserSession saveUser notice: $e");
    }
  }

  static Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_keyName);
      final email = prefs.getString(_keyEmail);

      if (name != null && email != null) {
        return UserModel(
          name: name,
          email: email,
          photoUrl: prefs.getString(_keyPhoto),
          phone: prefs.getString(_keyPhone),
        );
      }
    } catch (e) {
      debugPrint("UserSession getUser notice: $e");
    }

    if (_MemorySession.name != null && _MemorySession.email != null) {
      return UserModel(
        name: _MemorySession.name!,
        email: _MemorySession.email!,
        photoUrl: _MemorySession.photo,
        phone: _MemorySession.phone,
      );
    }

    return null;
  }

  static Future<void> clear() async {
    _MemorySession.name = null;
    _MemorySession.email = null;
    _MemorySession.photo = null;
    _MemorySession.phone = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyName);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyPhoto);
      await prefs.remove(_keyPhone);
    } catch (e) {
      debugPrint("UserSession clear notice: $e");
    }
  }
}
