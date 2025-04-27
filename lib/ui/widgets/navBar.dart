import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  const Navbar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navBarItem(Icons.people, 'Participant', selectedIndex == 0),
          _navBarItem(Icons.flag, 'Race', selectedIndex == 1),
          _navBarItem(Icons.timer, 'Track Time', selectedIndex == 2),
          _navBarItem(Icons.leaderboard, 'Result board', selectedIndex == 3),
        ],
      ),
    );
  }


  Widget _navBarItem(IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? RaceColors.primary : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? RaceColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
