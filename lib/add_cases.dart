import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'Database/database_helper.dart';
import 'color.dart';

class AddCases extends StatefulWidget {
  final Map<String, dynamic>? caseItem;

  const AddCases({Key? key, this.caseItem}) : super(key: key);

  @override
  State<AddCases> createState() => _AddCasesState();
}

class _AddCasesState extends State<AddCases> {
  final _caseTitleController = TextEditingController();
  final _caseNumberController = TextEditingController();
  final _caseYearController = TextEditingController();
  final _onBehalfOfController = TextEditingController();
  final _partyNameController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _adverseAdvocateController = TextEditingController();
  final _advocateContactController = TextEditingController();
  final _respondentNameController = TextEditingController();
  final _filedUnderSectionController = TextEditingController();

  List<String> courtOptions = [];
  List<String> caseTypeOptions = [];
  String selectedCourt = "";
  String selectedCaseType = "";

  @override
  void initState() {
    super.initState();
    _fetchCourtNames();
    _fetchCaseTypes();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.caseItem != null) {
      _caseTitleController.text = widget.caseItem!["case_title"] ?? "";
      selectedCourt = widget.caseItem!["court_name"] ?? "";
      selectedCaseType = widget.caseItem!["case_type"] ?? "";
      _caseNumberController.text = widget.caseItem!["case_number"] ?? "";
      _caseYearController.text = widget.caseItem!["case_year"].toString();
      _onBehalfOfController.text = widget.caseItem!["case_behalf_of"] ?? "";
      _partyNameController.text = widget.caseItem!["party_name"] ?? "";
      _contactNoController.text = widget.caseItem!["contact"] ?? "";
      _respondentNameController.text = widget.caseItem!["respondent_name"] ?? "";
      _filedUnderSectionController.text = widget.caseItem!["section"] ?? "";
      _adverseAdvocateController.text = widget.caseItem!["adverse_advocate_name"] ?? "";
      _advocateContactController.text = widget.caseItem!["adverse_advocate_contact"] ?? "";
    }
  }

  Future<void> _fetchCourtNames() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> courtList = await db.query('courtlist');
    setState(() {
      courtOptions = courtList.map((court) => court['court_name'] as String).toList();
      selectedCourt = courtOptions.isNotEmpty ? courtOptions[0] : "";
    });
  }

  Future<void> _fetchCaseTypes() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> caseTypeList = await db.query('casetype');
    setState(() {
      caseTypeOptions = caseTypeList.map((type) => type['case_type'] as String).toList();
      selectedCaseType = caseTypeOptions.isNotEmpty ? caseTypeOptions[0] : "";
    });
  }

  Future<void> _addToDatabase(String table, String column, String value) async {
    if (value.isNotEmpty) {
      final db = await DatabaseHelper.instance.database;
      await db.insert(table, {column: value}, conflictAlgorithm: ConflictAlgorithm.replace);
      if (table == 'courtlist') {
        _fetchCourtNames();
      } else {
        _fetchCaseTypes();
      }
    }
  }

  Future<void> _saveCase() async {
    if (_caseTitleController.text.isEmpty || _caseNumberController.text.isEmpty || _caseYearController.text.isEmpty || selectedCourt.isEmpty || selectedCaseType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All required fields must be filled")));
      return;
    }

    final db = await DatabaseHelper.instance.database;
    Map<String, dynamic> caseData = {
      "case_title": _caseTitleController.text,
      "court_name": selectedCourt,
      "case_type": selectedCaseType,
      "case_number": _caseNumberController.text,
      "case_year": int.tryParse(_caseYearController.text) ?? 0,
      "case_behalf_of": _onBehalfOfController.text,
      "party_name": _partyNameController.text,
      "contact": _contactNoController.text,
      "respondent_name": _respondentNameController.text,
      "section": _filedUnderSectionController.text,
      "adverse_advocate_name": _adverseAdvocateController.text,
      "adverse_advocate_contact": _advocateContactController.text,
      "last_adjourn_date": DateTime.now().toString(),
      "is_disposed": 0,
    };

    if (widget.caseItem == null) {
      await db.insert("caseinfo", caseData);
    } else {
      await db.update("caseinfo", caseData, where: "case_id = ?", whereArgs: [widget.caseItem!["case_id"]]);
    }

    Navigator.pop(context);
  }

  Future<void> _showInputDialog(String title, Function(String) onSubmit) async {
    TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add $title"),
          content: TextField(controller: controller, decoration: InputDecoration(hintText: "Enter $title")),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
            TextButton(onPressed: () {
              if (controller.text.isNotEmpty) {
                onSubmit(controller.text);
                Navigator.pop(context);
              }
            }, child: const Text("ADD"))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: themecolor,
        title: const Text("Add Case", style: TextStyle(color: Colors.white)),
        actions: [
          GestureDetector(
            onTap: _saveCase,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.check, color: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("CASE DETAILS"),
            _textField("Case Title", _caseTitleController, isRequired: true),
            _dropdownField("Court Name", selectedCourt, courtOptions, (value) {
              setState(() {
                selectedCourt = value!;
              });
            }, () {
              _showInputDialog("Court Name", (input) {
                setState(() {
                  courtOptions.add(input);
                  selectedCourt = input;
                });
              }
              );
            }, isRequired: true),
            _dropdownField("Case Type", selectedCaseType, caseTypeOptions, (value) {
              setState(() {
                selectedCaseType = value!;
              });
            }, () {
              _showInputDialog("Case Type", (input) {
                setState(() {
                  caseTypeOptions.add(input);
                  selectedCaseType = input;
                });
              });
            }, isRequired: true),
            Row(
              children: [
                Expanded(child: _textField("Case No.", _caseNumberController, isNumeric: true, isRequired: true),),
                const SizedBox(width: 10),
                Expanded(child: _yearPickerField("Year", _caseYearController, isRequired: true)),

              ],
            ),
            _textField("On Behalf Of", _onBehalfOfController, isRequired: true),

            _sectionTitle("PARTY DETAILS"),
            _textField("Party Name", _partyNameController),
            _textField("Contact No", _contactNoController, isNumeric: true),
            _textField("Adverse Advocate Name", _adverseAdvocateController),
            _textField("Advocate Contact No", _advocateContactController, isNumeric: true),

            _sectionTitle("OTHER DETAILS"),
            _textField("Respondent Name", _respondentNameController),
            _textField("Filed U/Sec", _filedUnderSectionController),
          ],
        ),
      ),
    );
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

  Widget _textField(String label, TextEditingController controller, {bool isNumeric = false, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,  // Add asterisk for required fields
          border: OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _dropdownField(
      String label, String value, List<String> options, ValueChanged<String?> onChanged, VoidCallback onAdd, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: isRequired ? '$label *' : label,  // Add asterisk for required fields
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  onChanged: onChanged,
                  items: options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }

  Widget _yearPickerField(String label, TextEditingController controller,
      {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        readOnly: true, // Prevent manual input
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          // Add asterisk for required fields
          border: OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 10),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          int? selectedYear = await _selectYear(context);
          if (selectedYear != null) {
            setState(() {
              controller.text = selectedYear.toString();
            });
          }
        },
      ),
    );
  }

  /// Function to Show a Year Picker Dialog
  Future<int?> _selectYear(BuildContext context) async {
    int currentYear = DateTime
        .now()
        .year;
    int selectedYear = currentYear;

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            height: 300, // Adjust height for better UI
            width: 250,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 100, // Show 100 years (Adjust as needed)
              itemBuilder: (context, index) {
                int year = currentYear - index;
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () {
                    Navigator.pop(context, year);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
