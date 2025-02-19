import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lawyer_diary/Case%20Details/add_notes.dart';
import 'package:lawyer_diary/Case%20Details/steps_case.dart';
import 'package:path/path.dart';
import '../add_cases.dart';
import '../color.dart';
import '../Database/database_helper.dart';
import 'dispose_cases_add.dart';

final db = DatabaseHelper.instance;

class CaseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> caseItem;
  final int caseId; // Accept caseId
  final bool disposeFlag;  // Add the flag here

  CaseDetailsPage({Key? key, required this.caseItem, required this.caseId, required this.disposeFlag}) : super(key: key);

  @override
  State<CaseDetailsPage> createState() => _CaseDetailsPageState();
}

class _CaseDetailsPageState extends State<CaseDetailsPage> {
  List<Map<String, dynamic>> _notesList = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    List<Map<String, dynamic>> notes = await db.fetchCaseNotes(widget.caseId);
    setState(() {
      _notesList = notes;
    });
  }


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
                        builder: (context) => AddCases(caseItem: widget.caseItem),
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
          future: db.fetchCaseMultipleHistory(widget.caseItem['case_id']), // Fetch history
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              List<Map<String, dynamic>> caseHistory = snapshot.data ?? [];

              return TabBarView(
                children: [
                  _caseTab(context, widget.caseItem),  // Case details
                  _stepsTab(context, caseHistory, widget.caseItem['case_id']),  // Fixed case steps call
                  _notesTab(context, widget.caseItem['case_id'],caseHistory ),  // Notes
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

            Expanded(
              child: caseHistory.isEmpty
                  ? const Center(child: Text("No steps added yet."))
                  : SingleChildScrollView(
                child: Column(
                  children: [
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

                    ...List.generate(caseHistory.length, (index) {
                      var step = caseHistory[index];

                      String? previousDate = index > 0 ? caseHistory[index - 1]['adjourn_date'] : null;
                      String formattedAdjournDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(step['adjourn_date']));
                      String? formattedPreviousDate = previousDate != null
                          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(previousDate))
                          : null;

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(formattedPreviousDate ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(formattedAdjournDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Step", style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        int stepId = step['multiplehistory_id'] ?? 0; // Ensure correct column name
                                        String stepText = step['step'] ?? '';

                                        if (stepId == 0) {
                                          print("Error: stepId is null or missing!"); // Debugging print
                                          return;
                                        }

                                        _editStepDialog(context, stepId, stepText, caseId, (updatedStep) async {
                                          // Fetch updated data from the database
                                          List<Map<String, dynamic>> updatedCaseHistory =
                                          await DatabaseHelper.instance.fetchCaseMultipleHistory(caseId);

                                          setState(() {
                                            caseHistory.clear();
                                            caseHistory.addAll(updatedCaseHistory); // Refresh UI
                                          });
                                        });
                                      },

                                      child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                                    ),
                                  ],
                                ),
                                Text(step['step']),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 70),
                  ],
                ),
              ),
            ),
          ],
        ),

        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: widget.disposeFlag  // Check if the flag is true
                ? ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StepsCase(
                      caseId: widget.caseId,
                      onSave: (refresh) {
                        if (refresh) {
                          setState(() {
                            _fetchNotes();
                          });
                        }
                      },
                    ),
                  ),
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
            )
                : Container(),  // If flag is false, don't show anything
          ),
        )
      ],
    );
  }


  void _editStepDialog(BuildContext context, int stepId, String stepText, int caseId, Function(String) onSave) {
    TextEditingController _controller = TextEditingController(text: stepText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Step"),
          content: TextField(
            controller: _controller,
            maxLines: 5,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String updatedStep = _controller.text;

                // Update in SQLite
                await DatabaseHelper.instance.updateCaseStep(stepId, updatedStep);

                // Update UI (only updated step text)
                onSave(updatedStep);

                // Close Dialog
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _notesTab(BuildContext context, int caseId, List<Map<String, dynamic>> notesList) {
    return Column(
      children: [
        Expanded(
          child: _notesList.isEmpty
              ? const Center(child: Text("No notes available"))
              : ListView.builder(
            itemCount: _notesList.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 1,
                child: Container(
                  height: 60,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    title: Text(
                      _notesList[index]['note'] ?? "No content", // Null check here
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          String currentNote = _notesList[index]["note_text"] ?? ''; // Null check here
                          // Proceed with edit
                        } else if (value == 'delete') {
                          bool confirmDelete = await showDeleteConfirmationDialog(context);
                          if (confirmDelete) {
                            await DatabaseHelper.instance.deleteNote(_notesList[index]["notes_id"]);
                            setState(() {
                              _notesList.removeAt(index);
                            });
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: widget.disposeFlag
              ? ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNotes(
                    caseId: widget.caseId,
                    onSave: (refresh) {
                      if (refresh) {
                        setState(() {
                          _fetchNotes();
                        });
                      }
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              child: Text("Add Note", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          )
              : const SizedBox.shrink(), // This prevents empty space when the button is hidden
        )
      ],
    );
  }

  Widget _caseTab(BuildContext context, Map<String, dynamic> caseItem) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(caseItem['case_title'] ?? 'Unknown Case Title'), // Null check here
          _detailRow("Court", caseItem['court_name'] ?? 'Unknown Court'), // Null check here
          _detailRow("Case No./Year", "${caseItem['case_number'] ?? 'N/A'}/${caseItem['case_year'] ?? 'N/A'}"), // Null check here
          _detailRow("Type", caseItem['case_type'] ?? 'Unknown Type'), // Null check here
          _detailRow("Filed U/sec", caseItem['section'] ?? 'Unknown Section'), // Null check here
          const SizedBox(height: 16),
          _sectionTitle("Party"),
          _detailRow("Name", caseItem['party_name'] ?? 'Unknown Party'), // Null check here
          _detailRow("Contact", caseItem['contact'] ?? 'Unknown Contact'), // Null check here
          const SizedBox(height: 16),
          _sectionTitle("Adverse Party"),
          _detailRow("Name", caseItem['adverse_advocate_name'] ?? 'Unknown Adverse Party'), // Null check here
          _detailRow("Contact", caseItem['adverse_advocate_contact'] ?? 'Unknown Contact'), // Null check here
          const SizedBox(height: 30),
          Center(
            child: widget.disposeFlag  // Check the flag here
                ? ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DisposeCases(caseId: widget.caseItem['case_id'] ?? 0)),
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
            )
                : Container(),  // If flag is false, don't show anything
            // If flag is false, don't show anything
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

void _editStepDialog(BuildContext context, int stepId, String stepText, int caseId, Function(String) onSave) {
  TextEditingController _controller = TextEditingController(text: stepText);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Edit Step"),
        content: TextField(
          controller: _controller,
          maxLines: 5,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String updatedStep = _controller.text;

              // Update in SQLite
              await DatabaseHelper.instance.updateCaseStep(stepId, updatedStep);

              // Update UI (only updated step text)
              onSave(updatedStep);

              // Close Dialog
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Cancel deletion
            },
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirm deletion
            },
            child: Text("Yes"),
          ),
        ],
      );
    },
  ) ?? false;
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
