import 'package:race_traking_app/service/timer_service.dart';

class TimerRepository {
  final TimerService _timerService;

  TimerRepository(this._timerService);

  Duration get elapsedTime => _timerService.elapsedTime;

  void startTimer(Function(Duration) onTick) {
    _timerService.startTimer(onTick);
  }

  void stopTimer() {
    _timerService.stopTimer();
  }

  void resetTimer() {
    _timerService.resetTimer();
  }
}