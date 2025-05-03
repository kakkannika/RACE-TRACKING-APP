import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class TimerDisplay extends StatelessWidget {
  final Duration elapsedTime;

  const TimerDisplay({Key? key, required this.elapsedTime}) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = (duration.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return "$hours:$minutes:$seconds.$milliseconds";
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _formatDuration(elapsedTime),
        style: RaceTextStyles.heading.copyWith(
          fontSize: 45,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
          color: RaceColors.black,
        ),
      ),
    );
  }
}
