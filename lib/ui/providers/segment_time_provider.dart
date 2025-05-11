import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/model/segment_time.dart';
import 'package:race_traking_app/ui/providers/async_value.dart';

class SegmentTimeProvider extends ChangeNotifier {
  final SegmentTimeRepository _repository;
  
    AsyncValue<List<SegmentTime>> segmentTimesValue = const AsyncValue.loading();
  AsyncValue<SegmentTime>? segmentTimeValue;
  

  
    dynamic _segmentTimesSubscription;
  
  SegmentTimeProvider({required SegmentTimeRepository repository})
      : _repository = repository {
    subscribeToSegmentTimes();
  }
  
  @override
  void dispose() {
    _segmentTimesSubscription?.cancel();
    super.dispose();
  }
  
  void subscribeToSegmentTimes() {
    segmentTimesValue = const AsyncValue.loading();
    notifyListeners();

    try {
      _segmentTimesSubscription = _repository.getSegmentTimesStream().listen(
        (segmentTimes) {
          segmentTimesValue = AsyncValue.success(segmentTimes);
          notifyListeners();
        },
        onError: (error) {
          segmentTimesValue = AsyncValue.error(error);
          notifyListeners();
        }
      );
    } catch (error) {
      segmentTimesValue = AsyncValue.error(error);
      notifyListeners();
    }
  }
  
  Future<void> fetchSegmentTimes() async {
    segmentTimesValue = const AsyncValue.loading();
    notifyListeners();
    
    try {
      final segmentTimes = await _repository.getAllSegmentTimes();
      segmentTimesValue = AsyncValue.success(segmentTimes);
    } catch (error) {
      segmentTimesValue = AsyncValue.error(error);
    }
    notifyListeners();
  }
  
  Future<List<SegmentTime>> getSegmentTimesBySegment(String segmentName) async {
    try {
      return await _repository.getSegmentTimesBySegment(segmentName);
    } catch (error) {
      segmentTimesValue = AsyncValue.error(error);
      notifyListeners();
      rethrow;
    }
  }
  
  Future<List<SegmentTime>> getSegmentTimesByParticipant(String bibNumber) async {
    try {
      return await _repository.getSegmentTimesByParticipant(bibNumber);
    } catch (error) {
      segmentTimesValue = AsyncValue.error(error);
      notifyListeners();
      rethrow;
    }
  }
  
    Future<void> startSegmentTime(String bibNumber, String segmentName) async {
    try {
      await _repository.startSegmentTime(bibNumber, segmentName);
    } catch (error) {
      segmentTimesValue = AsyncValue.error(error);
      notifyListeners();
      rethrow;
    }
  }
  
    Future<void> endSegmentTime(String bibNumber, String segmentName) async {
    try {
      await _repository.endSegmentTime(bibNumber, segmentName);
    } catch (error) {
      segmentTimesValue = AsyncValue.error(error);
      notifyListeners();
      rethrow;
    }
  }
  
    Future<void> deleteSegmentTime(String bibNumber, String segmentName) async {
    try {
      await _repository.deleteSegmentTime(bibNumber, segmentName);
    } catch (error) {
      segmentTimesValue = AsyncValue.error(error);
      notifyListeners();
      rethrow;
    }
  }
  
    Future<void> assignBibToFinishTime(String bibNumber, String segmentName, DateTime finishTime) async {
    try {
      await _repository.endSegmentTimeForTwoStep(bibNumber, segmentName, finishTime);
    } catch (error) {
      segmentTimesValue = AsyncValue.error(error);
      notifyListeners();
      rethrow;
    }
  }
} 