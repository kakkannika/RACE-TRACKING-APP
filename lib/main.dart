import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/screens/2step/test_twoStep_screen.dart';
import 'package:race_traking_app/ui/screens/2step/widget/TwoStep_list_tile.dart';
import 'package:race_traking_app/ui/screens/GridView/test_grid_screen.dart';
import 'package:race_traking_app/ui/screens/resultBoard/test_resultBoard_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Race Tracking Demo',
    
      home: const ResultBoardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}