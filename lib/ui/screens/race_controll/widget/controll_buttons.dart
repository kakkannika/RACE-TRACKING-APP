import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class ControlButtons extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onStartPause;
  final VoidCallback onReset;

  const ControlButtons({
    Key? key,
    required this.isRunning,
    required this.onStartPause,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset Button
          ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: RaceColors.secondary,
              foregroundColor: RaceColors.black,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(24),
              minimumSize: const Size(80, 80),
            ),
            child: Text(
              'Reset',
              style: RaceTextStyles.label.copyWith(
                color: RaceColors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Start/Pause Button
          ElevatedButton(
            onPressed: onStartPause,
            style: ElevatedButton.styleFrom(
              backgroundColor: RaceColors.primary,
              foregroundColor: RaceColors.white,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(24),
              minimumSize: const Size(80, 80),
            ),
            child: Text(
              isRunning ? 'Pause' : 'Start',
              style: RaceTextStyles.label.copyWith(
                color: RaceColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
