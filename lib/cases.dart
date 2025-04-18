import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lawyer_diary/home.dart';
import 'Case Details/case_details.dart';
import 'Database/database_helper.dart';
import 'add_cases.dart';
import 'color.dart';

class CaseModel {
  final int caseId;
  final String caseTitle;
  final String courtName;
  final String caseType;
  final String caseNumber;
  final int caseYear;
  final String caseBehalfOf;
  final String partyName;
  final String contact;
  final String respondentName;
  final String section;
  final String adverseAdvocateName;
  final String adverseAdvocateContact;
  final String lastAdjournDate;
  final int isDisposed;

  CaseModel({
    required this.caseId,
    required this.caseTitle,
    required this.courtName,
    required this.caseType,
    required this.caseNumber,
    required this.caseYear,
    required this.caseBehalfOf,
    required this.partyName,
    required this.contact,
    required this.respondentName,
    required this.section,
    required this.adverseAdvocateName,
    required this.adverseAdvocateContact,
    required this.lastAdjournDate,
    required this.isDisposed,
  });

  // Convert database row (Map) to CaseModel object
  factory CaseModel.fromMap(Map<String, dynamic> map) {
    return CaseModel(
      caseId: map['case_id'],
      caseTitle: map['case_title'],
      courtName: map['court_name'],
      caseType: map['case_type'],
      caseNumber: map['case_number'],
      caseYear: map['case_year'],
      caseBehalfOf: map['case_behalf_of'],
      partyName: map['party_name'],
      contact: map['contact'],
      respondentName: map['respondent_name'],
      section: map['section'],
      adverseAdvocateName: map['adverse_advocate_name'],
      adverseAdvocateContact: map['adverse_advocate_contact'],
      lastAdjournDate: map['last_adjourn_date'],
      isDisposed: map['is_disposed'],
    );
  }

  // Convert CaseModel object to Map (for inserting/updating database)
  Map<String, dynamic> toMap() {
    return {
      'case_id': caseId,
      'case_title': caseTitle,
      'court_name': courtName,
      'case_type': caseType,
      'case_number': caseNumber,
      'case_year': caseYear,
      'case_behalf_of': caseBehalfOf,
      'party_name': partyName,
      'contact': contact,
      'respondent_name': respondentName,
      'section': section,
      'adverse_advocate_name': adverseAdvocateName,
      'adverse_advocate_contact': adverseAdvocateContact,
      'last_adjourn_date': lastAdjournDate,
      'is_disposed': isDisposed,
    };
  }
}

class Cases extends StatefulWidget {
  const Cases({super.key});

  @override
  State<Cases> createState() => _CasesState();
}

class _CasesState extends State<Cases> {
  List<Map<String, dynamic>> _cases = [];
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCases = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    final List<CaseModel> caseList = await DatabaseHelper.instance.getOngoingCases(); // Fetch only ongoing cases

    setState(() {
      _cases = caseList.map((caseItem) => caseItem.toMap()).toList();
      _filteredCases = _cases; // Initially, show all cases
    });
  }



  void _filterCases(String query) {
    setState(() {
      _filteredCases = _cases
          .where((caseItem) =>
      caseItem['case_title'].toLowerCase().contains(query.toLowerCase()) ||
          caseItem['party_name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<List<CaseModel>> fetchOngoingCases() async {
    return await DatabaseHelper.instance.getOngoingCases();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;

        // Format the date as dd/MM/yyyy
        String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        print("📅 Selected Date: $formattedDate");

        _filterByAdjournDate();
      });
    }
  }


  void _filterByAdjournDate() {
    if (_selectedDate == null) {
      _filteredCases = _cases;
      return;
    }

    String formattedSelected = DateFormat('dd/MM/yyyy').format(_selectedDate!);
    print("Selected: $formattedSelected");

    setState(() {
      _filteredCases = _cases.where((caseItem) {
        String caseDateString = caseItem['last_adjourn_date'];

        try {
          DateTime caseDate = DateTime.parse(caseDateString);
          String formattedCaseDate = DateFormat('dd/MM/yyyy').format(caseDate);

          print("Comparing: $formattedCaseDate with $formattedSelected");

          return formattedCaseDate == formattedSelected;
        } catch (e) {
          print("Invalid date: $caseDateString");
          return false;
        }
      }).toList();
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: _filteredCases.isEmpty
            ? const Center(child: Text("No cases found"))
            : ListView.builder(
          itemCount: _filteredCases.length,
          itemBuilder: (context, index) {
            final caseItem = _filteredCases[index];
            return _buildCaseCard(caseItem);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: themecolor,
        shape: CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCases()),
          ).then((result) {
            if (result == true) {
              // fetchTotalRecords(); // Only refresh if a case was actually added
            }
          });
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      foregroundColor: Colors.white,
      title: const Text("Case List", style: TextStyle(color: Colors.white),),
      backgroundColor: themecolor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: (){
        Navigator.pop(context,true);
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),

        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10,bottom: 5),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterCases,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true, // Reduces vertical height
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: () => _pickDate(context),
                child: const Icon(Icons.date_range_sharp, color: Colors.white, size: 40),
              ),
            ),
            if (_selectedDate != null)
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                    _filteredCases = _cases;
                  });
                },
              ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> caseItem) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaseDetailsPage(
              caseItem: caseItem,
              caseId: int.parse(caseItem['case_id'].toString()),
              disposeFlag: true,
            ),
          ),
        );

        if (result == true) {
          _loadCases(); // Refresh if needed
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Case Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    caseItem['case_title'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 5),

              // Court and Case Number Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _boldText("Court", caseItem['court_name']),
                  _boldText("Case Type", caseItem['case_type']),
                  _boldText("Case#", "${caseItem['case_number']}/${caseItem['case_year']}"),
                ],
              ),
              const SizedBox(height: 10),

              // Party Info
              Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    caseItem['party_name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    caseItem['contact'],
                    style: const TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // On Behalf Of
              _detailRow("On Behalf Of", caseItem['case_behalf_of']),

              _detailRow("Previous Date", "-"), // Update if available
              _detailRow(
                "Adjourn Date",
                caseItem['last_adjourn_date'] != null
                    ? DateFormat('dd/MM/yyyy').format(DateTime.parse(caseItem['last_adjourn_date']))
                    : 'N/A',
              ),

              _detailRow("Steps", "no steps"), // Update dynamically if needed
            ],
          ),
        ),
      ),
    );
  }

// Helper method for bold label and value in a row
  Widget _boldText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

// Helper method for detail rows
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(value.isNotEmpty ? value : "-", style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }


  Widget _titleRow(Map<String, dynamic> caseItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          caseItem['case_title'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Icon(Icons.chevron_right),
      ],
    );
  }


}
