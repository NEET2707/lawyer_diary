import 'package:flutter/material.dart';
import 'Case Details/case_details.dart';
import 'Database/database_helper.dart';
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
  final String userId; // Add user_id field

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
    required this.userId, // Add user_id to the constructor
  });

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
      userId: map['user_id'], // Make sure user_id is retrieved
    );
  }

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
      'user_id': userId, // Make sure user_id is stored
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _filteredCases.isEmpty
          ? const Center(child: Text("No cases found"))
          : ListView.builder(
        itemCount: _filteredCases.length,
        itemBuilder: (context, index) {
          final caseItem = _filteredCases[index];
          return _buildCaseCard(caseItem);
        },
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
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: TextField(
            controller: _searchController,
            onChanged: _filterCases,
            decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaseCard(Map<String, dynamic> caseItem) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CaseDetailsPage(caseItem: caseItem, caseId: int.parse(caseItem['case_id'].toString()),),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleRow(caseItem),
              const SizedBox(height: 8),
              _detailRow(Icons.gavel, "Court", caseItem['court_name']),
              _detailRow(Icons.confirmation_number, "Case #", "${caseItem['case_number']}/${caseItem['case_year']}"),
              _detailRow(Icons.person, "On Behalf Of", caseItem['case_behalf_of']),
              _detailRow(Icons.phone, "Contact No", caseItem['contact']),
              _detailRow(Icons.people, "Respondent", caseItem['respondent_name']),
              _detailRow(Icons.article, "Section", caseItem['section']),
              _detailRow(Icons.account_balance, "Adverse Advocate", caseItem['adverse_advocate_name']),
              _detailRow(Icons.phone_android, "Advocate Contact", caseItem['adverse_advocate_contact']),
              _detailRow(Icons.event, "Last Adjourn Date", caseItem['last_adjourn_date']),
              _detailRow(Icons.check_circle, "Disposed", caseItem['is_disposed'] == 1 ? "Yes" : "No"),
              const SizedBox(height: 10),
            ],
          ),
        ),
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
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
