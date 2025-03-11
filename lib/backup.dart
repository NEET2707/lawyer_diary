import 'package:flutter/material.dart';

import 'Database/database_helper.dart';
import 'color.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  bool issignin = false;
  String signinuseremail = "";


  void backupDatabase() async {
    bool success = await DatabaseHelper.backupDatabase();
    setState(() {
      var storageBackupStatus = success ? "Last Backup: Successful" : "Last Backup: Failed";
    });
  }

  void restoreDatabase() async {
    bool success = await DatabaseHelper.restoreDatabase();
    setState(() {
      var storageBackupStatus = success ? "Restore Successful!" : "Restore Failed!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Backup And Restore",
          style: TextStyle(color: themecolor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: themecolor),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Storage Backup & Restore",
                          style: TextStyle(
                              color: themecolor,
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            "Back up your Accounts and Ledger to your Internal storage. You can restore it from Backup file."),
                        SizedBox(
                          height: 10,
                        ),
                        // Text(
                        //   "Last Backup: ${SharedPref.get(prefKey: PrefKey.lastbackup) ?? "No Backup yet"}",
                        //   style: TextStyle(
                        //       fontSize: 15, fontWeight: FontWeight.w500),
                        // ),
                        SizedBox(
                          height: 15,
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Backup Cash Book !!!"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '''
Follow the steps
        
Cashbook Local Backup
1. Click on 'Backup' Button.
2. Select/Create the specific folder on local storage to backup. (older one is 'cashbook_backup' or create a new one)
3. Allow the Folder Permission.
4. That's it. Backup Done. 
''',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: backupDatabase,
                                      child: const Text("Backup"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: themecolor,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                                child: Text(
                                  "Backup",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Restore Cash Book !!!"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '''If you restore to previous version then current latest cash book entry will not more available after restoring the backup.
        
Are you sure want to restore the data?''',
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      const Text(
                                        '''Follow the steps
                                              Cashbook Local Restore
                                              1. Make sure your existing entries will be removed.
                                              2. Click on 'Restore' Button.
                                              3. Select specific folder to restore.
                                              4. Allow the Folder Permission.
                                              5. That's it. Restore Done. 
                                              ''',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: restoreDatabase,
                                      child: const Text("Restore"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: themecolor,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                                child: Text(
                                  "Restore",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ),
                      ]),
                ),
              ),
              SizedBox(
                height: 15,
              ),
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
//                         // Text(
//                         //   "Last Backup: ${SharedPref.get(prefKey: PrefKey.cloudlastbackup) ?? "No Backup yet"}",
//                         //   style: TextStyle(
//                         //       fontSize: 15, fontWeight: FontWeight.w500),
//                         // ),
//                         SizedBox(
//                           height: 15,
//                         ),
//                         issignin
//                             ? Column(
//                           children: [
//                             InkWell(
//                               onTap: () async {
//
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
//
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
//
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
//
//                             },
//                             // child: FittedBox(
//                             //   fit: BoxFit.scaleDown,
//                             //   child: Row(
//                             //     mainAxisAlignment: MainAxisAlignment.center,
//                             //     children: [
//                             //       Text(
//                             //         "Connect",
//                             //         style: TextStyle(
//                             //             color: Colors.black54,
//                             //             fontSize: 18,
//                             //             fontWeight: FontWeight.w500),
//                             //       ),
//                             //       SizedBox(
//                             //         width: 5,
//                             //       ),
//                             //       Image.asset(
//                             //         "assets/image/imagesdrive.png",
//                             //         height: 30,
//                             //       ),
//                             //     ],
//                             //   ),
//                             // ),
//                           ),
//                         ),
//                       ]),
//                 ),
//               ),
            ],
          ),
        ),
      ),
    );
  }
}
