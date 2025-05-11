import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/ui/providers/async_value.dart';

class RaceProvider extends ChangeNotifier {
  final RaceRepository _raceRepository;
  
    AsyncValue<Race> currentRaceValue = const AsyncValue.loading();
  
  
    StreamSubscription<Race>? _raceSubscription;
  
  RaceProvider({required RaceRepository raceRepository})
      : _raceRepository = raceRepository {
    subscribeToRaceUpdates();
  }
  
  @override
  void dispose() {
        _raceSubscription?.cancel();
    super.dispose();
  }

    void subscribeToRaceUpdates() {
    currentRaceValue = const AsyncValue.loading();
    notifyListeners();

    try {
      _raceSubscription = _raceRepository.getRaceStream().listen(
        (race) {
          currentRaceValue = AsyncValue.success(race);
          notifyListeners();
        },
        onError: (error) {
          currentRaceValue = AsyncValue.error(error);
          notifyListeners();
        }
      );
    } catch (error) {
      currentRaceValue = AsyncValue.error(error);
      notifyListeners();
    }
  }

      Future<void> fetchCurrentRace() async {
    currentRaceValue = const AsyncValue.loading();
    notifyListeners();
    
    try {
      final race = await _raceRepository.getCurrentRace();
      currentRaceValue = AsyncValue.success(race);
    } catch (error) {
      currentRaceValue = AsyncValue.error(error);
    }
    notifyListeners();
  }

    Future<void> startRace() async {
    try {
      await _raceRepository.startRace();
    } catch (error) {
      currentRaceValue = AsyncValue.error(error);
      notifyListeners();
      rethrow;
    }
  }

    Future<void> finishRace() async {
    try {
      await _raceRepository.finishRace();
    } catch (error) {
      currentRaceValue = AsyncValue.error(error);
      notifyListeners();
      rethrow;
    }
  }

    Future<void> resetRace() async {
    try {
      await _raceRepository.resetRace();
    } catch (error) {
      currentRaceValue = AsyncValue.error(error);
      notifyListeners();
      rethrow;
    }
  }
  
  
}
