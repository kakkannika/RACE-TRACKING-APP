import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/screens/2step/twoStep_screen.dart';
import 'package:race_traking_app/ui/screens/GridView/grid_screen.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class RaceTrackingScreen extends StatefulWidget {
  const RaceTrackingScreen({Key? key}) : super(key: key);

  @override
  State<RaceTrackingScreen> createState() => _RaceTrackingScreenState();
}

class _RaceTrackingScreenState extends State<RaceTrackingScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: RaceColors.primary,
        title: const Text('Cycle Segment', style: TextStyle(color: Colors.white)),
        leading: BackButton(color: RaceColors.white),
      ),
      body: Column(
        children: [
          // Timer display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '11:11:11.00',
              style: TextStyle(
                fontSize: RaceTextStyles.heading.fontSize,
                fontWeight: FontWeight.bold
              ),
            ),
          ),

          // Custom Tab Bar
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 0),
                  child: Column(
                    children: [
                      Text(
                        'Grid View',
                        style: TextStyle(
                          color: _selectedIndex == 0 
                            ? RaceColors.primary 
                            : RaceColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        color: _selectedIndex == 0 
                          ? RaceColors.primary 
                          : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 1),
                  child: Column(
                    children: [
                      Text(
                        '2-Step View',
                        style: TextStyle(
                          color: _selectedIndex == 1 
                            ? RaceColors.primary 
                            : RaceColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        color: _selectedIndex == 1 
                          ? RaceColors.primary 
                          : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [
                ParticipantGridView(),
                TwoStepView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}