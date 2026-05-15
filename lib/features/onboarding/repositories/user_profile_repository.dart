import 'package:sqflite/sqflite.dart';

import '../../../core/storage/local_database.dart';
import '../models/user_profile.dart';

class UserProfileRepository {
  UserProfileRepository({LocalDatabase? localDatabase})
    : _localDatabase = localDatabase ?? LocalDatabase.instance;

  final LocalDatabase _localDatabase;

  Future<void> saveProfile(UserProfile profile) async {
    final db = await _localDatabase.database;
    await db.insert(
      'user_profiles',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getProfile() async {
    final db = await _localDatabase.database;
    final rows = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return UserProfile.fromMap(rows.first);
  }
}
