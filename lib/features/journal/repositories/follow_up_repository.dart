import 'package:sqflite/sqflite.dart';

import '../../../core/storage/local_database.dart';
import '../models/follow_up_answers.dart';

class FollowUpRepository {
  FollowUpRepository({LocalDatabase? localDatabase})
    : _localDatabase = localDatabase ?? LocalDatabase.instance;

  final LocalDatabase _localDatabase;

  Future<int> saveAnswers(FollowUpAnswers answers) async {
    final db = await _localDatabase.database;
    return db.insert(
      'follow_up_answers',
      answers.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<FollowUpAnswers?> getLatestAnswersForDream(int dreamId) async {
    final db = await _localDatabase.database;
    final rows = await db.query(
      'follow_up_answers',
      where: 'dream_id = ?',
      whereArgs: [dreamId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return FollowUpAnswers.fromMap(rows.first);
  }
}
