import 'package:flutter/foundation.dart';
import 'package:race_traking_app/model/participant.dart';

class ParticipantProvider with ChangeNotifier {
  List<Participant> _participants = [
    Participant(bibNumber: '001', firstName: 'Kannika', lastName: ''),
    Participant(bibNumber: '002', firstName: 'Watey', lastName: ''),
  ];

  List<Participant> get participants => _participants;

  void addParticipant(Participant participant) {
    _participants.add(participant);
    notifyListeners();
  }

  void updateParticipant(String oldBibNumber, Participant updatedParticipant) {
    final index = _participants.indexWhere((p) => p.bibNumber == oldBibNumber);
    if (index != -1) {
      _participants[index] = updatedParticipant;
      notifyListeners();
    }
  }

  void removeParticipant(String bibNumber) {
    _participants
        .removeWhere((participant) => participant.bibNumber == bibNumber);
    notifyListeners();
  }
}
