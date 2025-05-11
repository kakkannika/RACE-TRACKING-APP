import 'dart:async';

import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/data/repository/race_repository.dart';
import 'package:race_traking_app/model/segment_time.dart';
import 'package:race_traking_app/model/race.dart';

class MockSegmentTimeRepository implements SegmentTimeRepository {
  final List<SegmentTime> _segmentTimes = [];
  final _segmentTimesStreamController = StreamController<List<SegmentTime>>.broadcast();
  final RaceRepository _raceRepository;
  static const List<String> segmentOrder = ['swim', 'cycle', 'run'];
  
  MockSegmentTimeRepository({required RaceRepository raceRepository}) 
    : _raceRepository = raceRepository {
    _notifyListeners();
  }

  Future<bool> _isRaceActive() async {
    final race = await _raceRepository.getCurrentRace();
    return race.status == RaceStatus.started;
  }

  @override
  Future<List<SegmentTime>> getAllSegmentTimes() async {
    return List.from(_segmentTimes);
  }
  
  @override
  Future<List<SegmentTime>> getSegmentTimesBySegment(String segmentName) async {
    return _segmentTimes
        .where((time) => time.segmentName.toLowerCase() == segmentName.toLowerCase())
        .toList();
  }
  
  @override
  Future<List<SegmentTime>> getSegmentTimesByParticipant(String bibNumber) async {
    return _segmentTimes
        .where((time) => time.participantBibNumber == bibNumber)
        .toList();
  }
  
  @override
  Future<SegmentTime> startSegmentTime(String bibNumber, String segmentName) async {
    if (!await _isRaceActive()) {
      throw Exception('Cannot start segment time when race is not active');
    }

    final normalizedSegmentName = segmentName.toLowerCase();
    final currentSegmentIndex = segmentOrder.indexOf(normalizedSegmentName);
    
    if (currentSegmentIndex == -1) {
      throw Exception('Invalid segment name: $segmentName');
    }

    final existingIndex = _segmentTimes.indexWhere(
      (time) => 
          time.participantBibNumber == bibNumber && 
          time.segmentName.toLowerCase() == normalizedSegmentName
    );
    
    if (existingIndex != -1) {
      if (_segmentTimes[existingIndex].endTime != null) {
        _segmentTimes.removeAt(existingIndex);
      } else {
        return _segmentTimes[existingIndex];
      }
    }
    
    DateTime startTime = DateTime.now();
    
    if (currentSegmentIndex > 0) {
      final previousSegment = segmentOrder[currentSegmentIndex - 1];
      try {
        final previousSegmentTime = _segmentTimes.lastWhere(
          (time) => 
              time.participantBibNumber == bibNumber && 
              time.segmentName.toLowerCase() == previousSegment,
        );
        
        if (!previousSegmentTime.isCompleted) {
          throw Exception('Previous segment ($previousSegment) must be completed first');
        }
        
        startTime = previousSegmentTime.endTime!;
      } catch (e) {
        throw Exception('Previous segment ($previousSegment) must be completed first');
      }
    }
    
    final segmentTime = SegmentTime(
      participantBibNumber: bibNumber,
      segmentName: normalizedSegmentName,
      startTime: startTime,
    );
    
    _segmentTimes.add(segmentTime);
    _notifyListeners();
    return segmentTime;
  }
  
  @override
  Future<SegmentTime> endSegmentTime(String bibNumber, String segmentName) async {
    if (!await _isRaceActive()) {
      throw Exception('Cannot end segment time when race is not active');
    }

    final normalizedSegmentName = segmentName.toLowerCase();
    final index = _segmentTimes.indexWhere(
      (time) => 
          time.participantBibNumber == bibNumber && 
          time.segmentName.toLowerCase() == normalizedSegmentName
    );
    
    if (index == -1) {
      throw Exception('Cannot end segment time that hasn\'t started');
    }
    
    final existingTime = _segmentTimes[index];
    
    if (existingTime.endTime != null) {
      return existingTime;
    }
    
    final updatedTime = existingTime.copyWith(
      endTime: DateTime.now(),
    );
    
    _segmentTimes[index] = updatedTime;
    _notifyListeners();
    return updatedTime;
  }
  
  @override
  Future<void> deleteSegmentTime(String bibNumber, String segmentName) async {
    if (!await _isRaceActive()) {
      throw Exception('Cannot delete segment time when race is not active');
    }

    final normalizedSegmentName = segmentName.toLowerCase();
    final segmentIndex = segmentOrder.indexOf(normalizedSegmentName);
    
    if (segmentIndex < segmentOrder.length - 1) {
      final hasLaterSegments = _segmentTimes.any((time) => 
          time.participantBibNumber == bibNumber && 
          segmentOrder.indexOf(time.segmentName.toLowerCase()) > segmentIndex
      );
      
      if (hasLaterSegments) {
        throw Exception('Cannot delete a segment when later segments exist');
      }
    }

    _segmentTimes.removeWhere(
      (time) => 
          time.participantBibNumber == bibNumber && 
          time.segmentName.toLowerCase() == normalizedSegmentName
    );
    
    _notifyListeners();
  }
  
  @override
  Stream<List<SegmentTime>> getSegmentTimesStream() {
    return _segmentTimesStreamController.stream;
  }
  
  @override
  Future<SegmentTime> endSegmentTimeForTwoStep(String bibNumber, String segmentName, DateTime finishTime) async {
    if (!await _isRaceActive()) {
      throw Exception('Cannot end segment time when race is not active');
    }

    final normalizedSegmentName = segmentName.toLowerCase();
    final index = _segmentTimes.indexWhere(
      (time) => 
          time.participantBibNumber == bibNumber && 
          time.segmentName.toLowerCase() == normalizedSegmentName
    );
    
    if (index == -1) {
      if (normalizedSegmentName == 'swim') {
        DateTime? raceStartTime;
        final existingSwimSegments = _segmentTimes.where(
          (time) => time.segmentName.toLowerCase() == 'swim' && time.startTime != null
        );
        
        if (existingSwimSegments.isNotEmpty) {
          raceStartTime = existingSwimSegments.first.startTime;
        } else {
          raceStartTime = finishTime.subtract(const Duration(minutes: 5));
        }
        
        final swimSegmentTime = SegmentTime(
          participantBibNumber: bibNumber,
          segmentName: 'swim',
          startTime: raceStartTime,
          endTime: finishTime,
        );
        
        _segmentTimes.add(swimSegmentTime);
        _notifyListeners();
        return swimSegmentTime;
      } else if (segmentOrder.indexOf(normalizedSegmentName) > 0) {
        final previousSegmentName = segmentOrder[segmentOrder.indexOf(normalizedSegmentName) - 1];
        
        try {
          final previousSegmentTime = _segmentTimes.lastWhere(
            (time) => 
                time.participantBibNumber == bibNumber && 
                time.segmentName.toLowerCase() == previousSegmentName &&
                time.endTime != null,
          );
          
          final segmentTime = SegmentTime(
            participantBibNumber: bibNumber,
            segmentName: normalizedSegmentName,
            startTime: previousSegmentTime.endTime!,
            endTime: finishTime,
          );
          
          _segmentTimes.add(segmentTime);
          _notifyListeners();
          return segmentTime;
        } catch (e) {
          throw Exception('Previous segment must be completed first');
        }
      } else {
        throw Exception('Cannot end segment time that hasn\'t started');
      }
    }
    
    final existingTime = _segmentTimes[index];
    
    if (existingTime.endTime != null) {
      return existingTime;
    }
    
    final updatedTime = existingTime.copyWith(
      endTime: finishTime,
    );
    
    _segmentTimes[index] = updatedTime;
    _notifyListeners();
    return updatedTime;
  }
  
  void _notifyListeners() {
    _segmentTimesStreamController.add(List.from(_segmentTimes));
  }
  
  void dispose() {
    _segmentTimesStreamController.close();
  }
}