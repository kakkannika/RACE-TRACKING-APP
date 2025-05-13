import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/race_result_board_repository.dart';
import 'package:race_traking_app/data/repository/mock/mock_race_result_board_repository.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/model/race_result_board.dart';
import 'package:race_traking_app/ui/providers/async_value.dart';

class RaceResultBoardProvider extends ChangeNotifier {
  final RaceResultBoardRepository _raceResultBoardRepository;
  final bool _isMockRepository;
  
    AsyncValue<RaceResultBoard> raceResultBoardValue = const AsyncValue.loading();
  AsyncValue<RaceResultBoard>? specificRaceResultBoardValue;
  
    StreamSubscription<RaceResultBoard>? _raceResultBoardSubscription;
  
  RaceResultBoardProvider(this._raceResultBoardRepository)
      : _isMockRepository = _raceResultBoardRepository is MockRaceResultBoardRepository {
    if (_isMockRepository) {
      fetchCurrentRaceResultBoard();
    } else {
      subscribeToRaceResultBoardUpdates();
    }
  }
  
  @override
  void dispose() {
        _raceResultBoardSubscription?.cancel();
    super.dispose();
  }

    void subscribeToRaceResultBoardUpdates() {
    raceResultBoardValue = const AsyncValue.loading();
    notifyListeners();
    
        _raceResultBoardSubscription = _raceResultBoardRepository.getRaceResultBoardStream().listen(
      (board) {
                raceResultBoardValue = AsyncValue.success(board);
        notifyListeners();
      },
      onError: (error) {
        raceResultBoardValue = AsyncValue.error(error);
        notifyListeners();
        
                Future.delayed(const Duration(seconds: 5), subscribeToRaceResultBoardUpdates);
      }
    );
  }

      Future<void> fetchCurrentRaceResultBoard() async {
    raceResultBoardValue = const AsyncValue.loading();
    notifyListeners();

    try {
            final board = await _raceResultBoardRepository.getCurrentRaceResultBoard();
      raceResultBoardValue = AsyncValue.success(board);
    } catch (error) {
      raceResultBoardValue = AsyncValue.error(error);
    }
    notifyListeners();
  }

    Future<void> fetchRaceResultBoardByRace(Race race) async {
    specificRaceResultBoardValue = const AsyncValue.loading();
    notifyListeners();
    
    try {
      final board = await _raceResultBoardRepository.getRaceResultBoardByRace(race);
      specificRaceResultBoardValue = AsyncValue.success(board);
    } catch (error) {
      specificRaceResultBoardValue = AsyncValue.error(error);
    }
    notifyListeners();
  }

    Future<void> generateRaceResultBoard(Race race) async {
    try {
      raceResultBoardValue = const AsyncValue.loading();
      notifyListeners();
      
      final board = await _raceResultBoardRepository.generateRaceResultBoard(race);
      raceResultBoardValue = AsyncValue.success(board);
      notifyListeners();
      
      if (_isMockRepository) {
        await fetchCurrentRaceResultBoard();
      }
    } catch (error) {
      raceResultBoardValue = AsyncValue.error(error);
      notifyListeners();
      rethrow;
    }
  }

    Future<RaceResultItem?> getResultItemByParticipant(String bibNumber, Race race) async {
    try {
      return await _raceResultBoardRepository.getResultItemByParticipant(bibNumber, race);
    } catch (error) {
            if (raceResultBoardValue.isSuccess && 
          raceResultBoardValue.data!.race.date == race.date) {
        try {
          return raceResultBoardValue.data!.resultItems.firstWhere(
            (item) => item.bibNumber == bibNumber
          );
        } catch (_) {
          return null;
        }
      }
      rethrow;
    }
  }
} 