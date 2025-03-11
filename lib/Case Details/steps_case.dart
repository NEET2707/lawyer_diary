import 'package:flutter/material.dart';
import 'package:lawyer_diary/color.dart';
import '../Database/database_helper.dart';

class StepsCase extends StatefulWidget {
  final int caseId;
  final Function(bool) onSave; // Callback function

  const StepsCase({super.key, required this.caseId, required this.onSave});

  @override
  State<StepsCase> createState() => _StepsCaseState();
}

class _StepsCaseState extends State<StepsCase> {
  final TextEditingController _disposeNoteController = TextEditingController();
  DateTime? _selectedDate;
  DatabaseHelper db = DatabaseHelper.instance;
  List<Map<String, dynamic>> _caseHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchCaseHistory(); // Fetch saved steps when screen opens
  }

  // Fetch case history from database
  void _fetchCaseHistory() async {
    List<Map<String, dynamic>> history = await db.fetchCaseMultipleHistory(widget.caseId);
    setState(() {
      _caseHistory = history;
    });
  }

  // Pick Date Function
  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Save Case Step
  void _saveCase() async {
    if (_disposeNoteController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter step details and pick a date.")),
      );
      return;
    }

    Map<String, dynamic> caseStep = {
      'case_id': widget.caseId,
      'step': _disposeNoteController.text,
      'adjourn_date': _selectedDate!.toIso8601String(),
      'previous_date': DateTime.now().toIso8601String(),
    };

    try {
      await db.saveCaseMultipleHistory(caseStep);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Step saved successfully!")),
      );

      _disposeNoteController.clear();
      _selectedDate = null;

      _fetchCaseHistory(); // Refresh case history after saving

      widget.onSave(true); // Trigger the callback to refresh the parent page

      Navigator.pop(context, true); // Pass `true` to indicate refresh

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: themecolor,
        title: const Text("Case Steps", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Steps:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(width: 40),
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    controller: _disposeNoteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter details...",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text("Adjourn Dt.:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: themecolor),
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: Text(
                    _selectedDate != null
                        ? "${_selectedDate!.day.toString().padLeft(2, '0')}/"
                        "${_selectedDate!.month.toString().padLeft(2, '0')}/"
                        "${_selectedDate!.year}"
                        : "Pick a date",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themecolor,
                  ),
                  onPressed: _saveCase, // Save function
                  child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themecolor,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
