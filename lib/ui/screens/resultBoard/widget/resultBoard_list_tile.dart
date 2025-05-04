// The ResultListTile component
import 'package:flutter/material.dart';
import 'package:race_traking_app/model/raceResult.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/dataRow.dart';

class ResultListTile extends StatelessWidget {
  final RaceResult result;
  final bool isEven;
  final VoidCallback? onTap;
  

  const ResultListTile({
    Key? key,
    required this.result,
    this.isEven = false,
    this.onTap,
   
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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

