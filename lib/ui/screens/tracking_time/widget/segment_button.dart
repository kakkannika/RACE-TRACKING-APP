import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class SegmentButton extends StatelessWidget {
  final String segment;
  final bool isSelected;
  final VoidCallback onTap;

  const SegmentButton({
    Key? key,
    required this.segment,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: isSelected ? RaceColors.secondary : RaceColors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RaceSpacings.radius),
          child: Center(
            child: Text(
              segment,
              style: TextStyle(
                fontSize: RaceTextStyles.body.fontSize,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                color: RaceColors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}