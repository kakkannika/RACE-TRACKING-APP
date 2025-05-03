import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/ui/providers/tracking_time_provider.dart';
import 'package:race_traking_app/ui/screens/Views/race_segment_screen.dart';
import 'package:race_traking_app/ui/screens/tracking_time/widget/segment_button.dart';
import 'package:race_traking_app/ui/screens/tracking_time/widget/select_segments_text.dart';
import 'package:race_traking_app/ui/screens/tracking_time/widget/timer_display.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/navBar.dart';

class TrackingTimeScreen extends StatelessWidget {
  const TrackingTimeScreen({Key? key}) : super(key: key);

  Widget _buildSegmentButton(
    BuildContext context,
    TrackingTimeProvider provider,
    String segmentName,
  ) {
    return SegmentButton(
      segment: segmentName,
      isSelected: provider.selectedSegment == segmentName,
      onTap: () {
        provider.selectSegment(segmentName);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RaceTrackingScreen(
              segment: segmentName.split(' ')[0],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackingTimeProvider(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: RaceColors.primary,
          title: Text(
            'TRACK TIME',
            style: TextStyle(
              color: RaceColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: RaceColors.white,
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
                    elapsedTime: provider.elapsedTime ?? Duration.zero
                  ),
                  const SizedBox(height: 40),
                  // Select Segments Text
                  const SelectSegmentsText(),
                  const SizedBox(height: 16),
                  // Segment Buttons
                  _buildSegmentButton(
                    context,
                    provider,
                    "Cycle Segment"
                  ),
                  const SizedBox(height: 8),
                  _buildSegmentButton(
                    context,
                    provider,
                    "Swim Segment"
                  ),
                  const SizedBox(height: 8),
                  _buildSegmentButton(
                    context,
                    provider,
                    "Run Segment"
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