enum RaceStatus {
  notStarted,
  started,
  finished
}

class Race {
  final String name;
  final DateTime date;
  final RaceStatus status;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String> participantBibNumbers; // References to participants
  final Map<String, double> segmentDistances; // segment name -> distance

  const Race({
    required this.name,
    required this.date,
    this.status = RaceStatus.notStarted,
    this.startTime,
    this.endTime,
    this.participantBibNumbers = const [],
    this.segmentDistances = const {
      'swim': 1000, // meters
      'cycle': 20000, // meters (20km)
      'run': 5000, // meters (5km)
    },
  });

  Race copyWith({
    String? name,
    DateTime? date,
    RaceStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    List<String>? participantBibNumbers,
    Map<String, double>? segmentDistances,
  }) {
    return Race(
      name: name ?? this.name,
      date: date ?? this.date,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      participantBibNumbers: participantBibNumbers ?? this.participantBibNumbers,
      segmentDistances: segmentDistances ?? this.segmentDistances,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Race &&
      other.name == name &&
      other.date == date &&
      other.status == status &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.participantBibNumbers.length == participantBibNumbers.length &&
      other.segmentDistances.length == segmentDistances.length;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      date.hashCode ^
      status.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      participantBibNumbers.hashCode ^
      segmentDistances.hashCode;
  }

  @override
  String toString() {
    return 'Race(name: $name, date: $date, status: $status, startTime: $startTime, endTime: $endTime, participantBibNumbers: $participantBibNumbers, segmentDistances: $segmentDistances)';
  }
} 