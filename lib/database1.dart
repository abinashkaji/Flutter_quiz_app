import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  static Future<Database> initializeDatabase() async {
    final path = join(await getDatabasesPath(), 'number_database.db');
    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE numbers(id INTEGER PRIMARY KEY, number INTEGER)',
        );
      },
      version: 1,
    );
  }

  static Future<void> insertNumber(int number) async {
    final db = await database;
    await db.insert(
      'numbers',
      {'number': number},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<int>> getNumbers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('numbers');
    return List.generate(maps.length, (i) {
      return maps[i]['number'];
    });
  }
}
