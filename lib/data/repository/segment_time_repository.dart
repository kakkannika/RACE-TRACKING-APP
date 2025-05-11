import 'package:race_traking_app/model/segment_time.dart';

abstract class SegmentTimeRepository {
    Future<List<SegmentTime>> getAllSegmentTimes();
  
    Future<List<SegmentTime>> getSegmentTimesBySegment(String segmentName);
  
    Future<List<SegmentTime>> getSegmentTimesByParticipant(String bibNumber);
  
    Future<SegmentTime> startSegmentTime(String bibNumber, String segmentName);
  
    Future<SegmentTime> endSegmentTime(String bibNumber, String segmentName);
  
    Future<SegmentTime> endSegmentTimeForTwoStep(String bibNumber, String segmentName, DateTime finishTime);
  
    Future<void> deleteSegmentTime(String bibNumber, String segmentName);
  
    Stream<List<SegmentTime>> getSegmentTimesStream();
} 