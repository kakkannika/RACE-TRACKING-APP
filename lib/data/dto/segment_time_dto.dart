import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/model/segment_time.dart';

class SegmentTimeDto {

  static SegmentTime fromJson(String id, Map<String, dynamic> json) {
    DateTime startTime = DateTime.now();
    if (json['startTime'] != null) {
      startTime = (json['startTime'] as Timestamp).toDate();
    }
    
    DateTime? endTime;
    if (json['endTime'] != null) {
      endTime = (json['endTime'] as Timestamp).toDate();
    }
    
    return SegmentTime(
      participantBibNumber: json['participantBibNumber'] ?? '',
      segmentName: json['segmentName'] ?? '',
      startTime: startTime,
      endTime: endTime,
    );
  }

  static Map<String, dynamic> toJson(SegmentTime segmentTime) {
    return {
      'participantBibNumber': segmentTime.participantBibNumber,
      'segmentName': segmentTime.segmentName,
      'startTime': Timestamp.fromDate(segmentTime.startTime),
      'endTime': segmentTime.endTime != null ? Timestamp.fromDate(segmentTime.endTime!) : null,
    };
  }
} 