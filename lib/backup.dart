// import 'package:flutter/material.dart';
//
// import 'Database/database_helper.dart';
//
// class Backup extends StatefulWidget {
//   const Backup({super.key});
//
//   @override
//   State<Backup> createState() => _BackupState();
// }
//
// class _BackupState extends State<Backup> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Backup and Restore'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: () async {
//                 String message = await DatabaseHelper.instance.backupDatabase();
//                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//               },
//               child: const Text('BACKUP'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 String message = await DatabaseHelper.instance.restoreDatabase();
//                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//               },
//               child: const Text('RESTORE'),
//             ),
//
//           ],
//         ),
//       ),
//     );
//   }
// }