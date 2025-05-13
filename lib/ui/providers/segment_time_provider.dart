import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/model/segment_time.dart';
import 'package:race_traking_app/ui/providers/async_value.dart';



class SegmentTimeProvider extends ChangeNotifier {
  final SegmentTimeRepository _repository;
  
  
  AsyncValue<List<SegmentTime>> segmentTimesValue = const AsyncValue.loading();
  
  
  List<SegmentTime> _cachedSegmentTimes = [];
  bool _hasLoadedInitialData = false;
  
  
  dynamic _segmentTimesSubscription;
  
  SegmentTimeProvider({required SegmentTimeRepository repository})
      : _repository = repository {
    
    subscribeToSegmentTimes();
  }
  
  void subscribeToSegmentTimes() {
    
    fetchSegmentTimes();
    
    _segmentTimesSubscription = _repository.getSegmentTimesStream().listen(
      (segmentTimes) {
        _cachedSegmentTimes = segmentTimes;
        _hasLoadedInitialData = true;
        segmentTimesValue = AsyncValue.success(segmentTimes);
        notifyListeners();
      },
      onError: (error) {
        if (_hasLoadedInitialData) {
          
          segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
        } else {
          segmentTimesValue = AsyncValue.error(error);
        }
        notifyListeners();
      }
    );
  }
  
  
  Future<void> startSegmentTime(String bibNumber, String segmentName) async {
    try {
      
      final newSegmentTime = SegmentTime(
        participantBibNumber: bibNumber,
        segmentName: segmentName,
        startTime: DateTime.now(),
      );
      
      _cachedSegmentTimes = List.from(_cachedSegmentTimes)
        ..removeWhere((time) => 
            time.participantBibNumber == bibNumber && 
            time.segmentName == segmentName &&
            time.endTime != null)
        ..add(newSegmentTime);
      
      segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
      notifyListeners();
      
      
      await _repository.startSegmentTime(bibNumber, segmentName);
    } catch (error) {
      
      if (_hasLoadedInitialData) {
        await fetchSegmentTimes();
      } else {
        segmentTimesValue = AsyncValue.error(error);
        notifyListeners();
      }
      rethrow;
    }
  }
  
  
  Future<void> endSegmentTime(String bibNumber, String segmentName) async {
    final normalizedSegmentName = segmentName.toLowerCase();
    final isSwimSegment = normalizedSegmentName == 'swim';
    final segmentOrder = ['swim', 'cycle', 'run'];
    final segmentIndex = segmentOrder.indexOf(normalizedSegmentName);
    
    try {
      
      final existingIndex = _cachedSegmentTimes.indexWhere(
        (time) => time.participantBibNumber == bibNumber && 
                 time.segmentName == normalizedSegmentName &&
                 time.endTime == null
      );
      
      final now = DateTime.now();
      
      if (existingIndex != -1) {
        
        final existingTime = _cachedSegmentTimes[existingIndex];
        final updatedTime = existingTime.copyWith(
          endTime: now,
        );
        
        
        _cachedSegmentTimes = List.from(_cachedSegmentTimes)
          ..[existingIndex] = updatedTime;
        
        segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
        notifyListeners();
      } else if (isSwimSegment) {
        
        
        
        DateTime? raceStartTime;
        
        
        final existingSwimSegments = _cachedSegmentTimes.where(
          (time) => time.segmentName == 'swim' 
        );
        
        if (existingSwimSegments.isNotEmpty) {
          raceStartTime = existingSwimSegments.first.startTime;
        } else {
          
          raceStartTime = now.subtract(const Duration(minutes: 1));
        }
        
        
        final swimSegmentTime = SegmentTime(
          participantBibNumber: bibNumber,
          segmentName: 'swim',
          startTime: raceStartTime,
          endTime: now,
        );
        
        
        _cachedSegmentTimes = List.from(_cachedSegmentTimes)..add(swimSegmentTime);
        
        segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
        notifyListeners();
      } else {
        
        if (segmentIndex > 0) {
          final previousSegmentName = segmentOrder[segmentIndex - 1];
          
          
          final previousSegmentList = _cachedSegmentTimes.where(
            (time) => time.participantBibNumber == bibNumber && 
                     time.segmentName == previousSegmentName &&
                     time.endTime != null
          ).toList();
          
          final previousSegment = previousSegmentList.isNotEmpty ? previousSegmentList.first : null;
          
          if (previousSegment != null) {
            
            final segmentTime = SegmentTime(
              participantBibNumber: bibNumber,
              segmentName: normalizedSegmentName,
              startTime: previousSegment.endTime!,
              endTime: now,
            );
            
            
            _cachedSegmentTimes = List.from(_cachedSegmentTimes)..add(segmentTime);
            
            segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
            notifyListeners();
          } else {
            throw Exception('Previous segment must be completed first');
          }
        } else {
          throw Exception('Segment must be started before it can be ended');
        }
      }
      
      
      await _repository.endSegmentTime(bibNumber, segmentName);
    } catch (error) {
      
      if (_hasLoadedInitialData) {
        await fetchSegmentTimes();
      } else {
        segmentTimesValue = AsyncValue.error(error);
        notifyListeners();
      }
      rethrow;
    }
  }
  
  
  Future<void> deleteSegmentTime(String bibNumber, String segmentName) async {
    final normalizedSegmentName = segmentName.toLowerCase();
    
    try {
      
      _cachedSegmentTimes = List.from(_cachedSegmentTimes)
        ..removeWhere((time) => 
            time.participantBibNumber == bibNumber && 
            time.segmentName == normalizedSegmentName);
      
      segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
      notifyListeners();
      
      
      await _repository.deleteSegmentTime(bibNumber, segmentName);
    } catch (error) {
      
      if (_hasLoadedInitialData) {
        await fetchSegmentTimes();
      } else {
        segmentTimesValue = AsyncValue.error(error);
        notifyListeners();
      }
      rethrow;
    }
  }
  
  
  Future<void> fetchSegmentTimes() async {
    try {
      
      if (!_hasLoadedInitialData) {
        segmentTimesValue = const AsyncValue.loading();
        notifyListeners();
      }
      
      final segmentTimes = await _repository.getAllSegmentTimes();
      _cachedSegmentTimes = segmentTimes;
      _hasLoadedInitialData = true;
      segmentTimesValue = AsyncValue.success(segmentTimes);
      notifyListeners();
    } catch (error) {
      if (_hasLoadedInitialData) {
        
        segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
      } else {
        segmentTimesValue = AsyncValue.error(error);
      }
      notifyListeners();
      
    }
  }
  
  
  
  Future<void> assignBibToFinishTime(String bibNumber, String segmentName, DateTime finishTime) async {
    final normalizedSegmentName = segmentName.toLowerCase();
    final isSwimSegment = normalizedSegmentName == 'swim';
    final segmentOrder = ['swim', 'cycle', 'run'];
    final segmentIndex = segmentOrder.indexOf(normalizedSegmentName);
    
    try {
      
      final existingIndex = _cachedSegmentTimes.indexWhere(
        (time) => time.participantBibNumber == bibNumber && 
                 time.segmentName.toLowerCase() == normalizedSegmentName
      );
      
      if (existingIndex != -1) {
        
        throw Exception('Participant already has a time for this segment');
      }
      
      
      if (isSwimSegment) {
        
        DateTime raceStartTime;
        
        
        final existingSwimSegments = _cachedSegmentTimes.where(
          (time) => time.segmentName.toLowerCase() == 'swim' 
        );
        
        if (existingSwimSegments.isNotEmpty) {
          
          raceStartTime = existingSwimSegments.first.startTime;
        } else {
          
          raceStartTime = finishTime.subtract(const Duration(minutes: 30));
        }
        
        
        final swimSegmentTime = SegmentTime(
          participantBibNumber: bibNumber,
          segmentName: 'swim',
          startTime: raceStartTime,
          endTime: finishTime,
        );
        
        
        _cachedSegmentTimes = List.from(_cachedSegmentTimes)..add(swimSegmentTime);
        
      } else {
        
        if (segmentIndex > 0) {
          final previousSegmentName = segmentOrder[segmentIndex - 1];
          
          
          final previousSegment = _cachedSegmentTimes.firstWhere(
            (time) => time.participantBibNumber == bibNumber && 
                     time.segmentName.toLowerCase() == previousSegmentName &&
                     time.endTime != null,
            orElse: () => throw Exception('Previous segment must be completed first')
          );
          
          
          final segmentTime = SegmentTime(
            participantBibNumber: bibNumber,
            segmentName: normalizedSegmentName,
            startTime: previousSegment.endTime!,
            endTime: finishTime,
          );
          
          
          _cachedSegmentTimes = List.from(_cachedSegmentTimes)..add(segmentTime);
          
        } else {
          throw Exception('Segment should be handled as swim segment');
        }
      }
      
      
      segmentTimesValue = AsyncValue.success(_cachedSegmentTimes);
      notifyListeners();
      
      
      await _repository.endSegmentTimeForTwoStep(bibNumber, segmentName, finishTime);
      
    } catch (error) {
      
      if (_hasLoadedInitialData) {
        await fetchSegmentTimes();
      } else {
        segmentTimesValue = AsyncValue.error(error);
        notifyListeners();
      }
      rethrow;
    }
  }
  
  
  Future<List<SegmentTime>> getSegmentTimesBySegment(String segmentName) async {
    return _repository.getSegmentTimesBySegment(segmentName);
  }
  
  
  Future<List<SegmentTime>> getSegmentTimesByParticipant(String bibNumber) async {
    return _repository.getSegmentTimesByParticipant(bibNumber);
  }
  
  @override
  void dispose() {
    _segmentTimesSubscription?.cancel();
    super.dispose();
  }
} 