import 'package:flutter/material.dart';
import '../color.dart';
import '../Database/database_helper.dart';

class AddNotes extends StatefulWidget {
  final int caseId; // Accept caseId

  const AddNotes({super.key, required this.caseId});

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  final TextEditingController _disposeNoteController = TextEditingController();
  DatabaseHelper db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _saveCase() async {
    String noteText = _disposeNoteController.text.trim();
    if (noteText.isNotEmpty) {
      await db.saveCaseNote(widget.caseId, noteText);
      _disposeNoteController.clear();
      print(noteText);
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
            const Text("Write Notes For This Case", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 10),
            TextField(
              controller: _disposeNoteController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter details...",
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: themecolor),
                  onPressed: _saveCase, // Save function
                  child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: themecolor),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
