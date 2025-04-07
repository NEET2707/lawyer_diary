import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lawyer_diary/Database/database_helper.dart';
import 'package:lawyer_diary/settings.dart';
import 'Case Details/case_details.dart';
import 'cases.dart';
import 'color.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int totalcase = 0;
  int totaldispose = 0;
  int _selectedIndex = 0;

  List<Map<String, dynamic>> latestCases = [];
  List<Map<String, dynamic>> todayCases = [];

  @override
  void initState() {
    super.initState();
    fetchTotalRecords();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchTotalRecords();
  }

  Future<void> fetchTotalRecords() async {
    int cases = await DatabaseHelper.instance.getCountExcludingDisposedCases();
    int disposed = await DatabaseHelper.instance.countDisposedCases();
    List<Map<String, dynamic>> latest =
        await DatabaseHelper.instance.getFirstFiveAdjournCases();

    // 🔄 NEW: Use step-based adjourn data
    List<Map<String, dynamic>> todayStepCases =
        await DatabaseHelper.instance.getUpcomingCasesWithSteps();

    setState(() {
      totalcase = cases;
      totaldispose = disposed;
      latestCases = latest;
      todayCases = todayStepCases;
    });
  }

  final List<Widget> _pages = [
    Container(),
    Builder(builder: (context) => Cases()),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (_selectedIndex == 1 || _selectedIndex == 2)
          ? null
          : AppBar(
              backgroundColor: themecolor,
              title: const Text("Lawyer Diary",
                  style: TextStyle(color: Colors.white)),
            ),
      body: _selectedIndex == 0
          ? RefreshIndicator(
              onRefresh: fetchTotalRecords,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: [
                  if (latestCases.isNotEmpty)
                    _buildCaseCard("Latest 5 Cases", latestCases),
                  if (todayCases.isNotEmpty)
                    _buildStepsTab("Today's Adjourn Cases", todayCases)
                  else
                    _buildNoStepsCard(),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {},
              child: _pages[_selectedIndex],
            ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        height: 65,
        notchMargin: 8.0,
        color: themecolor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0),
            _buildNavItem(Icons.account_circle, "All Cases", 1),
            _buildNavItem(Icons.settings, "Settings", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard(String title, List<Map<String, dynamic>> cases) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.only(top: 10,left: 4,right: 4,bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Divider(),
            ...List.generate(cases.length, (index) {
              final caseData = cases[index];
              return Column(
                children: [
                  ListTile(
                    title: Text(caseData['case_title']),
                    subtitle: Text(
                        "ID: ${caseData['case_id']} • ${caseData['case_type']}"),
                    trailing: Text(
                      DateFormat('dd-MM-yyyy').format(
                          DateTime.parse(caseData['last_adjourn_date'])),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CaseDetailsPage(
                            caseItem: caseData,
                            caseId: int.parse(caseData['case_id'].toString()),
                            disposeFlag: true,
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNoStepsCard() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 40, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No cases available for today's adjourn date.\nNo steps available.",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsTab(String title, List<Map<String, dynamic>> cases) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.only(top: 10,left: 4,right: 4,bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Divider(),
            ...List.generate(cases.length, (index) {
              final caseData = cases[index];
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            caseData['case_title'],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          DateFormat('dd-MM-yyyy').format(
                            DateTime.parse(caseData['adjourn_date']),
                          ),
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "ID: ${caseData['case_number']} • ${caseData['case_type']}\nStep: ${caseData['step'] ?? 'N/A'}",
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CaseDetailsPage(
                            caseItem: caseData,
                            caseId: int.parse(caseData['case_id'].toString()),
                            disposeFlag: true,
                          ),
                        ),
                      );
                    },
                  ),
                    Divider(height: 0),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
