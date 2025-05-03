import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/model/participant.dart';
import 'package:race_traking_app/ui/providers/participant_provider.dart';
import 'package:race_traking_app/ui/screens/participants/wideget/participant_form.dart';
import 'package:race_traking_app/ui/screens/participants/wideget/participant_header.dart';
import 'package:race_traking_app/ui/screens/participants/wideget/participant_list.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/navBar.dart';

class ParticipantScreen extends StatefulWidget {
  const ParticipantScreen({Key? key}) : super(key: key);

  @override
  State<ParticipantScreen> createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  final TextEditingController _bibController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _editingBibNumber;
  bool _isEditing = false;

  @override
  void dispose() {
    _bibController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _startEditing(Participant participant) {
    setState(() {
      _isEditing = true;
      _editingBibNumber = participant.bibNumber;
      _bibController.text = participant.bibNumber;
      _nameController.text =
          '${participant.firstName} ${participant.lastName}'.trim();
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingBibNumber = null;
      _bibController.clear();
      _nameController.clear();
    });
  }

  void _saveParticipant(ParticipantProvider provider) {
    if (_bibController.text.isNotEmpty && _nameController.text.isNotEmpty) {
      List<String> nameParts = _nameController.text.split(' ');
      String firstName = nameParts.first;
      String lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final newParticipant = Participant(
        bibNumber: _bibController.text,
        firstName: firstName,
        lastName: lastName,
      );

      if (_isEditing && _editingBibNumber != null) {
        provider.updateParticipant(_editingBibNumber!, newParticipant);
        _cancelEditing();
      } else {
        provider.addParticipant(newParticipant);
        _bibController.clear();
        _nameController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = Provider.of<ParticipantProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const ParticipantHeader(), // Header widget
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Participant List',
                    style: RaceTextStyles.subtitle
                        .copyWith(fontFamily: 'YourFontFamily'),
                  ),
                  const SizedBox(height: 16),
                  ParticipantList(
                    participants: participantProvider.participants,
                    onEdit: _startEditing,
                    onDelete: participantProvider.removeParticipant,
                  ),
                  const SizedBox(height: 16),
                  ParticipantForm(
                    isEditing: _isEditing,
                    bibController: _bibController,
                    nameController: _nameController,
                    onSave: () => _saveParticipant(participantProvider),
                    onCancel: _cancelEditing,
                  ),
                ],
              ),
            ),
          ),
          const Navbar(selectedIndex: 0),
        ],
      ),
    );
  }
}
