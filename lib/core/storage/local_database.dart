import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  static const _databaseName = 'dream_journal.db';
  static const _databaseVersion = 3;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await _createDreamsTable(db);
        await _createFollowUpAnswersTable(db);
        await _createUserProfilesTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createFollowUpAnswersTable(db);
        }
        if (oldVersion < 3) {
          await _createUserProfilesTable(db);
        }
      },
    );
  }

  Future<void> _createDreamsTable(Database db) async {
    await db.execute('''
      CREATE TABLE dreams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        mood TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createFollowUpAnswersTable(Database db) async {
    await db.execute('''
      CREATE TABLE follow_up_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dream_id INTEGER NOT NULL,
        emotions TEXT NOT NULL,
        stress_level INTEGER NOT NULL,
        sleep_quality TEXT NOT NULL,
        beliefs TEXT NOT NULL,
        cultural_background TEXT NOT NULL,
        recent_life_events TEXT NOT NULL,
        is_recurring INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (dream_id) REFERENCES dreams (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createUserProfilesTable(Database db) async {
    await db.execute('''
      CREATE TABLE user_profiles (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        age TEXT NOT NULL,
        nationality TEXT NOT NULL,
        cultural_background TEXT NOT NULL,
        profession_or_interest TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
}
