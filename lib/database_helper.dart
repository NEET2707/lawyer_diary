import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'cases.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Table: caseinfo

  static const String tblcaseid = "case_id";

  static const String tblcaseinfo = "caseinfo";
  static const String tblcasetitle = "case_title";
  static const String tblcourtname = "court_name";
  static const String tblcasetype = "case_type";
  static const String tblcasenumber = "case_number";
  static const String tblcaseyear = "case_year";
  static const String tblcasebehalfof = "case_behalf_of";
  static const String tblpartyname = "party_name";
  static const String tblcontact = "contact";
  static const String tblrespondentname = "respondent_name";
  static const String tblsection = "section";
  static const String tbladverseadvocatename = "adverse_advocate_name";
  static const String tbladverseadvocatecontact = "adverse_advocate_contact";
  static const String tbllastadjourndate = "last_adjourn_date";
  static const String tblisdisposed = "is_disposed";

  //disposedcase
  static const String tbldisposednature = "disposed_nature";
  static const String tbldisposeddate = "disposed_date";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('case_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS caseinfo (
      case_id INTEGER PRIMARY KEY AUTOINCREMENT,
      case_title TEXT,
      court_name TEXT,
      case_type TEXT,
      case_number TEXT,
      case_year INTEGER,
      case_behalf_of TEXT,
      party_name TEXT,
      contact TEXT,
      respondent_name TEXT,
      section TEXT,
      adverse_advocate_name TEXT,
      adverse_advocate_contact TEXT,
      last_adjourn_date TEXT,
      is_disposed INTEGER DEFAULT 0
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS disposedcase (
      disposedcase_id INTEGER PRIMARY KEY AUTOINCREMENT,
      case_id INTEGER,
      disposed_nature TEXT,
      disposed_date TEXT,
     
      FOREIGN KEY (case_id) REFERENCES caseinfo (case_id) ON DELETE CASCADE
    )
  ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<List<Map<String, dynamic>>> fetchCases() async {
    final db = await instance.database;
    return await db.query(tblcaseinfo);
  }

  Future<void> saveDisposedCase(int caseId, String disposedNature, DateTime disposedDate) async {
    final db = await DatabaseHelper.instance.database;

    await db.insert(
      'disposedcase',
      {
        'case_id': caseId,
        'disposed_nature': disposedNature,
        'disposed_date': disposedDate.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

  }



  // Future<List<Map<String, dynamic>>> getDisposedCases() async {
  //   final db = await DatabaseHelper.instance.database;
  //
  //   return await db.query('disposedcase');
  // }

  Future<List<Map<String, dynamic>>> getDisposedCases() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT    
      c.case_id, 
      c.case_title, 
      c.court_name, 
      c.case_type, 
      c.case_number, 
      c.case_year,
      c.case_behalf_of,
      c.party_name,
      c.contact,
      c.respondent_name,
      c.section,
      c.adverse_advocate_name,
      c.adverse_advocate_contact,
      c.last_adjourn_date,
      c.is_disposed,
      d.disposed_nature, 
      d.disposed_date,
      d.disposedcase_id
    FROM caseinfo c
    INNER JOIN disposedcase d ON c.case_id = d.case_id
  ''');
    return result;
  }


  Future<List<CaseModel>> getOngoingCases() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'caseinfo',
      where: 'is_disposed = ?',
      whereArgs: [0], // Only fetch cases that are NOT disposed
    );

    return results.map((e) => CaseModel.fromMap(e)).toList();
  }

}
