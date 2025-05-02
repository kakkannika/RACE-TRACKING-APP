import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/screens/2step/twoStep_screen.dart';
import 'package:race_traking_app/ui/screens/2step/widget/TwoStep_list_tile.dart';
import 'package:race_traking_app/ui/screens/GridView/grid_screen.dart';
import 'package:race_traking_app/ui/screens/race_track_screen.dart';
import 'package:race_traking_app/ui/screens/resultBoard/resultBoard_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Race Tracking Demo',
    
      home: const RaceTrackingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}