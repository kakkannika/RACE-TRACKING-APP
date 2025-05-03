import 'package:flutter/material.dart';

class TimerDisplay extends StatelessWidget {
  final Duration elapsedTime;

  const TimerDisplay({Key? key, required this.elapsedTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(duration.inHours);
      final minutes = twoDigits(duration.inMinutes.remainder(60));
      final seconds = twoDigits(duration.inSeconds.remainder(60));
      final milliseconds = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
      return "$hours:$minutes:$seconds:$milliseconds";
    }

    return Center(
      child: Text(
        _formatDuration(elapsedTime),
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w400,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}