import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class SelectSegmentsText extends StatelessWidget {
  const SelectSegmentsText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5),
      child: Text(
        'Select Segments',
        style: TextStyle(
          fontSize: RaceTextStyles.body.fontSize ,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}