import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lawyer_diary/Case%20Details/add_notes.dart';
import 'package:lawyer_diary/Case%20Details/steps_case.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
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
      _notesList = List<Map<String, dynamic>>.from(notes); // Make a mutable copy
    });
  }

  void _shareCaseDetails() {
    String caseDetails = """
📌 Case Details
-----------------------
🔹 Case Title: ${widget.caseItem['case_title'] ?? 'N/A'}
🔹 Court Name: ${widget.caseItem['court_name'] ?? 'N/A'}
🔹 Case Number/Year: ${widget.caseItem['case_number'] ?? 'N/A'} / ${widget.caseItem['case_year'] ?? 'N/A'}
🔹 Case Type: ${widget.caseItem['case_type'] ?? 'N/A'}
🔹 Section: ${widget.caseItem['section'] ?? 'N/A'}

👥 Party Details
-----------------------
🔸 Party Name: ${widget.caseItem['party_name'] ?? 'N/A'}
🔸 Contact: ${widget.caseItem['contact'] ?? 'N/A'}

⚖️ Adverse Party
-----------------------
🔸 Name: ${widget.caseItem['adverse_advocate_name'] ?? 'N/A'}
🔸 Contact: ${widget.caseItem['adverse_advocate_contact'] ?? 'N/A'}

📅 Last Adjourn Date: ${widget.caseItem['last_adjourn_date'] ?? 'N/A'}
📌 Disposed: ${widget.caseItem['is_disposed'] == 1 ? 'Yes' : 'No'}
""";

    Share.share(caseDetails);
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this case? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false;
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
                  onPressed: () {
                    _shareCaseDetails();
                  },
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () async {
                    bool confirmDelete = await _showDeleteConfirmationDialog(context);
                    if (confirmDelete) {
                      await db.deleteCase(widget.caseId); // Delete from database
                      Navigator.popUntil(context, (route) => route.isFirst); // Go back to Home
                    }
                  },
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
              List<Map<String, dynamic>> caseHistory = List<Map<String, dynamic>>.from(snapshot.data ?? []);

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
    // ✅ Ensure the list is in insertion order (oldest first)
    caseHistory = List<Map<String, dynamic>>.from(caseHistory.reversed);

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

                      String? previousDate = index > 0
                          ? caseHistory[index - 1]['adjourn_date']
                          : null;

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
                                        int stepId = step['multiplehistory_id'] ?? 0;
                                        String stepText = step['step'] ?? '';

                                        if (stepId == 0) return;

                                        _editStepDialog(context, stepId, stepText, caseId, (updatedStep) async {
                                          List<Map<String, dynamic>> updatedCaseHistory =
                                          await DatabaseHelper.instance.fetchCaseMultipleHistory(caseId);
                                          setState(() {
                                            caseHistory.clear();
                                            caseHistory.addAll(updatedCaseHistory.reversed);
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

        // Add Step Button
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: widget.disposeFlag
                ? ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StepsCase(
                      caseId: widget.caseId,
                      onSave: (refresh) async {
                        if (refresh) {
                          List<Map<String, dynamic>> updatedCaseHistory =
                          await DatabaseHelper.instance.fetchCaseMultipleHistory(widget.caseId);
                          setState(() {
                            caseHistory = List<Map<String, dynamic>>.from(updatedCaseHistory.reversed);
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
                : Container(),
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
                          String currentNote = _notesList[index]["note"] ?? ''; // Fetch current note text
                          int noteId = _notesList[index]["notes_id"]; // Fetch note ID

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddNotes(
                                caseId: widget.caseId,
                                noteId: noteId, // Pass noteId for editing
                                existingNote: currentNote, // Pass existing note text
                                onSave: (refresh) {
                                  if (refresh) {
                                    setState(() {
                                      _fetchNotes(); // Refresh notes list
                                    });
                                  }
                                },
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          bool confirmDelete = await showDeleteConfirmationDialog(context);
                          if (confirmDelete) {
                            await DatabaseHelper.instance.deleteNote(_notesList[index]["notes_id"]);
                            setState(() {
                              _notesList.removeAt(index);
                            });
                            setState(() {

                            });
                            print(_notesList);
                            print("666666666666666666666666666666666666666");
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
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(caseItem['case_title'] ?? 'Unknown Case Title'),
              _detailRow("Court", caseItem['court_name'] ?? 'Unknown Court'),
              _detailRow("Case No./Year", "${caseItem['case_number'] ?? 'N/A'}/${caseItem['case_year'] ?? 'N/A'}"),
              _detailRow("Type", caseItem['case_type'] ?? 'Unknown Type'),
              _detailRow("Filed U/sec", caseItem['section'] ?? 'Unknown Section'),
              const SizedBox(height: 16),
              _sectionTitle("Party"),
              _detailRow("Name", caseItem['party_name'] ?? 'Unknown Party'),
              _detailRow("Contact", caseItem['contact'] ?? 'Unknown Contact'),
              const SizedBox(height: 16),
              _sectionTitle("Adverse Party"),
              _detailRow("Name", caseItem['adverse_advocate_name'] ?? 'Unknown Adverse Party'),
              _detailRow("Contact", caseItem['adverse_advocate_contact'] ?? 'Unknown Contact'),
              const SizedBox(height: 30),
              Center(
                child: widget.disposeFlag
                    ? ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DisposeCases(caseId: caseItem['case_id'] ?? 0),
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
                    padding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    child: Text("Dispose",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                )
                    : Container(),
              ),
            ],
          ),
        ),
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
