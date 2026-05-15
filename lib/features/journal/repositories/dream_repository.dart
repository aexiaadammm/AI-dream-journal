import 'package:sqflite/sqflite.dart';

import '../../../core/storage/local_database.dart';
import '../models/dream_entry.dart';

class DreamRepository {
  DreamRepository({LocalDatabase? localDatabase})
    : _localDatabase = localDatabase ?? LocalDatabase.instance;

  final LocalDatabase _localDatabase;

  Future<int> addDream(DreamEntry dream) async {
    final db = await _localDatabase.database;
    return db.insert(
      'dreams',
      dream.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DreamEntry>> getDreams() async {
    final db = await _localDatabase.database;
    final rows = await db.query('dreams', orderBy: 'created_at DESC');

    return rows.map(DreamEntry.fromMap).toList();
  }
}
