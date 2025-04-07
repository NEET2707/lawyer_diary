import 'package:flutter/material.dart';
import 'package:lawyer_diary/reminderpage.dart';

import 'Database/database_helper.dart';
import 'add_cases.dart';
import 'backup.dart';
import 'cases.dart';
import 'color.dart';
import 'disoposed_cases.dart';
import 'manage_case_type.dart';
import 'manage_court.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int totalcase = 0;
  int totaldispose = 0;
  int count = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTotalRecords();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchTotalRecords(); // Refresh counts when page is revisited
  }

  Future<void> _loadDisposeCount() async {
    List<Map<String, dynamic>> disposed = await DatabaseHelper.instance
        .getDisposedCases();
    setState(() {
      totaldispose = disposed.length;
    });
  }

  Future<void> fetchTotalRecords() async {
    int cases = await DatabaseHelper.instance.getCountExcludingDisposedCases();
    int disposed = await DatabaseHelper.instance.countDisposedCases();
    int reminders = await DatabaseHelper.instance
        .countRecordsWithTodayAdjournDate();

    setState(() {
      totalcase = cases;
      totaldispose = disposed;
      count = reminders;
    });

    print('Total cases: $totalcase');
    print('Disposed cases: $totaldispose');
    print('Today’s reminders: $count');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themecolor, // Use the variable
        title: const Text(
          "Settings", style: TextStyle(color: Colors.white),),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchTotalRecords(); // Correct function call
        }, child: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          // _buildHomeCard(icon: Icons.manage_search_sharp,
          //   title: "Cases",
          //   subtitle: "Clik to View All Cases",
          //   onTap: (){
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => Cases()),
          //     );
          //   }
          // ),


          Card(
            color: Colors.white,
            elevation: 1,
            margin: EdgeInsets.only(bottom: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              leading: Icon(Icons.manage_search_sharp, size: 40,
                  color: Colors.blue.shade900),
              title: Text("Cases",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(
                  "Clik to View All Cases", style: TextStyle(fontSize: 14)),
              onTap: () async {
                var reesult = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Cases()),
                );
                if (reesult == true) {
                  fetchTotalRecords();
                }
              },
              trailing: CircleAvatar(
                backgroundColor: Colors.blue.shade900,
                child: Text(
                  totalcase.toString(), style: TextStyle(color: Colors.white),),
              ), // Display the trailing widget here
            ),
          ),

          _buildHomeCard(icon: Icons.bookmark_remove_sharp,
              title: "Disoposed Cases",
              subtitle: "Clik to View All Disoposed Cases List",
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DisposedCases()),
                );

                if (result == true) {
                  _loadDisposeCount(); // Recalculate totaldispose
                }
              },
              trailingWidget: CircleAvatar(
                  backgroundColor: Colors.blue.shade900,
                  child: Text(totaldispose.toString(),
                    style: TextStyle(color: Colors.white),))
          ),
          _buildHomeCard(icon: Icons.add_box_outlined,
              title: "Add Cases",
              subtitle: "Clik to Add Cases Details",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCases()),
                ).then((result) {
                  if (result == true) {
                    fetchTotalRecords(); // Only refresh if a case was actually added
                  }
                });
              }
          ),

          _buildHomeCard(icon: Icons.maps_home_work_outlined,
              title: "Manage Court",
              subtitle: "Clik to Manage Court List",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageCourt()),
                );
              }
          ),

          _buildHomeCard(icon: Icons.cases_rounded,
              title: "Manage CaseType",
              subtitle: "Clik to Manage CaseType List",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageCaseType()),
                );
              }),

          _buildHomeCard(icon: Icons.punch_clock,
            title: "Reminder Cases",
            subtitle: "Clik to View All Reminder Cases",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReminderPage()),
              );
            },
            trailingWidget: CircleAvatar(
              backgroundColor: Colors.blue.shade900,
              child: Text(
                count.toString(), style: TextStyle(color: Colors.white),),
            ),
          ),

          _buildHomeCard(icon: Icons.restore,
              title: "Lawyer Diary Backup",
              subtitle: "Back Up/ Restore Your Case Entries",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BackupScreen()),
                );
              }),
        ],
      ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: themecolor,
      //   shape: CircleBorder(),
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => AddCases()),
      //     ).then((result) {
      //       if (result == true) {
      //         fetchTotalRecords(); // Only refresh if a case was actually added
      //       }
      //     });
      //   },
      //   child: Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  Widget _buildHomeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    void Function()? onTap,
    Widget?
    trailingWidget,
    IconData? leadingIcon,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        leading: leadingIcon != null
            ? Icon(leadingIcon,
            size: 40, color: Colors.black54)
            : Icon(icon, size: 40, color: Colors.blue.shade900),
        // Default icon
        title: Text(
            title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 14)),
        onTap: onTap,
        trailing: trailingWidget,
      ),
    );
  }
}
