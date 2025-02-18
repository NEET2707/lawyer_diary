import 'package:flutter/material.dart';
import 'package:lawyer_diary/color.dart';
import 'Database/database_helper.dart'; // Your SQLite Database Helper

class ManageCourt extends StatefulWidget {
  const ManageCourt({super.key});

  @override
  State<ManageCourt> createState() => _ManageCourtState();
}

class _ManageCourtState extends State<ManageCourt> {
  List<String> courtOptions = [];
  String? selectedCourt; // Can be null initially

  @override
  void initState() {
    super.initState();
    _fetchCourtNames();
  }

  // Fetch court names from the database
  Future<void> _fetchCourtNames() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> courtList = await db.query('courtlist');

    setState(() {
      courtOptions = courtList.map((court) => court['court_name'] as String).toList();
      selectedCourt = courtOptions.isNotEmpty ? courtOptions[0] : null;
    });
  }

  // Add new court
  Future<void> _addCourt(String courtName) async {
    if (courtName.isNotEmpty) {
      final db = await DatabaseHelper.instance.database;
      await db.insert('courtlist', {'court_name': courtName});
      _fetchCourtNames(); // Refresh the UI
    }
  }

  // Show confirmation before deleting a court
  void _confirmDeleteCourt(String courtName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Court"),
        content: Text("Are you sure you want to delete \"$courtName\"? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteCourt(courtName); // Proceed with deletion
            },
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Delete a court from the database
  Future<void> _deleteCourt(String courtName) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('courtlist', where: 'court_name = ?', whereArgs: [courtName]);
    _fetchCourtNames(); // Refresh UI after deletion
  }

  // Show dialog to add a court
  void _showAddCourtDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Court"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter court name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _addCourt(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themecolor,
        foregroundColor: Colors.white,
        title: const Text('Manage Court', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCourtDialog, // Open add court dialog
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: courtOptions.isEmpty
            ? const Center(child: CircularProgressIndicator()) // Loading spinner if empty
            : ListView.builder(
          itemCount: courtOptions.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(courtOptions[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteCourt(courtOptions[index]), // Ask for confirmation before deleting
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
