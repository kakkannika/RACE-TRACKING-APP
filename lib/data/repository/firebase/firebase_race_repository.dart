import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/data/dto/race_dto.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/data/repository/firebase/firebase_participant_repository.dart';

class FirebaseRaceRepository implements RaceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseParticipantRepository _participantRepository;
  
  final String _racesCollection = 'races';
  final String _currentRaceDoc = 'current';

  FirebaseRaceRepository({
    FirebaseFirestore? firestore,
    FirebaseParticipantRepository? participantRepository
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _participantRepository = participantRepository ?? FirebaseParticipantRepository();
  
  Future<void> _createDefaultRace() async {
    final participants = await _participantRepository.getAllParticipants();
    final bibNumbers = participants.map((p) => p.bibNumber).toList();
    
    final defaultRace = Race(
      date: DateTime.now(),
      status: RaceStatus.notStarted,
      participantBibNumbers: bibNumbers,
    );
    
    await _firestore
        .collection(_racesCollection)
        .doc(_currentRaceDoc)
        .set(RaceDto.toJson(defaultRace));
  }

  @override
  Stream<Race> getRaceStream() {
    return _firestore
        .collection(_racesCollection)
        .doc(_currentRaceDoc)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.exists) {
            final raceData = snapshot.data()!;
            
            if (!raceData.containsKey('date') || !raceData.containsKey('status')) {
              await _createDefaultRace();
              return getCurrentRace();
            }
            
            final participants = await _participantRepository.getAllParticipants();
            final bibNumbers = participants.map((p) => p.bibNumber).toList();
            
            Race race = RaceDto.fromJson(_currentRaceDoc, raceData);
            
            if (race.participantBibNumbers.length != bibNumbers.length ||
                !_areListsEqual(race.participantBibNumbers, bibNumbers)) {
              race = race.copyWith(participantBibNumbers: bibNumbers);
              
              _firestore
                  .collection(_racesCollection)
                  .doc(_currentRaceDoc)
                  .update({'participantBibNumbers': bibNumbers})
                  .catchError((error) {
                    return null;
                  });
            }
            
            return race;
          } else {
            await _createDefaultRace();
            return getCurrentRace();
          }
        });
  }
  
  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    list1.sort();
    list2.sort();
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  Future<Race> getCurrentRace() async {
    try {
      final participants = await _participantRepository.getAllParticipants();
      final bibNumbers = participants.map((p) => p.bibNumber).toList();
      
      final docSnapshot = await _firestore
          .collection(_racesCollection)
          .doc(_currentRaceDoc)
          .get();
      
      if (docSnapshot.exists) {
        final raceData = docSnapshot.data()!;
        
        if (!raceData.containsKey('date') || 
            !raceData.containsKey('status')) {
          await _createDefaultRace();
          return getCurrentRace();
        }
        
        Race race = RaceDto.fromJson(_currentRaceDoc, raceData);
        
        if (race.participantBibNumbers.length != bibNumbers.length ||
            !_areListsEqual(race.participantBibNumbers, bibNumbers)) {
          race = race.copyWith(participantBibNumbers: bibNumbers);
          
          await _firestore
              .collection(_racesCollection)
              .doc(_currentRaceDoc)
              .update({'participantBibNumbers': bibNumbers});
        }
        
        return race;
      } else {
        await _createDefaultRace();
        
        final newDocSnapshot = await _firestore
            .collection(_racesCollection)
            .doc(_currentRaceDoc)
            .get();
        
        if (!newDocSnapshot.exists) {
          throw Exception("Failed to create race document");
        }
        
        return RaceDto.fromJson(_currentRaceDoc, newDocSnapshot.data()!);
      }
    } catch (error) {
      throw Exception("Couldn't get race data: ${error.toString()}");
    }
  }
  
  @override
  Future<void> startRace() async {
    try {
      await getCurrentRace();
      
      final participantRepo = FirebaseParticipantRepository();
      final participants = await participantRepo.getAllParticipants();
      
      if (participants.isEmpty) {
        throw Exception('Cannot start race without participants');
      }
      
      await _firestore
          .collection(_racesCollection)
          .doc(_currentRaceDoc)
          .update({
            'startTime': Timestamp.fromDate(DateTime.now()),
            'status': RaceStatus.started.index,
          });
    } catch (error) {
      rethrow;
    }
  }
  
  @override
  Future<void> finishRace() async {
    try {
      await _firestore
          .collection(_racesCollection)
          .doc(_currentRaceDoc)
          .update({
            'endTime': Timestamp.fromDate(DateTime.now()),
            'status': RaceStatus.finished.index,
          });
    } catch (error) {
      rethrow;
    }
  }
  
  @override
  Future<void> resetRace() async {
    try {
      final participants = await _participantRepository.getAllParticipants();
      final bibNumbers = participants.map((p) => p.bibNumber).toList();
      
      final newRace = Race(
        date: DateTime.now(),
        status: RaceStatus.notStarted,
        startTime: null,
        endTime: null,
        participantBibNumbers: bibNumbers,
      );
      
      const segmentTimesCollection = 'segmentTimes';
      final segmentTimesSnapshot = await _firestore.collection(segmentTimesCollection).get();
      final batch = _firestore.batch();
      
      for (final doc in segmentTimesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      batch.set(
        _firestore.collection(_racesCollection).doc(_currentRaceDoc),
        RaceDto.toJson(newRace)
      );
      
      await batch.commit();
    } catch (error) {
      rethrow;
    }
  }
}