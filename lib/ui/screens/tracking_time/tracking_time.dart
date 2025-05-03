import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/ui/providers/tracking_time_provider.dart';
import 'package:race_traking_app/ui/screens/GridView/test_grid_screen.dart';
import 'package:race_traking_app/ui/screens/tracking_time/widget/segment_button.dart';
import 'package:race_traking_app/ui/screens/tracking_time/widget/select_segments_text.dart';
import 'package:race_traking_app/ui/screens/tracking_time/widget/timer_display.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/navBar.dart';

class TrackingTimeScreen extends StatelessWidget {
  const TrackingTimeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackingTimeProvider(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: RaceColors.primary,
          title: const Text(
            'TRACK TIME',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: Colors.white, 
        body: Consumer<TrackingTimeProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Timer Display
                  TimerDisplay(
                      elapsedTime: provider.elapsedTime ?? Duration.zero),
                  const SizedBox(height: 40),
                  // Select Segments Text
                  const SelectSegmentsText(),
                  const SizedBox(height: 16),
                  // Segment Buttons
                  SegmentButton(
                    segment: "Cycle Segment",
                    isSelected: provider.selectedSegment == "Cycle Segment",
                    onTap: () {
                      provider.selectSegment("Cycle Segment");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ParticipantGrid(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  SegmentButton(
                    segment: "Swim Segment",
                    isSelected: provider.selectedSegment == "Swim Segment",
                    onTap: () => provider.selectSegment("Swim Segment"),
                  ),
                  const SizedBox(height: 8),
                  SegmentButton(
                    segment: "Run Segment",
                    isSelected: provider.selectedSegment == "Run Segment",
                    onTap: () => provider.selectSegment("Run Segment"),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: const Navbar(selectedIndex: 2),
      ),
    );
  }
}
