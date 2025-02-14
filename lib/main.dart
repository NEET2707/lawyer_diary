import 'package:flutter/material.dart';
import 'package:lawyer_diary/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Run the app with the correct screen based on PIN availability
  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Lawyer Diary',
        debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
