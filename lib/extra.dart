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

























// import 'dart:developer';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:intl/intl.dart';
//
// import 'DATABASE/database_helper.dart';
// import 'color.dart';
//
// class BackupScreen extends StatefulWidget {
//   const BackupScreen({super.key});
//
//   @override
//   State<BackupScreen> createState() => _BackupScreenState();
// }
//
// class _BackupScreenState extends State<BackupScreen> {
//   final GoogleDriveService _googleDriveService = GoogleDriveService();
//
//   @override
//   void initState() {
//     checksignin();
//     // TODO: implement initState
//     super.initState();
//   }
//
//   bool issignin = false;
//   String signinuseremail = "";
//
//   checksignin() async {
//     issignin = await _googleDriveService.googleSignIn.isSignedIn();
//     if (issignin)
//       signinuseremail = await _googleDriveService.Signedemail() ?? '';
//     print(_googleDriveService.Signedemail() ?? '');
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: themecolor,
//       appBar: AppBar(
//         title: Text(
//           "Backup And Restore",
//           style: TextStyle(color: themecolor, fontWeight: FontWeight.w500),
//         ),
//         backgroundColor: themecolor,
//         iconTheme: IconThemeData(color: themecolor),
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(15.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Card(
//                 elevation: 2,
//                 color: Colors.white,
//                 child: Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Storage Backup & Restore",
//                           style: TextStyle(
//                               color: themecolor,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 20),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                             "Back up your Accounts and Ledger to your Internal storage. You can restore it from Backup file."),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Last Backup: ${SharedPref.get(prefKey: PrefKey.lastbackup) ?? "No Backup yet"}",
//                           style: TextStyle(
//                               fontSize: 15, fontWeight: FontWeight.w500),
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         InkWell(
//                           onTap: () {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: const Text("Backup Cash Book !!!"),
//                                   content: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Text(
//                                         '''
// Follow the steps
//
// Cashbook Local Backup
// 1. Click on 'Backup' Button.
// 2. Select/Create the specific folder on local storage to backup. (older one is 'cashbook_backup' or create a new one)
// 3. Allow the Folder Permission.
// 4. That's it. Backup Done.
// ''',
//                                         style: TextStyle(
//                                             color: Colors.black,
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w400),
//                                       ),
//                                     ],
//                                   ),
//                                   actions: <Widget>[
//                                     TextButton(
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                       },
//                                       child: const Text("Cancel"),
//                                     ),
//                                     TextButton(
//                                       onPressed: () async {
//                                         Navigator.of(context).pop();
//                                         EasyLoading.show(status: "Loading.");
//                                         await DatabaseHelper().exportClientsToCsv();
//                                         EasyLoading.dismiss();
//                                         setState(() {});
//                                       },
//                                       child: const Text("Backup"),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           },
//                           child: Container(
//                             height: 40,
//                             decoration: BoxDecoration(
//                                 color: themecolor,
//                                 borderRadius: BorderRadius.circular(8)),
//                             child: Center(
//                                 child: Text(
//                                   "Backup",
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold),
//                                 )),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         InkWell(
//                           onTap: () {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: const Text("Restore Cash Book !!!"),
//                                   content: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Text(
//                                         '''If you restore to previous version then current latest cash book entry will not more available after restoring the backup.
//
// Are you sure want to restore the data?''',
//                                       ),
//                                       SizedBox(
//                                         height: 15,
//                                       ),
//                                       const Text(
//                                         '''Follow the steps
//
// Cashbook Local Restore
// 1. Make sure your existing entries will be removed.
// 2. Click on 'Restore' Button.
// 3. Select specific folder to restore.
// 4. Allow the Folder Permission.
// 5. That's it. Restore Done.
// ''',
//                                         style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w400,
//                                             color: Colors.black),
//                                       ),
//                                     ],
//                                   ),
//                                   actions: <Widget>[
//                                     TextButton(
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                       },
//                                       child: const Text("Cancel"),
//                                     ),
//                                     TextButton(
//                                       onPressed: () async {
//                                         final csvImporter = CsvAutoImporter();
//                                         String? path = await csvImporter
//                                             .picksafdirectory();
//                                         if (path != null)
//                                           showDialog(
//                                             context: context,
//                                             builder: (BuildContext context) {
//                                               return AlertDialog(
//                                                 title: const Text("Alert"),
//                                                 content: const Text(
//                                                   "Are you sure you wan't to restore data?",
//                                                 ),
//                                                 actions: <Widget>[
//                                                   TextButton(
//                                                     onPressed: () {
//                                                       Navigator.of(context)
//                                                           .pop();
//                                                     },
//                                                     child: const Text(
//                                                         "Cancel"),
//                                                   ),
//                                                   TextButton(
//                                                     onPressed: () async {
//                                                       Navigator.of(context)
//                                                           .pop();
//                                                       Navigator.pop(context);
//                                                       await csvImporter.importCsvFiles(path);
//                                                     },
//                                                     child:
//                                                     const Text("Restore"),
//                                                   ),
//                                                 ],
//                                               );
//                                             },
//                                           );
//
//
//                                       },
//                                       child: const Text("Restore"),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           },
//                           child: Container(
//                             height: 40,
//                             decoration: BoxDecoration(
//                                 color: themecolor,
//                                 borderRadius: BorderRadius.circular(8)),
//                             child: Center(
//                                 child: Text(
//                                   "Restore",
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold),
//                                 )),
//                           ),
//                         ),
//                       ]),
//                 ),
//               ),
//               SizedBox(
//                 height: 15,
//               ),
//               Card(
//                 elevation: 2,
//                 color: Colors.white,
//                 child: Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Cloud Backup & Restore",
//                           style: TextStyle(
//                               color: themecolor,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 20),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                             "Back up your Accounts and Ledger to your Google Account's storage. You can restore them on a new phone after you download Cashbook on it."),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           "Last Backup: ${SharedPref.get(prefKey: PrefKey.cloudlastbackup) ?? "No Backup yet"}",
//                           style: TextStyle(
//                               fontSize: 15, fontWeight: FontWeight.w500),
//                         ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         issignin
//                             ? Column(
//                           children: [
//                             InkWell(
//                               onTap: () async {
//                                 await _googleDriveService
//                                     .changeGoogleAccount();
//                                 checksignin();
//                                 setState(() {});
//                               },
//                               child: Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Google Account",
//                                         style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500),
//                                       ),
//                                       Text(
//                                         "${signinuseremail}",
//                                         style: TextStyle(
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.w400),
//                                       ),
//                                     ],
//                                   ),
//                                   Icon(
//                                     Icons.arrow_forward_ios,
//                                     color: Colors.grey,
//                                     size: 20,
//                                   )
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             InkWell(
//                               onTap: () async {
//                                 await Cloudbackup()
//                                     .cloudexportClientsToCsv();
//                                 setState(() {});
//                               },
//                               child: Container(
//                                 height: 40,
//                                 decoration: BoxDecoration(
//                                     color: themecolor,
//                                     borderRadius:
//                                     BorderRadius.circular(8)),
//                                 child: Center(
//                                     child: Text(
//                                       "Cloud Backup",
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold),
//                                     )),
//                               ),
//                             ),
//                             SizedBox(
//                               height: 15,
//                             ),
//                             InkWell(
//                               onTap: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return AlertDialog(
//                                       title:
//                                       const Text("Cloud Restore !!!"),
//                                       content: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           const Text(
//                                             '''If you restore to previous version then current latest cash book entry will not more available after restoring the backup.
//
// Are you sure want to restore the data?''',
//                                           ),
//                                         ],
//                                       ),
//                                       actions: <Widget>[
//                                         TextButton(
//                                           onPressed: () {
//                                             Navigator.of(context).pop();
//                                           },
//                                           child: const Text("Cancel"),
//                                         ),
//                                         TextButton(
//                                           onPressed: () async {
//                                             EasyLoading.show(
//                                                 status:
//                                                 "Featching Backup Files...");
//                                             await Cloudbackup()
//                                                 .cloudimportCsvFiles(
//                                                 context);
//                                           },
//                                           child: const Text("Restore"),
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 );
//                               },
//                               child: Container(
//                                 height: 40,
//                                 decoration: BoxDecoration(
//                                     color: themecolor,
//                                     borderRadius:
//                                     BorderRadius.circular(8)),
//                                 child: Center(
//                                     child: Text(
//                                       "Cloud Restore",
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold),
//                                     )),
//                               ),
//                             ),
//                           ],
//                         )
//                             : Container(
//                           margin: EdgeInsets.only(bottom: 5),
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(
//                                   color: Colors.grey, width: 2)),
//                           height: 50,
//                           child: InkWell(
//                             onTap: () async {
//                               await _googleDriveService
//                                   .changeGoogleAccount();
//                               checksignin();
//                               setState(() {});
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   "Connect",
//                                   style: TextStyle(
//                                       color: Colors.black54,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w500),
//                                 ),
//                                 SizedBox(
//                                   width: 5,
//                                 ),
//                                 Image.asset(
//                                     height: 30,
//                                     "assets/image/imagesdrive.png"),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ]),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
