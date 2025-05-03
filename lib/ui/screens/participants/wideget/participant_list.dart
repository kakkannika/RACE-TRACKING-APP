import 'package:flutter/material.dart';
import 'package:race_traking_app/model/participant.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class ParticipantList extends StatelessWidget {
  final List<Participant> participants;
  final Function(Participant) onEdit;
  final Function(String) onDelete;

  const ParticipantList({
    Key? key,
    required this.participants,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () => onEdit(participant),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: RaceColors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(participant.bibNumber),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: RaceColors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                        '${participant.firstName} ${participant.lastName}'
                            .trim()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onDelete(participant.bibNumber),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
