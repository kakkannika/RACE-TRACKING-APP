import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/model/race.dart';

class RaceDto {

  static Race fromJson(String id, Map<String, dynamic> json) {
    DateTime date = DateTime.now();
    if (json['date'] != null) {
      date = (json['date'] as Timestamp).toDate();
    }
    
    RaceStatus status = RaceStatus.notStarted;
    if (json['status'] != null) {
      status = RaceStatus.values[json['status'] as int];
    }
    
    DateTime? startTime;
    if (json['startTime'] != null) {
      startTime = (json['startTime'] as Timestamp).toDate();
    }
    
    DateTime? endTime;
    if (json['endTime'] != null) {
      endTime = (json['endTime'] as Timestamp).toDate();
    }
    
    List<String> participantBibNumbers = [];
    if (json['participantBibNumbers'] != null) {
      participantBibNumbers = List<String>.from(json['participantBibNumbers']);
    }
    
    Map<String, double> segmentDistances = {
      'swim': 1000.0,
      'cycle': 20000.0,
      'run': 5000.0,
    };
    if (json['segmentDistances'] != null) {
      segmentDistances = Map<String, double>.from(json['segmentDistances']);
    }
    
    return Race(
      date: date,
      status: status,
      startTime: startTime,
      endTime: endTime,
      participantBibNumbers: participantBibNumbers,
      segmentDistances: segmentDistances,
    );
  }

  static Map<String, dynamic> toJson(Race race) {
    return {
      'date': Timestamp.fromDate(race.date),
      'status': race.status.index,
      'startTime': race.startTime != null ? Timestamp.fromDate(race.startTime!) : null,
      'endTime': race.endTime != null ? Timestamp.fromDate(race.endTime!) : null,
      'participantBibNumbers': race.participantBibNumbers,
      'segmentDistances': race.segmentDistances,
    };
  }
  
}