import 'package:flutter/material.dart';
import 'Database/database_helper.dart';
import 'Case Details/case_details.dart';
import 'color.dart';

class DisposedCases extends StatefulWidget {
  const DisposedCases({super.key});

  @override
  State<DisposedCases> createState() => _DisposedCasesState();
}

class _DisposedCasesState extends State<DisposedCases> {
  List<Map<String, dynamic>> _disposedCases = [];

  @override
  void initState() {
    super.initState();
    _loadDisposedCases();
  }

  Future<void> _loadDisposedCases() async {
    List<Map<String, dynamic>> disposedCases = await DatabaseHelper.instance.getDisposedCases();
    setState(() {
      _disposedCases = disposedCases;
    });
  }

  String _getYear(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    return date.split('-')[0]; // Extracts the year from "YYYY-MM-DD"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text("Disposed Cases", style: TextStyle(color: Colors.white)),
        backgroundColor: themecolor,
      ),
      body: _disposedCases.isEmpty
          ? const Center(child: Text("No disposed cases found"))
          : ListView.builder(
        itemCount: _disposedCases.length,
        itemBuilder: (context, index) {
          final caseItem = _disposedCases[index];
          return _buildCaseCard(caseItem);
        },
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> caseItem) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  caseItem['case_title'] ?? "Unknown Case",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 4),

            // Case Number and Court
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Court: ${caseItem['court_name'] ?? 'Unknown'}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${caseItem['case_year']} / ${_getYear(caseItem['disposed_date'])}",
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const Divider(),

            // Party Name and Contact
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                _tag(caseItem['party_name'] ?? "N/A"),
                const SizedBox(width: 12),
                const Icon(Icons.call, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                _contactTag(caseItem['contact'] ?? "N/A"),
              ],
            ),

            const SizedBox(height: 6),

            _detailRow("Respondent Name", caseItem['respondent_name']),
            _detailRow("Disposed Nature", caseItem['disposed_nature']),
            _detailRow("Disposed Date", caseItem['disposed_date']),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CaseDetailsPage(
                        caseItem: caseItem,
                        caseId: int.parse(caseItem['case_id'].toString()),
                        disposeFlag: false,
                      ),
                    ),
                  );

                },
                child: const Text("View Details", style: TextStyle(color: Colors.blue, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? "N/A", overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _contactTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }
}
