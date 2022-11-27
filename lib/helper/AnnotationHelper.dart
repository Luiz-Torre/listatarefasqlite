import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/Annotation.dart';

class AnnotationHelper {
  static final _annotationHelper = AnnotationHelper.internal();
  static Database? _db;
  static final String tableName = "annotation";

  AnnotationHelper.internal();

  factory AnnotationHelper() {
    return _annotationHelper;
  }

  Future<Database> get db async {
    _db ??= await initDb();
    return _db!;
  }

  _onCreateDb(Database db, int version) {

    String sql = """
    CREATE TABLE annotation(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title VARCHAR,
      description TEXT,
      data DATETIME
    );
    """;

    db.execute(sql);

  }

  initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "annotation.db");

    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreateDb
    );

    return db;
  }

  Future<int> insertAnnotation(Annotation annotation) async{
    var database = await db;

    int result = await database.insert(tableName, annotation.toMap());

    return result;

  }

  getAnnotations() async {
    var database = await db;

    String sql = "SELECT * FROM $tableName ORDER BY data DESC";
    List annotations = await database!.rawQuery(sql);

    return annotations;
  }
  

  Future<int> deleteAnnotation(int id) async {
    var database = await db;

    int result = await database!.delete(
      tableName,
      where: "id = ?",
      whereArgs: [id]
    );

    return result;
  }

  Future<int> updateAnnotation(Annotation annotation) async {
    var database = await db;

    int result = await database!.update(
      tableName,
      annotation.toMap(),
      where: "id = ?",
      whereArgs: [annotation.id]
    );

    return result;
  }
}