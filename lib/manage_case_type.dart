import 'package:flutter/material.dart';
import 'package:lawyer_diary/color.dart';
import 'Database/database_helper.dart'; // Import your SQLite Database Helper

class ManageCaseType extends StatefulWidget {
  const ManageCaseType({super.key});

  @override
  State<ManageCaseType> createState() => _ManageCaseTypeState();
}

class _ManageCaseTypeState extends State<ManageCaseType> {
  List<String> caseTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchCaseTypes();
  }

  // Fetch case types from the database
  Future<void> _fetchCaseTypes() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> caseTypeList = await db.query('casetype');

    setState(() {
      caseTypes = caseTypeList.map((caseType) => caseType['case_type'] as String).toList();
    });
  }

  // Add a new case type
  Future<void> _addCaseType(String caseTypeName) async {
    if (caseTypeName.isNotEmpty) {
      final db = await DatabaseHelper.instance.database;
      await db.insert('casetype', {'case_type': caseTypeName});
      _fetchCaseTypes(); // Refresh UI
    }
  }

  // Show confirmation dialog before deleting a case type
  void _confirmDeleteCaseType(String caseTypeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Case Type"),
        content: Text("Are you sure you want to delete \"$caseTypeName\"? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteCaseType(caseTypeName); // Proceed with deletion
            },
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Delete a case type from the database
  Future<void> _deleteCaseType(String caseTypeName) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('casetype', where: 'case_type = ?', whereArgs: [caseTypeName]);
    _fetchCaseTypes(); // Refresh UI after deletion
  }

  // Show dialog to add a new case type
  void _showAddCaseTypeDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Case Type"),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: "Enter case type"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _addCaseType(controller.text.trim());
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
        title: const Text('Manage Case Type', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCaseTypeDialog, // Open add case type dialog
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: caseTypes.isEmpty
            ? const Center(child: CircularProgressIndicator()) // Loading spinner if empty
            : ListView.builder(
          itemCount: caseTypes.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                title: Text(caseTypes[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteCaseType(caseTypes[index]), // Ask for confirmation before deleting
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
