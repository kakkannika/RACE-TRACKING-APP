import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/dataRow.dart';

class TwoStepListTile extends StatelessWidget {
  final String number;
  final String finishTime;
  final VoidCallback onSelectBib;
  final VoidCallback onReset;
  final bool isSelected;
  final String? selectedBib;

  const TwoStepListTile({
    Key? key,
    required this.number,
    required this.finishTime,
    required this.onSelectBib,
    required this.onReset,
    this.isSelected = false,
    this.selectedBib,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isSelected ? RaceColors.secondary : Colors.transparent,
      child: Row(
        children: [
        SizedBox(width: RaceSpacings.s),
        DataInRow(
          text: number.padLeft(2, '0'),
          flex: 1,
        ),
        DataInRow(
          text: finishTime,
          flex: 2,
        ),
        Expanded(
          flex: 2,
          child: TextButton(
            onPressed: onSelectBib,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              textStyle: const TextStyle(fontSize: 14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedBib == null ? 'Enter BIB' : 'BIB: $selectedBib',
                  style: TextStyle(
                    color: selectedBib == null ? RaceColors.primary : RaceColors.black,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 14, color: RaceColors.primary),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: RaceSpacings.s),
          onPressed: onReset,
          color: RaceColors.primary,
        ),
        const SizedBox(width: RaceSpacings.s),
      ],
      ),
    );
  }
}
