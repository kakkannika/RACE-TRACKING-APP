import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/timer_repository.dart';

class TimerProvider with ChangeNotifier {
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;
  bool _isRunning = false;

  final TimerRepository _timerRepository;

  TimerProvider(this._timerRepository);

  Duration get elapsedTime => _elapsedTime;
  bool get isRunning => _isRunning;

  void startTimer() {
    if (_timer != null) return;

    _isRunning = true;

    // Update every 10 milliseconds for smooth timing display
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _elapsedTime = _elapsedTime + const Duration(milliseconds: 10);
      notifyListeners();
    });

    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _timer = null;
    _elapsedTime = Duration.zero;
    _isRunning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
