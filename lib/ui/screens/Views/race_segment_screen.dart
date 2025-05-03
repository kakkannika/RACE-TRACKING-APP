import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/screens/Views/2step/twoStep_screen.dart';
import 'package:race_traking_app/ui/screens/Views/GridView/grid_screen.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class RaceTrackingScreen extends StatefulWidget {
  final String segment;

  const RaceTrackingScreen({
    Key? key,
    required this.segment,
  }) : super(key: key);

  @override
  State<RaceTrackingScreen> createState() => _RaceTrackingScreenState();
}

class _RaceTrackingScreenState extends State<RaceTrackingScreen> {
  int _selectedIndex = 0;
  late String _segment;

  @override
  void initState() {
    super.initState();
    _segment = widget.segment;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: RaceColors.primary,
        centerTitle: true,
        title: Text(
          '$_segment Segment', 
          style: TextStyle(color: RaceColors.white,fontSize: RaceTextStyles.subtitle.fontSize),
        ),
        leading: BackButton(color: RaceColors.white),
      ),
      body: Column(
        children: [
          // Header with Segment Info
          Container(         
            child: Column(
              
              children: [
                SizedBox(height: RaceSpacings.xs),
                Text(
                  '11:11:11.00',
                  style: TextStyle(
                    fontSize: RaceTextStyles.heading.fontSize,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),

          // Custom Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildTabButton(
                  title: 'Grid View',
                  index: 0,
                ),
                _buildTabButton(
                  title: '2-Step View',
                  index: 1,
                ),
              ],
            ),
          ),

          // Content with Segment Context
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                ParticipantGridView(segment: _segment),
                TwoStepView(segment: _segment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? RaceColors.primary : RaceColors.darkGrey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              color: isSelected ? RaceColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}