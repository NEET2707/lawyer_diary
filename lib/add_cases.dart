import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color.dart';
import 'database_helper.dart';


class AddCases extends StatefulWidget {
  final Map<String, dynamic>? caseItem;

  const AddCases({Key? key, this.caseItem}) : super(key: key);

  @override
  State<AddCases> createState() => _AddCasesState();
}


class _AddCasesState extends State<AddCases> {

  Future<void> _saveCase() async {
    if (_caseTitleController.text.isEmpty ||
        _caseNumberController.text.isEmpty ||
        _caseYearController.text.isEmpty ||
        _onBehalfOfController.text.isEmpty ||
        _partyNameController.text.isEmpty ||
        _contactNoController.text.isEmpty ||
        _adverseAdvocateController.text.isEmpty ||
        _advocateContactController.text.isEmpty ||
        _respondentNameController.text.isEmpty ||
        _filedUnderSectionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    final db = await DatabaseHelper.instance.database;
    Map<String, dynamic> caseData = {
      DatabaseHelper.tblcasetitle: _caseTitleController.text,
      DatabaseHelper.tblcourtname: selectedCourt,
      DatabaseHelper.tblcasetype: selectedCaseType,
      DatabaseHelper.tblcasenumber: _caseNumberController.text,
      DatabaseHelper.tblcaseyear: int.tryParse(_caseYearController.text) ?? 0,
      DatabaseHelper.tblcasebehalfof: _onBehalfOfController.text,
      DatabaseHelper.tblpartyname: _partyNameController.text,
      DatabaseHelper.tblcontact: _contactNoController.text,
      DatabaseHelper.tblrespondentname: _respondentNameController.text,
      DatabaseHelper.tblsection: _filedUnderSectionController.text,
      DatabaseHelper.tbladverseadvocatename: _adverseAdvocateController.text,
      DatabaseHelper.tbladverseadvocatecontact: _advocateContactController.text,
      DatabaseHelper.tbllastadjourndate: DateTime.now().toString(),
      DatabaseHelper.tblisdisposed: 0,
    };

    if (widget.caseItem == null) {
      // Insert new case
      await db.insert(DatabaseHelper.tblcaseinfo, caseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Case saved successfully!")),
      );
    } else {
      // Update existing case
      await db.update(
        DatabaseHelper.tblcaseinfo,
        caseData,
        where: "${DatabaseHelper.tblcaseid} = ?",
        whereArgs: [widget.caseItem![DatabaseHelper.tblcaseid]],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Case updated successfully!")),
      );
    }

    Navigator.pop(context);
    // setState(() {
    //
    // });
  }


  final TextEditingController _caseTitleController = TextEditingController();
  final TextEditingController _caseNumberController = TextEditingController();
  final TextEditingController _caseYearController = TextEditingController();
  final TextEditingController _onBehalfOfController = TextEditingController();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _adverseAdvocateController = TextEditingController();
  final TextEditingController _advocateContactController = TextEditingController();
  final TextEditingController _respondentNameController = TextEditingController();
  final TextEditingController _filedUnderSectionController = TextEditingController();

  List<String> courtOptions = ["Italiya", "Other Court"];
  List<String> caseTypeOptions = ["Criminal", "Civil"];

  String selectedCourt = "Italiya";
  String selectedCaseType = "Criminal";

  @override
  void initState() {
    super.initState();

    if (widget.caseItem != null) {
      _caseTitleController.text = widget.caseItem!['case_title'] ?? "";
      selectedCourt = widget.caseItem!['court_name'] ?? "Italiya";
      selectedCaseType = widget.caseItem!['case_type'] ?? "Criminal";
      _caseNumberController.text = widget.caseItem!['case_number'] ?? "";
      _caseYearController.text = widget.caseItem!['case_year']?.toString() ?? "";
      _onBehalfOfController.text = widget.caseItem!['case_behalf_of'] ?? "";
      _partyNameController.text = widget.caseItem!['party_name'] ?? "";
      _contactNoController.text = widget.caseItem!['contact'] ?? "";
      _respondentNameController.text = widget.caseItem!['respondent_name'] ?? "";
      _filedUnderSectionController.text = widget.caseItem!['section'] ?? "";
      _adverseAdvocateController.text = widget.caseItem!['adverse_advocate_name'] ?? "";
      _advocateContactController.text = widget.caseItem!['adverse_advocate_contact'] ?? "";
    }
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
            _textField("Case Title", _caseTitleController),
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
              });
            }),
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
            }),
            Row(
              children: [
                Expanded(child: _textField("Case No.", _caseNumberController, isNumeric: true),),
                const SizedBox(width: 10),
                Expanded(child: _yearPickerField("Year", _caseYearController)),

              ],
            ),
            _textField("On Behalf Of", _onBehalfOfController),

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

  Widget _textField(String label, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }


  Widget _dropdownField(
      String label, String value, List<String> options, ValueChanged<String?> onChanged, VoidCallback onAdd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10), // Reduce padding
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  onChanged: onChanged,
                  items: options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option, style: const TextStyle(fontSize: 14)), // Adjust font size
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

  Widget _yearPickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextFormField(
        controller: controller,
        readOnly: true, // Prevent manual input
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
    int currentYear = DateTime.now().year;
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

  Future<void> _showInputDialog(String title, Function(String) onSubmit) async {
    TextEditingController controller = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  onSubmit(controller.text);
                  Navigator.pop(context);
                }
              },
              child: Text("ADD"),
            ),
          ],
        );
      },
    );
  }
}