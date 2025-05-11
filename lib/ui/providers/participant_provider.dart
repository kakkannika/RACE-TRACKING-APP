import 'package:flutter/foundation.dart';
import 'package:race_traking_app/data/repository/participant_repository.dart';
import 'package:race_traking_app/data/repository/mock/mock_participant_repository.dart';
import 'package:race_traking_app/model/participant.dart';
import 'package:race_traking_app/ui/providers/async_value.dart';

class ParticipantProvider extends ChangeNotifier {
  final ParticipantRepository _repository;
  final bool _isMockRepository;
  
    AsyncValue<List<Participant>> participantsValue = const AsyncValue.loading();
  AsyncValue<Participant>? participantValue;
  
  dynamic _participantsSubscription;

  ParticipantProvider(this._repository)
    : _isMockRepository = _repository is MockParticipantRepository {
    if (_isMockRepository) {
      fetchParticipants();
    } else {
      subscribeToParticipants();
    }
  }

  @override
  void dispose() {
    if (_participantsSubscription != null) {
      _participantsSubscription.cancel();
    }
    super.dispose();
  }

  void subscribeToParticipants() {
    participantsValue = const AsyncValue.loading();
    notifyListeners();

    try {
      _participantsSubscription = _repository.getParticipantsStream().listen(
        (participants) {
          participantsValue = AsyncValue.success(participants);
          notifyListeners();
        },
        onError: (error) {
          participantsValue = AsyncValue.error(error);
          notifyListeners();
        }
      );
    } catch (error) {
      participantsValue = AsyncValue.error(error);
      notifyListeners();
    }
  }

  Future<void> fetchParticipants() async {
    participantsValue = const AsyncValue.loading();
    notifyListeners();
    
    try {
      final participants = await _repository.getAllParticipants();
      participantsValue = AsyncValue.success(participants);
    } catch (error) {
      participantsValue = AsyncValue.error(error);
    }
    notifyListeners();
  }

  Future<void> getParticipantByBib(String bibNumber) async {
    participantValue = const AsyncValue.loading();
    notifyListeners();

    try {
      final participant = await _repository.getParticipantByBib(bibNumber);
      participantValue = AsyncValue.success(participant);
    } catch (error) {
      participantValue = AsyncValue.error(error);
    }
    notifyListeners();
  }

  Future<void> addParticipant(Participant participant) async {
    try {
      await _repository.addParticipant(participant);
      
            if (_isMockRepository) {
        await fetchParticipants();
      }
    } catch (error) {
      participantsValue = AsyncValue.error(error);
      notifyListeners();
    }
  }

  Future<void> updateParticipant(Participant participant) async {
    try {
      await _repository.updateParticipant(participant);
      
            if (_isMockRepository) {
        await fetchParticipants();
      }
      
            if (participantValue != null && 
          participantValue!.isSuccess && 
          participantValue!.data!.bibNumber == participant.bibNumber) {
        participantValue = AsyncValue.success(participant);
        notifyListeners();
      }
    } catch (error) {
            participantsValue = AsyncValue.error(error);
      notifyListeners();
    }
  }

  Future<void> deleteParticipant(String bibNumber) async {
    try {
      await _repository.deleteParticipant(bibNumber);
      
            if (_isMockRepository) {
        await fetchParticipants();
      }
      
            if (participantValue != null && 
          participantValue!.isSuccess && 
          participantValue!.data!.bibNumber == bibNumber) {
        participantValue = null;
        notifyListeners();
      }
    } catch (error) {
      participantsValue = AsyncValue.error(error);
      notifyListeners();
    }
  }

  Future<void> renumberParticipants() async {
    if (!participantsValue.isSuccess || participantsValue.data!.isEmpty) return;
    
    try {
      final participants = List<Participant>.from(participantsValue.data!);
      
      participants.sort((a, b) {
        final aNum = int.tryParse(a.bibNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bNum = int.tryParse(b.bibNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aNum.compareTo(bNum);
      });
      
      final updates = <Future<void>>[];
      
      for (int i = 0; i < participants.length; i++) {
        final newBibNumber = (i + 1).toString().padLeft(3, '0');
        final participant = participants[i];
        
        if (participant.bibNumber != newBibNumber) {
          final updatedParticipant = Participant(
            bibNumber: newBibNumber,
            firstName: participant.firstName,
            lastName: participant.lastName,
            age: participant.age,
            gender: participant.gender,
          );
          
          updates.add(_repository.updateParticipant(updatedParticipant));
        }
      }
      
      if (updates.isNotEmpty) {
        await Future.wait(updates);
        
        if (_isMockRepository) {
          await fetchParticipants();
        }
      }
    } catch (error) {
      participantsValue = AsyncValue.error(error);
      notifyListeners();
    }
  }
}
