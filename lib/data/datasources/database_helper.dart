import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/nutrition_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('six_scan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    
    await db.execute('''
CREATE TABLE scans ( 
  id $idType, 
  imagePath $textType,
  timestamp $textType,
  energy $textType,
  fat $textType,
  protein $textType,
  carbs $textType,
  sugar $textType,
  salt $textType
  )
''');
  }

  Future<void> create(ScanResultModel scan) async {
    final db = await instance.database;
    await db.insert('scans', scan.toMap());
  }

  Future<List<ScanResultModel>> readAllScans() async {
    final db = await instance.database;
    final orderBy = 'timestamp DESC';
    final result = await db.query('scans', orderBy: orderBy);

    return result.map((json) => ScanResultModel.fromMap(json)).toList();
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete(
      'scans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
