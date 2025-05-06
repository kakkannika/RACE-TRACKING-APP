import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/ui/providers/async_value.dart';

class RaceProvider extends ChangeNotifier {
  final RaceRepository _raceRepository;
  
  AsyncValue<Race>? currentRace;
  
  Race? _cachedRace;
  bool _hasLoadedInitialData = false;
  
  StreamSubscription<Race>? _raceSubscription;
  
  RaceProvider({required RaceRepository raceRepository})
      : _raceRepository = raceRepository {
    _subscribeToRaceUpdates();
  }
  
  @override
  void dispose() {
    _raceSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToRaceUpdates() {
    _raceSubscription?.cancel();
    
    if (!_hasLoadedInitialData) {
      currentRace = const AsyncValue.loading();
      notifyListeners();
    }
    
    _raceSubscription = _raceRepository.getRaceStream().listen(
      (race) {
        _cachedRace = race;
        _hasLoadedInitialData = true;
        currentRace = AsyncValue.success(race);
        notifyListeners();
      },
      onError: (error) {
        if (_hasLoadedInitialData && _cachedRace != null) {
          currentRace = AsyncValue.success(_cachedRace!);
        } else {
          currentRace = AsyncValue.error(error);
        }
        notifyListeners();
        
        Future.delayed(const Duration(seconds: 5), _subscribeToRaceUpdates);
      }
    );
  }

  Future<void> fetchCurrentRace() async {
    if (currentRace?.isLoading == true) return;
    
    if (!_hasLoadedInitialData) {
      currentRace = const AsyncValue.loading();
      notifyListeners();
    }

    try {
      final race = await _raceRepository.getCurrentRace();
      
      _cachedRace = race;
      _hasLoadedInitialData = true;
      currentRace = AsyncValue.success(race);
      notifyListeners();
    } catch (error) {
      if (_hasLoadedInitialData && _cachedRace != null) {
        currentRace = AsyncValue.success(_cachedRace!);
      } else {
        currentRace = AsyncValue.error(error);
      }
      notifyListeners();
    }
  }

  Future<void> startRace() async {
    if (!_hasLoadedInitialData || _cachedRace == null) {
      await fetchCurrentRace();
      return;
    }

    try {
      final updatedRace = _cachedRace!.copyWith(
        startTime: DateTime.now(),
        status: RaceStatus.started,
      );
      _cachedRace = updatedRace;
      currentRace = AsyncValue.success(updatedRace);
      notifyListeners();
      
      await _raceRepository.startRace();
    } catch (error) {
      if (_cachedRace != null) {
        currentRace = AsyncValue.success(_cachedRace!);
        notifyListeners();
      } else {
        currentRace = AsyncValue.error(error);
        notifyListeners();
      }
      
      rethrow;
    }
  }

  Future<void> finishRace() async {
    if (!_hasLoadedInitialData || _cachedRace == null) {
      await fetchCurrentRace();
      return;
    }

    try {
      final updatedRace = _cachedRace!.copyWith(
        endTime: DateTime.now(),
        status: RaceStatus.finished,
      );
      _cachedRace = updatedRace;
      currentRace = AsyncValue.success(updatedRace);
      notifyListeners();
      
      await _raceRepository.finishRace();
    } catch (error) {
      if (_cachedRace != null) {
        currentRace = AsyncValue.success(_cachedRace!);
        notifyListeners();
      } else {
        currentRace = AsyncValue.error(error);
        notifyListeners();
      }
    }
  }

  Future<void> resetRace() async {
    if (!_hasLoadedInitialData) {
      await fetchCurrentRace();
      return;
    }

    try {
      final participantBibNumbers = _cachedRace?.participantBibNumbers ?? [];
      
      final updatedRace = Race(
        date: DateTime.now(),
        status: RaceStatus.notStarted,
        startTime: null,
        endTime: null,
        participantBibNumbers: participantBibNumbers,
      );
      _cachedRace = updatedRace;
      currentRace = AsyncValue.success(updatedRace);
      notifyListeners();
      
      await _raceRepository.resetRace();
    } catch (error) {
      if (_cachedRace != null) {
        currentRace = AsyncValue.success(_cachedRace!);
        notifyListeners();
      } else {
        currentRace = AsyncValue.error(error);
        notifyListeners();
      }
    }
  }
  
  
}
