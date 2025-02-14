import 'package:flutter/material.dart';
import 'package:lawyer_diary/add_cases.dart';
import 'cases.dart';
import 'color.dart';
import 'disoposed_cases.dart';
import 'notification.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final Color teakWood = Color(0xFFC19A6B); // Teak Wood

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themecolor, // Use the variable
        title: const Text("Lawyer Diary" , style: TextStyle(color:Colors.white),),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.notification_add, color: Colors.white,),
            ),
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildHomeCard(icon: Icons.manage_search_sharp,
            title: "Cases",
            subtitle: "Clik to View All Cases",
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Cases()),
              );
            }
          ),

          _buildHomeCard(icon: Icons.bookmark_remove_sharp,
              title: "Disoposed Cases",
              subtitle: "Clik to View All Disoposed Cases List",
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisposedCases()),
                );
              }
          ),
          _buildHomeCard(icon: Icons.add_box_outlined,
              title: "Add Cases",
              subtitle: "Clik to Add Cases Details",
              onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddCases()),
                  );
              }
          ),

          _buildHomeCard(icon: Icons.maps_home_work_outlined,
              title: "Manage Court",
              subtitle: "Clik to Manage Court List",
              onTap: (){}
          ),

          _buildHomeCard(icon: Icons.cases_rounded,
              title: "Manage CaseType",
              subtitle: "Clik to Manage CaseType List",
              onTap: (){}
          ),

          _buildHomeCard(icon: Icons.punch_clock,
              title: "Reminder Cases",
              subtitle: "Clik to View All Reminder Cases",
              onTap: (){}
          ),

          _buildHomeCard(icon: Icons.restore,
              title: "Lawyer Diary Backup",
              subtitle: "Back Up/ Restore Your Case Entries",
              onTap: (){}
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themecolor,
        shape: CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCases()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),    );
  }
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
          : Icon(icon, size: 40, color: Colors.blue.shade900), // Default icon
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 14   )),
      onTap: onTap,
      trailing: trailingWidget, // Display the trailing widget here
    ),
  );
}