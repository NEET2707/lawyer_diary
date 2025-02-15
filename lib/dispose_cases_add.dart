import 'package:flutter/material.dart';
import 'package:lawyer_diary/color.dart';
import 'package:lawyer_diary/home.dart';
import 'database_helper.dart';

import 'extra.dart';

class DisposeCases extends StatefulWidget {
  final int caseId; // Add this line

  const DisposeCases({Key? key, required this.caseId}) : super(key: key);

  @override
  State<DisposeCases> createState() => _DisposeCasesState();
}
class _DisposeCasesState extends State<DisposeCases> {
  final TextEditingController _disposeNoteController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themecolor,
        foregroundColor: Colors.white,
        title: const Text("Dispose Cases", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nature of Dispose (TextField)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nature Of \n Dispose:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 20), // Spacing between label and input field
                Expanded(
                  child: TextField(
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
            SizedBox(height: 20),

            // Dispose Date (Date Picker)
            Row(
              children: [
                const Text("Dispose Dt.:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: themecolor),
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: Text(
                    _selectedDate != null
                        ? "${_selectedDate!.day.toString().padLeft(2, '0')} "
                        "${_selectedDate!.month.toString().padLeft(2, '0')} "
                        "${_selectedDate!.year}"
                        : "Pick a date",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Buttons (Save & Cancel)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themecolor,
                  ),
                  onPressed: () => _saveCase(), // Ensure you pass a valid case ID
                  child: const Text("SAVE", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themecolor,
                  ),
                  // onPressed: (){
                  //   Navigator.push(context, MaterialPageRoute(builder: (context) => GradientPage(),));
                  // },
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


  void _saveCase() async {
    String disposeNote = _disposeNoteController.text;

    if (disposeNote.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter details and select a date")),
      );
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Are you sure you want to dispose this case?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Save disposed case details
      await DatabaseHelper.instance.saveDisposedCase(widget.caseId, disposeNote, _selectedDate!);

      // Mark case as disposed in the caseinfo table
      await DatabaseHelper.instance.updateCaseAsDisposed(widget.caseId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Case disposed successfully!")),
      );

      // Navigate to home page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
            (route) => false,
      );
    }
  }


  // Function to pick a date
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
}
