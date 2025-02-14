import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'add_cases.dart';
import 'color.dart';
import 'dispose_cases_add.dart';

class CaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> caseItem;

  const CaseDetailsPage({Key? key, required this.caseItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text("Case Details", style: TextStyle(color: Colors.white)),
          backgroundColor: themecolor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min, // Prevents extra width usage
              children: [
                IconButton(
                  icon: const Icon(Icons.question_mark, color: Colors.white),
                  onPressed: () {
                    _showTipsDialog(context);
                  },
                  visualDensity: VisualDensity.compact, // Removes extra padding
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCases(caseItem: caseItem),
                      ),
                    );
                  },
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ],

          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "CASE"),
              Tab(text: "STEPS"),
              Tab(text: "NOTES"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _caseTab(context ,caseItem),  // Case details
            _stepsTab(),         // Case steps
            _notesTab(),         // Notes
          ],
        ),
      ),
    );
  }


  Widget _stepsTab() {
    return Center(
      child: Text("Case Steps will be shown here", style: TextStyle(fontSize: 16)),
    );
  }

  Widget _notesTab() {
    return Center(
      child: Text("Notes for this case will be displayed here", style: TextStyle(fontSize: 16)),
    );
  }

  Widget _caseTab(BuildContext context, Map<String, dynamic> caseItem) { // Pass BuildContext
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(caseItem['case_title']),
          _detailRow("Court", caseItem['court_name']),
          _detailRow("Case No./Year", "${caseItem['case_number']}/${caseItem['case_year']}"),
          _detailRow("Type", caseItem['case_type']),
          _detailRow("Filed U/sec", caseItem['section']),
          const SizedBox(height: 16),
          _sectionTitle("Party"),
          _detailRow("Name", caseItem['party_name']),
          _detailRow("Contact", caseItem['contact']),
          const SizedBox(height: 16),
          _sectionTitle("Adverse Party"),
          _detailRow("Name", caseItem['adverse_advocate_name']),
          _detailRow("Contact", caseItem['adverse_advocate_contact']),
          const SizedBox(height: 30),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context, // Now using the correct BuildContext
                  MaterialPageRoute(builder: (context) => DisposeCases(caseId: caseItem['case_id'])),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                child: Text("Dispose", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
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

Widget _sectionTitle(String title) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    color: Colors.blue[100],
    child: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  );
}

void _showTipsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Tips"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("**Press ✏️ Icon on navbar to Edit Case Details."),
              Text("**Press 🗑️ Icon on navbar to Delete Case."),
              Text("**Press ➕ Steps to Add Adjourn Date and Steps Case."),
              Text("   (View all Steps on steps segment at bottom)"),
              Text("**Press 🗑️ Dispose to Dispose Case."),
              Text("**Press ➕ Notes to Add Notes."),
              Text("   (View all Notes on Notes segment at bottom"),
              Text("   and long Press on Particular Notes"),
              Text("   to Delete and Edit Notes)"),
              Text("**Press 🔗 Icon on navbar to Share Case Details"),
              Text("   with Any Preferred Sharing Application."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}
