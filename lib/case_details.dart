import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lawyer_diary/steps_case.dart';
import 'package:path/path.dart';
import 'add_cases.dart';
import 'color.dart';
import 'database_helper.dart';
import 'dispose_cases_add.dart';

final db = DatabaseHelper.instance;

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
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: db.fetchCaseMultipleHistory(caseItem['case_id']), // Fetch history
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              List<Map<String, dynamic>> caseHistory = snapshot.data ?? [];

              return TabBarView(
                children: [
                  _caseTab(context, caseItem),  // Case details
                  _stepsTab(context, caseHistory, caseItem['case_id']),  // Fixed case steps call
                  _notesTab(context),  // Notes
                ],
              );
            }
          },
        ),

      ),
    );
  }


  Widget _stepsTab(BuildContext context, List<Map<String, dynamic>> caseHistory, int caseId) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Saved Case Steps:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Expanded ListView for scrolling
            Expanded(
              child: caseHistory.isEmpty
                  ? const Center(child: Text("No steps added yet."))
                  : SingleChildScrollView(
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.blue.shade800,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Previous Dt.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("Adjourn Dt.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),

                    // Case History Steps
                    ...List.generate(caseHistory.length, (index) {
                      var step = caseHistory[index];

                      // Get previous date (if available)
                      String? previousDate = index > 0 ? caseHistory[index - 1]['adjourn_date'] : null;

                      // Format dates
                      String formattedAdjournDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(step['adjourn_date']));
                      String? formattedPreviousDate = previousDate != null
                          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(previousDate))
                          : null;

                      return Column(
                        children: [
                          // Date Row
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formattedPreviousDate ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(formattedAdjournDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),

                          // Step Details
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Step", style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 5),
                                    Icon(Icons.edit, size: 16, color: Colors.blue), // Edit icon
                                  ],
                                ),
                                Text(step['step']),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 70), // Extra space to prevent list from being covered
                  ],
                ),
              ),
            ),
          ],
        ),

        // Fixed Positioned Button
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StepsCase(caseId: caseId)),
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
                child: Text("Add Step", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _notesTab(BuildContext context) {
    return Center(
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
          child: Text("Notes", style: TextStyle(fontSize: 16, color: Colors.white)),
        ),
      ),
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
