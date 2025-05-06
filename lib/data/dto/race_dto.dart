import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/model/race.dart';

class RaceDto {

  static Race fromJson(String id, Map<String, dynamic> json) {
    try {
      DateTime date;
      try {
        date = (json['date'] as Timestamp).toDate();
      } catch (e) {
        date = DateTime.now();
      }
      
      RaceStatus status;
      try {
        int statusIndex = json['status'] as int;
        status = RaceStatus.values[statusIndex];
      } catch (e) {
        status = RaceStatus.notStarted;
      }
      
      DateTime? startTime;
      if (json['startTime'] != null) {
        try {
          startTime = (json['startTime'] as Timestamp).toDate();
        } catch (e) {
        }
      }
      
      DateTime? endTime;
      if (json['endTime'] != null) {
        try {
          endTime = (json['endTime'] as Timestamp).toDate();
        } catch (e) {
        }
      }
      
      List<String> participantBibNumbers;
      try {
        participantBibNumbers = List<String>.from(json['participantBibNumbers'] ?? []);
      } catch (e) {
        participantBibNumbers = [];
      }
      
      Map<String, double> segmentDistances;
      try {
        segmentDistances = Map<String, double>.from(json['segmentDistances'] ?? {});
      } catch (e) {
        segmentDistances = {
          'swim': 1000.0,
          'cycle': 20000.0,
          'run': 5000.0,
        };
      }
      
      return Race(
        date: date,
        status: status,
        startTime: startTime,
        endTime: endTime,
        participantBibNumbers: participantBibNumbers,
        segmentDistances: segmentDistances,
      );
    } catch (e) {
      print("Error parsing race data: $e");
      return Race(
        date: DateTime.now(),
        status: RaceStatus.notStarted,
        participantBibNumbers: [],
      );
    }
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