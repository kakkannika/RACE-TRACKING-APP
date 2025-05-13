import 'dart:async';
import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

/// A reusable loading indicator widget
class LoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final bool showTimer;

  const LoadingIndicator({
    Key? key,
    this.size = 40.0,
    this.color,
    this.showTimer = false,
  }) : super(key: key);

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.showTimer) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? RaceColors.primary,
            ),
          ),
        ),
        if (widget.showTimer && _seconds > 0) ...[
          const SizedBox(height: 8),
          Text(
            'Loading for ${_seconds}s',
            style: RaceTextStyles.label.copyWith(
              color: widget.color ?? RaceColors.primary,
            ),
          ),
        ],
      ],
    );
  }
} 