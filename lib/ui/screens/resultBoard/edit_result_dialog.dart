import 'package:flutter/material.dart';
import 'package:race_traking_app/model/raceResult.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class EditResultDialog extends StatefulWidget {
  final RaceResult result;
  final Function(RaceResult) onSave;

  const EditResultDialog({
    Key? key,
    required this.result,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditResultDialog> createState() => _EditResultDialogState();
}

class _EditResultDialogState extends State<EditResultDialog> {
  late TextEditingController _bibController;
  late TextEditingController _nameController;
  late TextEditingController _cycleController;
  late TextEditingController _runController;
  late TextEditingController _swimController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _bibController = TextEditingController(text: widget.result.bib);
    _nameController = TextEditingController(text: widget.result.name);
    _cycleController = TextEditingController(text: widget.result.cycleTime);
    _runController = TextEditingController(text: widget.result.runTime);
    _swimController = TextEditingController(text: widget.result.swimTime);
    _durationController = TextEditingController(text: widget.result.duration);
  }

  @override
  void dispose() {
    _bibController.dispose();
    _nameController.dispose();
    _cycleController.dispose();
    _runController.dispose();
    _swimController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Result - ${widget.result.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RaceTextField('BIB', _bibController),
            RaceTextField('Name', _nameController),
            RaceTextField('Cycle Time', _cycleController),
            RaceTextField('Run Time', _runController),
            RaceTextField('Swim Time', _swimController),
            RaceTextField('Duration', _durationController),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedResult = RaceResult(
              rank: widget.result.rank,
              bib: _bibController.text,
              name: _nameController.text,
              cycleTime: _cycleController.text,
              runTime: _runController.text,
              swimTime: _swimController.text,
              duration: _durationController.text,
            );
            widget.onSave(updatedResult);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget RaceTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}