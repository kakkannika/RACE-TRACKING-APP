import 'dart:async';

import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/data/repository/mock/mock_participant_repository.dart';

class MockRaceRepository implements RaceRepository {
  final MockParticipantRepository _participantRepository = MockParticipantRepository();
  
  Race currentRace = Race(
    date: DateTime.now(),
    status: RaceStatus.notStarted,
    participantBibNumbers: [],
  );

  MockRaceRepository() {
    _initializeRace();
  }

  Future<void> _initializeRace() async {
    final participants = await _participantRepository.getAllParticipants();
    final bibNumbers = participants.map((p) => p.bibNumber).toList();
    
    currentRace = currentRace.copyWith(
      participantBibNumbers: bibNumbers,
    );
  }

  @override
  Future<Race> getCurrentRace() async {
    final participants = await _participantRepository.getAllParticipants();
    final bibNumbers = participants.map((p) => p.bibNumber).toList();
    
    currentRace = currentRace.copyWith(
      participantBibNumbers: bibNumbers,
    );
    
    return currentRace;
  }
  
  void _updateRace(Race updatedRace) {
    currentRace = updatedRace;
  }
  
  @override
  Future<void> startRace() async {
    await getCurrentRace();
    
    final updatedRace = currentRace.copyWith(
      startTime: DateTime.now(),
      status: RaceStatus.started,
    );
    
    _updateRace(updatedRace);
  }
  
  @override
  Future<void> finishRace() async {
    final updatedRace = currentRace.copyWith(
      endTime: DateTime.now(),
      status: RaceStatus.finished,
    );
    
    _updateRace(updatedRace);
  }
  
  @override
  Future<void> resetRace() async {
    final participants = await _participantRepository.getAllParticipants();
    final bibNumbers = participants.map((p) => p.bibNumber).toList();
    
    currentRace = Race(
      date: DateTime.now(),
      status: RaceStatus.notStarted,
      startTime: null,
      endTime: null,
      participantBibNumbers: bibNumbers,
    );
  }

  @override
  Stream<Race> getRaceStream() {
    return Stream.periodic(const Duration(seconds: 1), (i) => currentRace);
  }
}