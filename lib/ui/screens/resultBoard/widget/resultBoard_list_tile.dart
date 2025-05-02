// The ResultListTile component
import 'package:flutter/material.dart';
import 'package:race_traking_app/model/raceResult.dart';
import 'package:race_traking_app/ui/screens/resultBoard/edit_result_dialog.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/dataRow.dart';

class ResultListTile extends StatelessWidget {
  final RaceResult result;
  final bool isEven;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  

  const ResultListTile({
    Key? key,
    required this.result,
    this.isEven = false,
    this.onEdit,
    this.onDelete,
   
  }) : super(key: key);


  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Result - ${result.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RaceEditField('BIB', result.bib),
                RaceEditField('Name', result.name),
                RaceEditField('Cycle Time', result.cycleTime),
                RaceEditField('Run Time', result.runTime),
                RaceEditField('Swim Time', result.swimTime),
                RaceEditField('Duration', result.duration),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement save functionality
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget RaceEditField(String label, String initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: TextEditingController(text: initialValue),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      //when the user taps on the tile, show the edit dialog
      onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return EditResultDialog(
            result: result,
            onSave: (updatedResult) {
              // TODO: Implement save functionality in parent widget
              if (onEdit != null) onEdit!();
            },
          );
        },
      );
    },
    //when the user long presses on the tile, show the delete confirmation dialog
     onLongPress: () {
        // Show delete confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Result'),
              content: Text('Are you sure you want to delete ${result.name}\'s result?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onDelete != null) onDelete!();
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: 1000,
        color: isEven ? RaceColors.secondary : RaceColors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              DataInRow(text: result.rank.toString(), flex: 1),
              DataInRow(text: result.bib, flex: 1),
              DataInRow(text: result.name, flex: 1),
              DataInRow(text: result.cycleTime, flex: 2),
              DataInRow(text: result.runTime, flex: 2),
              DataInRow(text: result.swimTime, flex: 2),
              DataInRow(text: result.duration, flex: 2),
            ],
          ),
        ),
      ),
    );
  }

 
}

