import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../cases.dart';
import 'package:saf_util/saf_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:csv/csv.dart';
import 'package:saf_stream/saf_stream.dart';

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
  static const String tbldisposedcaseid = "disposedcase_id";
  static const String tbldisposeddate = "disposed_date";


  //casemultiplehistory
  static const String tblmultiplehistoryid = "multiplehistory_id";
  static const String tblpreviousdate = "previous_date";
  static const String tbladjourndate = "adjourn_date";
  static const String tblstep = "step";

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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS casemultiplehistory (
        multiplehistory_id INTEGER PRIMARY KEY AUTOINCREMENT,
        case_id INTEGER,
        previous_date TEXT,
        adjourn_date TEXT,
        step TEXT,
        FOREIGN KEY (case_id) REFERENCES caseinfo (case_id) ON DELETE CASCADE

      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS casenote (
        notes_id INTEGER PRIMARY KEY AUTOINCREMENT,
        case_id INTEGER,
        note TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS courtlist (
        court_id INTEGER PRIMARY KEY AUTOINCREMENT,
        court_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS casetype (
        casetype_id INTEGER PRIMARY KEY AUTOINCREMENT,
        case_type TEXT
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

  Future<int> deleteCase(int caseId) async {
    final db = await database;
    return await db.delete('caseinfo', where: 'case_id = ?', whereArgs: [caseId]);
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

  Future<void> updateCaseAsDisposed(int caseId) async {
    final db = await instance.database;
    await db.update(
      'caseinfo',
      {'is_disposed': 1},
      where: 'case_id = ?',
      whereArgs: [caseId],
    );
  }

  Future<int> insertCaseStep(int caseId, String previousDate, String adjournDate, String step) async {
    final db = await database;
    return await db.insert('casemultiplehistory', {
      'case_id': caseId,
      'previous_date': previousDate,
      'adjourn_date': adjournDate,
      'step': step,
    });
  }

  Future<List<Map<String, dynamic>>> getCaseSteps(int caseId) async {
    final db = await database;
    return await db.query('casemultiplehistory', where: 'case_id = ?', whereArgs: [caseId]);
  }

  Future<int> saveCaseMultipleHistory( Map<String, dynamic> historyData) async {
    final db = await database;
    return await db.insert(
      'casemultiplehistory',
      historyData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCaseMultipleHistory(int caseId) async {
    final db = await database;
    return await db.query(
      'casemultiplehistory',
      where: 'case_id = ?',
      whereArgs: [caseId],
      orderBy: 'adjourn_date DESC',
    );
  }

  Future<int> updateCaseStep(int multiplehistoryId, String updatedStep) async {
    final db = await database;
    return await db.update(
      'casemultiplehistory',
      {'step': updatedStep},
      where: 'multiplehistory_id = ?', // Use correct column name
      whereArgs: [multiplehistoryId],
    );
  }



  Future<int> saveCaseNote(int caseId, String note) async {
    final db = await database;
    return await db.insert(
      'casenote',
      {
        'case_id': caseId,
        'note': note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Function to fetch all notes for a given case_id
  Future<List<Map<String, dynamic>>> fetchCaseNotes(int caseId) async {
    final db = await database;
    return await db.query(
      'casenote',
      where: 'case_id = ?',
      whereArgs: [caseId],
    );
  }

  Future<int> deleteNote(int notesId) async {
    final db = await database;
    return await db.delete(
      'casenote',
      where: 'notes_id = ?',
      whereArgs: [notesId],
    );
  }

  Future<List<Map<String, dynamic>>> getCasesByAdjournDate(String date) async {
    final db = await database;
    print("Searching cases for date: $date");

    List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT 
      ci.*, 
      cmh.adjourn_date
    FROM casemultiplehistory cmh
    INNER JOIN caseinfo ci ON cmh.case_id = ci.case_id
    WHERE substr(cmh.adjourn_date, 1, 10) = ?
    ORDER BY cmh.adjourn_date DESC
  ''', [date]);

    print("Cases found: ${results.length}");
    return results;
  }

  Future<List<Map<String, dynamic>>> checkAllCases() async {
    final db = await database;
    return await db.query('casemultiplehistory');
  }


  Future<int> getCountExcludingDisposedCases() async {

    // Open the database
    final db = await database;

    // Run the query to get the count of non-disposed cases
    List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT COUNT(*) 
    FROM caseinfo 
    WHERE case_id NOT IN (SELECT case_id FROM disposedcase)
  ''');

    // Extract the count from the result
    int count = result.first.values.first;

    return count;
  }

  Future<int> countDisposedCases() async {
    // Query the table to count the records
    final db = await database;

    List<Map<String, dynamic>> result = await db.rawQuery('SELECT COUNT(*) FROM disposedcase');

    // The result will be a list with a single row containing the count
    int count = Sqflite.firstIntValue(result) ?? 0; // If no records, default to 0
    return count;
  }


  Future<int> countRecordsWithTodayAdjournDate() async {
    // Get today's date in the same format as the adjourn_date
    final db = await database;

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print(todayDate);
    // Query to count records where adjourn_date is today's date
    var result = await db.rawQuery('''
    SELECT COUNT(*) 
    FROM caseinfo c
    JOIN casemultiplehistory h ON c.case_id = h.case_id
    WHERE strftime('%Y-%m-%d', h.adjourn_date) = ?
  ''', [todayDate]);



    // Get the count from the result
    int count = Sqflite.firstIntValue(result) ?? 0;

    return count;
  }

  Future<int> updateNote(int noteId, String noteText) async {
    final db = await database;
    return await db.update(
      'casenote', // Corrected table name
      {'note': noteText},
      where: 'notes_id = ?',
      whereArgs: [noteId],
    );
  }

  Future<Map<String, dynamic>> fetchCaseById(int caseId) async {
    final db = await database;
    final result = await db.query('caseinfo', where: 'case_id = ?', whereArgs: [caseId]);
    return result.isNotEmpty ? result.first : {};
  }



  static Future<bool> backupDatabase() async {

    final _saf = SafUtil();
    try {
      String? pickedDirectory = await _saf.openDirectory();
      if (pickedDirectory == null) {
        print("❌ No directory selected!");
        return false;
      }

      String filePath = "$pickedDirectory/backup.csv";

      bool success = await exportToCSV(filePath);
      return success;
    } catch (e) {
      print("❌ Error during backup: $e");
      return false;
    }
  }

  static Future<bool> restoreDatabase() async {

    try {

      bool success = await importFromCSV();
      return success;
    } catch (e) {
      print("❌ Error during restore: $e");
      return false;
    }
  }

  Future<String?> picksafdirectory() async {
    final _safUtil = SafUtil();
    String? selectedDirectory = await _safUtil.openDirectory();
    if (selectedDirectory == null) {
      Fluttertoast.showToast(msg: "No folder selected.");
      return null;
    }
    return selectedDirectory;
  }

  static Future<bool> exportToCSV(String filePath) async {
    final _safStreamPlugin = SafStream();
    final _safUtil = SafUtil();
    String? selectedDirectory = await _safUtil.openDirectory();
    try {
      Database db = await instance.database;
      List<String> tables = ['caseinfo','disposedcase','casemultiplehistory','casenote', 'courtlist','casetype'];

      List<List<String>> csvData = [];
      for (String table in tables) {
        List<Map<String, dynamic>> rows = await db.query(table);
        print("roesssss : $rows");
        if (rows.isNotEmpty) {
          csvData.add([table]); // Table name
          csvData.add(rows.first.keys.toList()); // Column headers
          for (var row in rows) {
            csvData.add(row.values.map((value) => value.toString()).toList());
          }
        }
      }
      String csv = const ListToCsvConverter().convert(csvData);
      Uint8List unitdata = Uint8List.fromList(csv.codeUnits);
      await _safStreamPlugin.writeFileBytes(selectedDirectory??"", "fxdfhjh.csv", "text/csv", unitdata);


      print("✅ Exported Success");
      return true;
    } catch (e) {
      print("❌ Error during export: $e");
      return false;
    }
  }

  static Future<bool> importFromCSV() async {
    final _safUtil = SafUtil();
    String? selectedFilePath = await _safUtil.openFile();

    if (selectedFilePath == null) {
      print("❌ No file selected.");
      return false;
    }

    try {
      final _safStreamPlugin = SafStream();
      Uint8List fileBytes = (await _safStreamPlugin.readFileBytes(selectedFilePath)) as Uint8List;

      String fileContent = utf8.decode(fileBytes);
      List<List<dynamic>> csvData = const CsvToListConverter().convert(fileContent);

      print("CSV Data: $csvData");

      Database db = await instance.database;
      String? currentTable;
      List<String> currentColumns = [];
      List<String> knownTables = ['caseinfo','disposedcase','casemultiplehistory','casenote', 'courtlist','casetype'];

      for (int i = 0; i < csvData.length; i++) {
        List<dynamic> row = csvData[i];

        if (row.isEmpty) continue;

        if (row.length == 1 && knownTables.contains(row[0].toString().trim().toLowerCase())) {
          // Found a new table name
          currentTable = row[0].toString().trim();
          print("👉 Switching to table: $currentTable");

          // Next row should be the column headers
          if (i + 1 < csvData.length) {
            currentColumns = csvData[i + 1].map((e) => e.toString()).toList();
            i++; // Skip to the row after headers
          }
        } else if (currentTable != null && currentColumns.isNotEmpty) {
          // Data row for the current table
          Map<String, dynamic> rowData = {};

          for (int j = 0; j < currentColumns.length && j < row.length; j++) {
            rowData[currentColumns[j]] = row[j];
          }

          await db.insert(currentTable, rowData, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }

      print("✅ Data imported successfully!");
      return true;
    } catch (e) {
      print("❌ Error during import: $e");
      return false;
    }
  }

}
