import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDp {
  static Database? db;

  Future<Database?> getDb() async {
    if (db == null) {
      db = await initialDp();
    }
    return db;
  }

  Future<Database> initialDp() async {
    String getDatabath = await getDatabasesPath();
    String path = join(getDatabath, 'expenses.dp');
    Database myDp = await openDatabase(path, onCreate: creatDp, version: 1);
    return myDp;
  }

  upgradeDp(Database db, int oldVersion, int newVersion) async {}

  Future<void> creatDp(Database db, int version) async {
    await db.execute(
      'CREATE TABLE homeexpenses (id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT, amount REAL, note TEXT ,date TEXT)',
    );

    //// new table
    await db.execute(
      'CREATE TABLE categories ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'title TEXT)',
      //// new table
    );
  }

  Future<List<Map<String, Object?>>> selectData(String sql) async {
    Database? myDb = await getDb();
    return await myDb!.rawQuery(sql);
  }

  Future<int> insertData(String sql) async {
    Database? myDb = await getDb();
    return await myDb!.rawInsert(sql);
  }

  Future<int> deleteData(String sql) async {
    Database? myDb = await getDb();
    return await myDb!.rawDelete(sql);
  }

  Future<int> updatetData(String sql) async {
    Database? myDb = await getDb();
    return await myDb!.rawUpdate(sql);
  }
}
