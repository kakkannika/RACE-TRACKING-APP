import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/data/dto/race_result_board_dto.dart';
import 'package:race_traking_app/data/repository/race_result_board_repository.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/data/repository/participant_repository.dart';
import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/model/race_result_board.dart';

class FirebaseRaceResultBoardRepository implements RaceResultBoardRepository {
  final FirebaseFirestore _firestore;
  final RaceRepository _raceRepository;
  final ParticipantRepository _participantRepository;
  final SegmentTimeRepository _segmentTimeRepository;
  final String _collectionPath = 'raceResultBoards';
  
  FirebaseRaceResultBoardRepository({
    FirebaseFirestore? firestore,
    required RaceRepository raceRepository,
    required ParticipantRepository participantRepository,
    required SegmentTimeRepository segmentTimeRepository,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _raceRepository = raceRepository,
    _participantRepository = participantRepository,
    _segmentTimeRepository = segmentTimeRepository;
  
  Future<RaceResultBoard> _buildRaceResultBoard(Race race) async {
    final participants = await _participantRepository.getAllParticipants();
    final segmentTimes = await _segmentTimeRepository.getAllSegmentTimes();
    
    return RaceResultBoard.createFromData(
      race: race,
      participants: participants,
      segmentTimes: segmentTimes,
    );
  }
  
  Future<void> _saveToFirestore(RaceResultBoard board) async {
    if (board.race.status != RaceStatus.finished) {
      return;
    }
    
    try {
      final docId = board.race.date.toIso8601String();
      await _firestore.collection(_collectionPath).doc(docId).set(
        RaceResultBoardDto.toJson(board)
      );
    } catch (e) {
      throw Exception('Error saving race result board to Firestore: $e');
    }
  }
  
  @override
  Future<RaceResultBoard> getCurrentRaceResultBoard() async {
    try {
      final race = await _raceRepository.getCurrentRace();
      
      if (race.status == RaceStatus.finished) {
        final docId = race.date.toIso8601String();
        final docSnapshot = await _firestore.collection(_collectionPath).doc(docId).get();
        
        if (docSnapshot.exists && docSnapshot.data() != null) {
          return RaceResultBoardDto.fromJson(
            docId, 
            docSnapshot.data() as Map<String, dynamic>
          );
        }
      }
      
      return _buildRaceResultBoard(race);
    } catch (e) {
      final race = await _raceRepository.getCurrentRace();
      return _buildRaceResultBoard(race);
    }
  }
  
  @override
  Stream<RaceResultBoard> getRaceResultBoardStream() {
    return _raceRepository.getRaceStream().asyncMap((race) async {
      if (race.status == RaceStatus.finished) {
        final docId = race.date.toIso8601String();
        final docSnapshot = await _firestore.collection(_collectionPath).doc(docId).get();
        
        if (docSnapshot.exists && docSnapshot.data() != null) {
          return RaceResultBoardDto.fromJson(
            docId, 
            docSnapshot.data() as Map<String, dynamic>
          );
        }
      }
      
      final board = await _buildRaceResultBoard(race);
      
      if (race.status == RaceStatus.finished) {
        await _saveToFirestore(board);
      }
      
      return board;
    });
  }
  
  @override
  Future<RaceResultBoard> getRaceResultBoardByRace(Race race) async {
    if (race.status == RaceStatus.finished) {
      try {
        final docId = race.date.toIso8601String();
        final docSnapshot = await _firestore.collection(_collectionPath).doc(docId).get();
        
        if (docSnapshot.exists && docSnapshot.data() != null) {
          return RaceResultBoardDto.fromJson(
            docId, 
            docSnapshot.data() as Map<String, dynamic>
          );
        }
      } catch (e) {
        throw Exception('Error getting race result board by race: $e');
      }
    }
    
    return _buildRaceResultBoard(race);
  }
  
  @override
  Future<RaceResultBoard> generateRaceResultBoard(Race race) async {
    final board = await _buildRaceResultBoard(race);
    
    if (race.status == RaceStatus.finished) {
      await _saveToFirestore(board);
    }
    
    return board;
  }
  
  @override
  Future<RaceResultItem?> getResultItemByParticipant(String bibNumber, Race race) async {
    final board = await getRaceResultBoardByRace(race);
    
    try {
      return board.resultItems.firstWhere(
        (item) => item.bibNumber == bibNumber
      );
    } catch (e) {
      return null;
    }
  }
}