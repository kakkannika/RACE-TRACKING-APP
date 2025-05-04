import 'dart:async';

class TimerService {
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;

  Duration get elapsedTime => _elapsedTime;

  void startTimer(Function(Duration) onTick) {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _elapsedTime += const Duration(milliseconds: 10);
      onTick(_elapsedTime);
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void resetTimer() {
    _timer?.cancel();
    _elapsedTime = Duration.zero;
  }
}