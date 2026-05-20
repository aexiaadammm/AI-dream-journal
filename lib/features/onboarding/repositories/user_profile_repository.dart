import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class UserProfileRepository {
  static const _profileKey = 'user_profile';

  Future<void> saveProfile(UserProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_profileKey, jsonEncode(profile.toMap()));
  }

  Future<UserProfile?> getProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final rawProfile = preferences.getString(_profileKey);

    if (rawProfile == null) {
      return null;
    }

    return UserProfile.fromMap(
      Map<String, Object?>.from(jsonDecode(rawProfile) as Map),
    );
  }
}
