// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
//
// class textlink {
//   // Table: caseinfo
//   static const String TABLE_CASE_INFO = "caseinfo";
//   static const String KEY_CASE_ID = "case_id";
//   static const String KEY_CASE_TITLE = "case_title";
//   static const String KEY_COURT_NAME = "court_name";
//   static const String KEY_CASE_TYPE = "case_type";
//   static const String KEY_CASE_NUMBER = "case_number";
//   static const String KEY_CASE_YEAR = "case_year";
//   static const String KEY_CASE_BEHALF_OF = "case_behalf_of";
//   static const String KEY_PARTY_NAME = "party_name";
//   static const String KEY_CONTACT = "contact";
//   static const String KEY_RESPONDENT_NAME = "respondent_name";
//   static const String KEY_SECTION = "section";
//   static const String KEY_ADVERSE_ADVOCATE_NAME = "adverse_advocate_name";
//   static const String KEY_ADVERSE_ADVOCATE_CONTACT = "adverse_advocate_contact";
//   static const String KEY_LAST_ADJOURN_DATE = "last_adjourn_date";
//   static const String KEY_IS_DISPOSED = "is_disposed";
//
// // Table: courtlist
//   static const String TABLE_COURT_LIST = "courtlist";
//   static const String KEY_COURT_ID = "court_id";
//   static const String KEY_COURT_NAME_IN_COURT_LIST = "court_name";
//
// // Table: casetype
//   static const String TABLE_CASE_TYPE = "casetype";
//   static const String KEY_CASETYPE_ID = "casetype_id";
//   static const String KEY_CASE_TYPE_NAME = "case_type";
//
// // Table: casenote
//   static const String TABLE_CASE_NOTE = "casenote";
//   static const String KEY_NOTES_ID = "notes_id";
//   static const String KEY_NOTE_CASE_ID = "case_id";
//   static const String KEY_NOTE_TEXT = "note";
//
// // Table: casehistory
//   static const String TABLE_CASE_HISTORY = "casehistory";
//   static const String KEY_HISTORY_ID = "history_id";
//   static const String KEY_HISTORY_CASE_ID = "case_id";
//   static const String KEY_PREVIOUS_DATE = "previous_date";
//   static const String KEY_ADJOURN_DATE = "adjourn_date";
//   static const String KEY_STEP = "step";
//
// // Table: casemultiplehistory
//   static const String TABLE_CASE_MULTIPLE_HISTORY = "casemultiplehistory";
//   static const String KEY_MULTIPLE_HISTORY_ID = "multiplehistory_id";
//   static const String KEY_MULTIPLE_HISTORY_CASE_ID = "case_id";
//   static const String KEY_MULTIPLE_HISTORY_PREVIOUS_DATE = "previous_date";
//   static const String KEY_MULTIPLE_HISTORY_ADJOURN_DATE = "adjourn_date";
//   static const String KEY_MULTIPLE_HISTORY_STEP = "step";
//
// // Table: disposedcase
//   static const String TABLE_DISPOSED_CASE = "disposedcase";
//   static const String KEY_DISPOSED_CASE_ID = "disposedcase_id";
//   static const String KEY_DISPOSED_CASE_CASE_ID = "case_id";
//   static const String KEY_DISPOSED_NATURE = "disposed_nature";
//   static const String KEY_DISPOSED_DATE = "disposed_date";
//
// }
//
// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._init();
//   static Database? _database;
//
//   DatabaseHelper._init();
//
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('case_database.db');
//     return _database!;
//   }
//
//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);
//     return await openDatabase(path, version: 1, onCreate: _createDB);
//   }
//
//   Future<void> _createDB(Database db, int version) async {
//
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS caseinfo (
//         case_id INTEGER PRIMARY KEY AUTOINCREMENT,
//         case_title TEXT,
//         court_name INTEGER,
//         case_type INTEGER,
//         case_number TEXT,
//         case_year INTEGER,
//         case_behalf_of TEXT,
//         party_name TEXT,
//         contact TEXT,
//         respondent_name TEXT,
//         section TEXT,
//         adverse_advocate_name TEXT,
//         adverse_advocate_contact TEXT,
//         last_adjourn_date TEXT,
//         is_disposed BOOLEAN
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS courtlist (
//         court_id INTEGER PRIMARY KEY AUTOINCREMENT,
//         court_name TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS casetype (
//         casetype_id INTEGER PRIMARY KEY AUTOINCREMENT,
//         case_type TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS casenote (
//         notes_id INTEGER PRIMARY KEY AUTOINCREMENT,
//         case_id INTEGER,
//         note TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS casehistory (
//         history_id INTEGER PRIMARY KEY AUTOINCREMENT,
//         case_id INTEGER,
//         previous_date TEXT,
//         adjourn_date TEXT,
//         step TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS casemultiplehistory (
//         multiplehistory_id INTEGER PRIMARY KEY AUTOINCREMENT,
//         case_id INTEGER,
//         previous_date TEXT,
//         adjourn_date TEXT,
//         step TEXT
//       )
//     ''');
//
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS disposedcase (
//         disposedcase_id INTEGER PRIMARY KEY AUTOINCREMENT,
//         case_id INTEGER,
//         disposed_nature TEXT,
//         disposed_date TEXT
//       )
//     ''');
//   }
//
//   Future<void> close() async {
//     final db = await instance.database;
//     db.close();
//   }
// }
