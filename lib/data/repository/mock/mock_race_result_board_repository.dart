import 'dart:async';

import 'package:race_traking_app/data/repository/race_result_board_repository.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/data/repository/participant_repository.dart';
import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/model/race_result_board.dart';


class MockRaceResultBoardRepository implements RaceResultBoardRepository {
  final RaceRepository _raceRepository;
  final ParticipantRepository _participantRepository;
  final SegmentTimeRepository _segmentTimeRepository;
  
  RaceResultBoard? _currentRaceResultBoard;
  
  final _raceResultBoardStreamController = StreamController<RaceResultBoard>.broadcast();
  
  MockRaceResultBoardRepository({
    required RaceRepository raceRepository,
    required ParticipantRepository participantRepository,
    required SegmentTimeRepository segmentTimeRepository,
  }) : 
    _raceRepository = raceRepository,
    _participantRepository = participantRepository,
    _segmentTimeRepository = segmentTimeRepository {
      _segmentTimeRepository.getSegmentTimesStream().listen((_) async {
        final race = await _raceRepository.getCurrentRace();
        await generateRaceResultBoard(race);
      });
    }
  
  Future<RaceResultBoard> _buildRaceResultBoard(Race race) async {
    final participants = await _participantRepository.getAllParticipants();
    final segmentTimes = await _segmentTimeRepository.getAllSegmentTimes();
    
    return RaceResultBoard.createFromData(
      race: race,
      participants: participants,
      segmentTimes: segmentTimes,
    );
  }
  
  void _notifyListeners(RaceResultBoard board) {
    if (!_raceResultBoardStreamController.isClosed) {
      _raceResultBoardStreamController.add(board);
    }
  }
  
  @override
  Future<RaceResultBoard> getCurrentRaceResultBoard() async {
    if (_currentRaceResultBoard == null) {
      final race = await _raceRepository.getCurrentRace();
      return generateRaceResultBoard(race);
    }
    return _currentRaceResultBoard!;
  }
  
  @override
  Stream<RaceResultBoard> getRaceResultBoardStream() {
    return _raceResultBoardStreamController.stream;
  }
  
  @override
  Future<RaceResultBoard> getRaceResultBoardByRace(Race race) async {
    return _buildRaceResultBoard(race);
  }
  
  @override
  Future<RaceResultBoard> generateRaceResultBoard(Race race) async {
    final board = await _buildRaceResultBoard(race);
    
    _currentRaceResultBoard = board;
    
    _notifyListeners(board);
    
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
  
  void dispose() {
    _raceResultBoardStreamController.close();
  }
} 