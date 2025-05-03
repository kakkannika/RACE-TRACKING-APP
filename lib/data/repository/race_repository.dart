//race repo
import 'package:flutter/material.dart';
import '../../model/participant.dart';

class RaceRepository with ChangeNotifier {
  final List<Participant> _participants = [];

  List<Participant> get participants => List.unmodifiable(_participants);

  void addParticipant(Participant participant) {
    _participants.add(participant);
    notifyListeners();
  }

  void removeParticipant(String bibNumber) {
    _participants.removeWhere((participant) => participant.bibNumber == bibNumber);
    notifyListeners();
  }

  void updateParticipant(String bibNumber, Participant updatedParticipant) {
    final index = _participants.indexWhere((participant) => participant.bibNumber == bibNumber);
    if (index != -1) {
      _participants[index] = updatedParticipant;
      notifyListeners();
    }
  }
}