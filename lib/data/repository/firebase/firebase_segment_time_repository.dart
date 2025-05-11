import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:race_traking_app/data/dto/segment_time_dto.dart';
import 'package:race_traking_app/data/repository/segment_time_repository.dart';
import 'package:race_traking_app/data/repository/firebase/firebase_race_repository.dart';
import 'package:race_traking_app/model/segment_time.dart';
import 'package:race_traking_app/model/race.dart';

class FirebaseSegmentTimeRepository implements SegmentTimeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseRaceRepository _raceRepository;
  
  final String _collectionPath = 'segmentTimes';
  
  static const List<String> _segmentOrder = ['swim', 'cycle', 'run'];
  
  FirebaseSegmentTimeRepository({
    FirebaseFirestore? firestore,
    FirebaseRaceRepository? raceRepository
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _raceRepository = raceRepository ?? FirebaseRaceRepository();
  
  String _createSegmentTimeId(String bibNumber, String segmentName) {
    return '${bibNumber}_${segmentName.toLowerCase()}';
  }
  
  Future<bool> _isRaceActive() async {
    try {
      final race = await _raceRepository.getCurrentRace();
      return race.status == RaceStatus.started;
    } catch (e) {
      try {
        final raceSnapshot = await _firestore
            .collection('races')
            .where('status', isEqualTo: 1)
            .limit(1)
            .get();
            
        return raceSnapshot.docs.isNotEmpty;
      } catch (innerError) {
        return false;
      }
    }
  }

  @override
  Stream<List<SegmentTime>> getSegmentTimesStream() {
    return _firestore
        .collection(_collectionPath)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs
              .map((doc) => SegmentTimeDto.fromJson(doc.id, doc.data()))
              .toList()
        );
  }

  @override
  Future<List<SegmentTime>> getAllSegmentTimes() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      return querySnapshot.docs.map((doc) => 
        SegmentTimeDto.fromJson(doc.id, doc.data())
      ).toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<List<SegmentTime>> getSegmentTimesBySegment(String segmentName) async {
    try {
      final normalizedSegmentName = segmentName.toLowerCase();
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('segmentName', isEqualTo: normalizedSegmentName)
          .get();
          
      return querySnapshot.docs.map((doc) => 
        SegmentTimeDto.fromJson(doc.id, doc.data())
      ).toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<List<SegmentTime>> getSegmentTimesByParticipant(String bibNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('participantBibNumber', isEqualTo: bibNumber)
          .get();
          
      return querySnapshot.docs.map((doc) => 
        SegmentTimeDto.fromJson(doc.id, doc.data())
      ).toList();
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<SegmentTime> startSegmentTime(String bibNumber, String segmentName) async {
    if (!await _isRaceActive()) {
      throw Exception('Cannot start segment time when race is not active');
    }

    final normalizedSegmentName = segmentName.toLowerCase();
    final currentSegmentIndex = _segmentOrder.indexOf(normalizedSegmentName);
    
    if (currentSegmentIndex == -1) {
      throw Exception('Invalid segment name: $segmentName');
    }

    final docId = _createSegmentTimeId(bibNumber, normalizedSegmentName);
    
    try {
      final docSnapshot = await _firestore
          .collection(_collectionPath)
          .doc(docId)
          .get();
      
      if (docSnapshot.exists) {
        return SegmentTimeDto.fromJson(docId, docSnapshot.data()!);
      }
      
      if (normalizedSegmentName != 'swim') {
        throw Exception('Only the swim segment can be manually started. Other segments start automatically when previous segment ends.');
      }
      
      final segmentTime = SegmentTime(
        participantBibNumber: bibNumber,
        segmentName: normalizedSegmentName,
        startTime: DateTime.now(),
      );
      
      await _firestore
          .collection(_collectionPath)
          .doc(docId)
          .set(SegmentTimeDto.toJson(segmentTime));
      
      return segmentTime;
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<SegmentTime> endSegmentTime(String bibNumber, String segmentName) async {
    if (!await _isRaceActive()) {
      throw Exception('Cannot end segment time when race is not active');
    }

    final normalizedSegmentName = segmentName.toLowerCase();
    final docId = _createSegmentTimeId(bibNumber, normalizedSegmentName);
    final segmentIndex = _segmentOrder.indexOf(normalizedSegmentName);
    
    if (segmentIndex == -1) {
      throw Exception('Invalid segment name: $segmentName');
    }
    
    try {
      final docSnapshot = await _firestore
          .collection(_collectionPath)
          .doc(docId)
          .get();
      
      if (!docSnapshot.exists) {
        if (normalizedSegmentName == 'swim') {
          final raceSnapshot = await _firestore
              .collection('races')
              .where('status', isEqualTo: 1)
              .limit(1)
              .get();
              
          if (raceSnapshot.docs.isEmpty) {
            throw Exception('Cannot find active race');
          }
          
          final raceData = raceSnapshot.docs.first.data();
          final raceStartTime = (raceData['startTime'] as Timestamp).toDate();
          
          final now = DateTime.now();
          final segmentTime = SegmentTime(
            participantBibNumber: bibNumber,
            segmentName: normalizedSegmentName,
            startTime: raceStartTime,
            endTime: now,
          );
          
          await _firestore
              .collection(_collectionPath)
              .doc(docId)
              .set(SegmentTimeDto.toJson(segmentTime));
          
          return segmentTime;
        } else {
          if (segmentIndex > 0) {
            final previousSegmentName = _segmentOrder[segmentIndex - 1];
            final previousDocId = _createSegmentTimeId(bibNumber, previousSegmentName);
            
            final previousDocSnapshot = await _firestore
                .collection(_collectionPath)
                .doc(previousDocId)
                .get();
                
            if (!previousDocSnapshot.exists) {
              throw Exception('Previous segment must be completed first');
            }
            
            final previousSegmentTime = SegmentTimeDto.fromJson(
              previousDocId, 
              previousDocSnapshot.data()!
            );
            
            if (previousSegmentTime.endTime == null) {
              throw Exception('Previous segment must be completed first');
            }
            
            final now = DateTime.now();
            final segmentTime = SegmentTime(
              participantBibNumber: bibNumber,
              segmentName: normalizedSegmentName,
              startTime: previousSegmentTime.endTime!,
              endTime: now,
            );
            
            await _firestore
                .collection(_collectionPath)
                .doc(docId)
                .set(SegmentTimeDto.toJson(segmentTime));
            
            return segmentTime;
          } else {
            throw Exception('Segment must be started before it can be ended');
          }
        }
      } else {
        final existingTime = SegmentTimeDto.fromJson(docId, docSnapshot.data()!);
        
        if (existingTime.endTime != null) {
          return existingTime;
        }
        
        final now = DateTime.now();
        final updatedTime = existingTime.copyWith(
          endTime: now,
        );
        
        await _firestore
            .collection(_collectionPath)
            .doc(docId)
            .update({'endTime': Timestamp.fromDate(now)});
        
        return updatedTime;
      }
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<void> deleteSegmentTime(String bibNumber, String segmentName) async {
    try {
      if (!await _isRaceActive()) {
        throw Exception('Cannot delete segment time when race is not active');
      }

      final normalizedSegmentName = segmentName.toLowerCase();
      final docId = _createSegmentTimeId(bibNumber, normalizedSegmentName);
      
      final docSnapshot = await _firestore
          .collection(_collectionPath)
          .doc(docId)
          .get();
          
      if (!docSnapshot.exists) {
        return;
      }
      
      await _firestore
          .collection(_collectionPath)
          .doc(docId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<SegmentTime> endSegmentTimeForTwoStep(String bibNumber, String segmentName, DateTime finishTime) async {
    try {
      if (!await _isRaceActive()) {
        throw Exception('Cannot end segment time when race is not active');
      }

      final normalizedSegmentName = segmentName.toLowerCase();
      final docId = _createSegmentTimeId(bibNumber, normalizedSegmentName);
      final segmentIndex = _segmentOrder.indexOf(normalizedSegmentName);
      
      if (segmentIndex == -1) {
        throw Exception('Invalid segment name: $segmentName');
      }
      
      final docSnapshot = await _firestore
          .collection(_collectionPath)
          .doc(docId)
          .get();
      
      if (!docSnapshot.exists) {
        if (normalizedSegmentName == 'swim') {
          DateTime raceStartTime;
          
          final race = await _raceRepository.getCurrentRace();
          if (race.startTime != null) {
            raceStartTime = race.startTime!;
          } else {
            final raceSnapshot = await _firestore
                .collection('races')
                .where('status', isEqualTo: 1)
                .limit(1)
                .get();
                
            if (raceSnapshot.docs.isNotEmpty && 
                raceSnapshot.docs.first.data().containsKey('startTime') && 
                raceSnapshot.docs.first.data()['startTime'] != null) {
              raceStartTime = (raceSnapshot.docs.first.data()['startTime'] as Timestamp).toDate();
            } else {
              final swimSegments = await getSegmentTimesBySegment('swim');
              if (swimSegments.isNotEmpty) {
                raceStartTime = swimSegments.first.startTime;
              } else {
                raceStartTime = finishTime.subtract(const Duration(minutes: 30));
              }
            }
          }
          
          final segmentTime = SegmentTime(
            participantBibNumber: bibNumber,
            segmentName: normalizedSegmentName,
            startTime: raceStartTime,
            endTime: finishTime,
          );
          
          await _firestore
              .collection(_collectionPath)
              .doc(docId)
              .set(SegmentTimeDto.toJson(segmentTime));
          
          return segmentTime;
        } else {
          if (segmentIndex > 0) {
            final previousSegmentName = _segmentOrder[segmentIndex - 1];
            final previousDocId = _createSegmentTimeId(bibNumber, previousSegmentName);
            
            final previousDocSnapshot = await _firestore
                .collection(_collectionPath)
                .doc(previousDocId)
                .get();
                
            if (!previousDocSnapshot.exists || 
                !previousDocSnapshot.data()!.containsKey('endTime') ||
                previousDocSnapshot.data()!['endTime'] == null) {
              throw Exception('Previous segment must be completed first');
            }
            
            final previousSegmentTime = SegmentTimeDto.fromJson(
              previousDocId, 
              previousDocSnapshot.data()!
            );
            
            final segmentTime = SegmentTime(
              participantBibNumber: bibNumber,
              segmentName: normalizedSegmentName,
              startTime: previousSegmentTime.endTime!,
              endTime: finishTime,
            );
            
            await _firestore
                .collection(_collectionPath)
                .doc(docId)
                .set(SegmentTimeDto.toJson(segmentTime));
            
            return segmentTime;
          } else {
            throw Exception('Segment must be started before it can be ended');
          }
        }
      } else {
        final existingTime = SegmentTimeDto.fromJson(docId, docSnapshot.data()!);
        
        if (existingTime.endTime != null) {
          return existingTime;
        }
        
        final updatedTime = existingTime.copyWith(endTime: finishTime);
        
        await _firestore
            .collection(_collectionPath)
            .doc(docId)
            .update({'endTime': Timestamp.fromDate(finishTime)});
        
        return updatedTime;
      }
    } catch (e) {
      rethrow;
    }
  }
}