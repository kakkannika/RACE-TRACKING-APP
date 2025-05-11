import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/screens/view_segment/GridView/grid_screen.dart';
import 'package:race_traking_app/ui/screens/view_segment/2step/twoStep_screen.dart';
import 'package:race_traking_app/ui/providers/segment_time_provider.dart';
import 'package:race_traking_app/ui/providers/race_provider.dart';
import 'package:race_traking_app/ui/providers/participant_provider.dart';
import 'package:race_traking_app/ui/widgets/time_display.dart';
import 'package:race_traking_app/model/race.dart';

class RaceTrackingScreen extends StatefulWidget {
  final String segment;

  const RaceTrackingScreen({
    Key? key,
    required this.segment,
  }) : super(key: key);

  @override
  State<RaceTrackingScreen> createState() => _RaceTrackingScreenState();
}

class _RaceTrackingScreenState extends State<RaceTrackingScreen> {
  int _selectedIndex = 0;
  late String _segment;
  
  @override
  void initState() {
    super.initState();
    _segment = widget.segment;
    
        WidgetsBinding.instance.addPostFrameCallback((_) {
      final segmentProvider = Provider.of<SegmentTimeProvider>(context, listen: false);
      final participantProvider = Provider.of<ParticipantProvider>(context, listen: false);
      segmentProvider.fetchSegmentTimes();
      participantProvider.fetchParticipants();
    });
  }

  @override
  Widget build(BuildContext context) {
    final segmentTimeProvider = Provider.of<SegmentTimeProvider>(context, listen: false);
    
        final twoStepKey = ValueKey<int>(segmentTimeProvider.hashCode + DateTime.now().microsecondsSinceEpoch);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: RaceColors.primary,
        centerTitle: true,
        title: Text(
          '$_segment Segment', 
          style: TextStyle(color: RaceColors.white, fontSize: RaceTextStyles.subtitle.fontSize),
        ),
        leading: BackButton(color: RaceColors.white),
      ),
      body: Column(
        children: [
                    Consumer<RaceProvider>(
            builder: (context, raceProvider, _) {
              final raceState = raceProvider.currentRaceValue;
              bool isRaceActive = false;
              
              if (raceState.data != null) {
                isRaceActive = raceState.data!.status == RaceStatus.started;
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(vertical: RaceSpacings.xs),
                child: Column(
                  children: [
                    const SizedBox(height: RaceSpacings.xs),
                    TimerDisplay(
                      isRunning: isRaceActive,
                      onTick: null,
                    ),
                  ],
                ),
              );
            }
          ),

                    Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildTabButton(
                  title: 'Grid View',
                  index: 0,
                ),
                _buildTabButton(
                  title: '2-Step View',
                  index: 1,
                ),
              ],
            ),
          ),

                    Expanded(
            child: Consumer2<SegmentTimeProvider, ParticipantProvider>(
              builder: (context, segmentTimeProvider, participantProvider, _) {
                final segmentTimesValue = segmentTimeProvider.segmentTimesValue;
                final participantsValue = participantProvider.participantsValue;
                
                                if (segmentTimesValue.isLoading || participantsValue.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                                if (segmentTimesValue.isError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${segmentTimesValue.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => segmentTimeProvider.fetchSegmentTimes(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (participantsValue.isError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading participants: ${participantsValue.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => participantProvider.fetchParticipants(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                                return IndexedStack(
                  index: _selectedIndex,
                  children: [
                    ParticipantGrid(
                      segmentName: _segment,
                      onTimeRecorded: () {
                                                segmentTimeProvider.fetchSegmentTimes();
                                                setState(() {});
                      },
                    ),
                    TwoStepView(
                      key: twoStepKey,
                      segment: _segment
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? RaceColors.primary : RaceColors.darkGrey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              color: isSelected ? RaceColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}