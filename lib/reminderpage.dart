import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Database/database_helper.dart';
import '../Case Details/case_details.dart';
import '../color.dart';

class ReminderPage extends StatefulWidget {
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  List<Map<String, dynamic>> _cases = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
    debugDatabase();
  }

  Future<void> _loadReminders() async {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print("Today's Date: $todayDate");

    final List<Map<String, dynamic>> caseList = await DatabaseHelper.instance.getCasesByAdjournDate(todayDate);

    print("Fetched Cases: ${caseList.length}");
    for (var caseItem in caseList) {
      print(caseItem); // Print each case to see if data is correct
    }

    setState(() {
      _cases = caseList;
    });
  }

  void debugDatabase() async {
    List<Map<String, dynamic>> allCases = await DatabaseHelper.instance.checkAllCases();
    for (var caseItem in allCases) {
      print("========================================");
      print(caseItem);
      print("Case ID: ${caseItem['case_id']}, Adjourn Date: ${caseItem['adjourn_date']}");
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "No Date";

    try {
      DateTime date = DateTime.parse(dateString); // Convert string to DateTime
      return DateFormat('dd/MM/yyyy').format(date); // Format to dd/MM/yyyy
    } catch (e) {
      print("Date parsing error: $e");
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Reminders", style: TextStyle(color: Colors.white)),
        backgroundColor: themecolor,
        foregroundColor: Colors.white,
      ),
      body: _cases.isEmpty
          ? Center(child: Text("No cases for today"))
          : ListView.builder(
        itemCount: _cases.length,
        itemBuilder: (context, index) {
          final caseItem = _cases[index];
          print(caseItem); // Print each case to see if it is populated
          return Card(
            margin: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CaseDetailsPage(
                      caseItem: caseItem,
                      caseId: caseItem['case_id'],
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleRow(caseItem),
                    const SizedBox(height: 8),
                    _detailRow(Icons.confirmation_number, "Case ID", caseItem['case_id'].toString()),
                    _detailRow(Icons.article, "Case Title", caseItem['case_title'] ?? "No Title"), // Handle null case title
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _titleRow(Map<String, dynamic> caseItem) {
    String formattedDate = formatDate(caseItem['adjourn_date']);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Adjourn Date: $formattedDate", // Added "Adjourn Date: " before the date
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Icon(Icons.chevron_right),
      ],
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
