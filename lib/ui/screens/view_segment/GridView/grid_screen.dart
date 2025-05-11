import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/screens/view_segment/GridView/widget/BIB_Button.dart';
import 'package:race_traking_app/ui/providers/segment_time_provider.dart';
import 'package:race_traking_app/ui/providers/race_provider.dart';
import 'package:race_traking_app/ui/providers/participant_provider.dart';
import 'package:race_traking_app/model/segment_time.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/utils/timestamp_formatter.dart';

class ParticipantGrid extends StatefulWidget {
  final String segmentName;
  final VoidCallback? onTimeRecorded;

  const ParticipantGrid({
    Key? key,
    this.segmentName = 'Segment',
    this.onTimeRecorded,
  }) : super(key: key);

  @override
  State<ParticipantGrid> createState() => _ParticipantGridState();
}

class _ParticipantGridState extends State<ParticipantGrid> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  
  @override
  void initState() {
    super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SegmentTimeProvider>(context, listen: false);
      provider.fetchSegmentTimes();
    });
  }

    Future<void> _handleSegmentTracking(
      String bibNumber, SegmentTimeProvider provider) async {
    try {
            final times = await provider.getSegmentTimesByParticipant(bibNumber);
      
            final normalizedSegmentName = widget.segmentName.toLowerCase();
      final segmentOrder = ['swim', 'cycle', 'run'];
      final segmentIndex = segmentOrder.indexOf(normalizedSegmentName);
      
            final currentSegmentTime = times
          .where((time) => time.segmentName.toLowerCase() == normalizedSegmentName)
          .firstOrNull;
      
            if (currentSegmentTime != null && currentSegmentTime.endTime != null) {
                if (segmentIndex < segmentOrder.length - 1) {
          final laterSegments = segmentOrder.sublist(segmentIndex + 1);
          
          for (final laterSegmentName in laterSegments) {
            final laterSegmentExists = times.any((time) => 
                time.segmentName.toLowerCase() == laterSegmentName && 
                time.endTime != null);
            
            if (laterSegmentExists) {
              throw Exception('Cannot delete a segment when later segments exist');
            }
          }
        }
        
        await provider.deleteSegmentTime(bibNumber, normalizedSegmentName);
                if (widget.onTimeRecorded != null) {
          widget.onTimeRecorded!();
        }
        return;
      }
      
            if (segmentIndex > 0) {
                final previousSegmentName = segmentOrder[segmentIndex - 1];
        final previousSegmentCompleted = times.any((time) => 
            time.segmentName.toLowerCase() == previousSegmentName && 
            time.endTime != null);
        
        if (!previousSegmentCompleted) {
          throw Exception('Previous segment must be completed first');
        }
      }
      
            await provider.endSegmentTime(bibNumber, normalizedSegmentName);
      
            if (widget.onTimeRecorded != null) {
        widget.onTimeRecorded!();
      }
    } catch (e) {
            if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  String? _getTimestamp(SegmentTime? time) {
    return TimestampFormatter.getTimestampFromSegment(time);
  }

    String _getPageRange(int totalItems) {
    final start = (_currentPage * _itemsPerPage) + 1;
    final end = (_currentPage + 1) * _itemsPerPage;
    return '$start-${end > totalItems ? totalItems : end}';
  }

    int _getItemCount(int totalItems, int totalPages) {
    if (_currentPage == totalPages - 1) {
      final remainingItems = totalItems % _itemsPerPage;
      return remainingItems == 0 ? _itemsPerPage : remainingItems;
    }
    return _itemsPerPage;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SegmentTimeProvider, RaceProvider, ParticipantProvider>(
      builder:
          (context, timeProvider, raceProvider, participantProvider, child) {
        final segmentTimesValue = timeProvider.segmentTimesValue;
        final raceState = raceProvider.currentRaceValue;
        final participantsState = participantProvider.participantsValue;

                if (segmentTimesValue.isLoading ||
            raceState.isLoading ||
            participantsState.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading data...'),
              ],
            ),
          );
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
                  onPressed: () => timeProvider.fetchSegmentTimes(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (raceState.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error loading race data'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => raceProvider.fetchCurrentRace(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (participantsState.isError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error loading participants data'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => participantProvider.fetchParticipants(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final segmentTimes = segmentTimesValue.data ?? [];
        final race = raceState.data!;
        final participants = participantsState.data ?? [];

                final List<String> participantBibNumbers =
            participants.map((p) => p.bibNumber).toList();
        
                final int totalItems = participantBibNumbers.length;
        final int totalPages = (totalItems / _itemsPerPage).ceil();

                Duration elapsedTime = Duration.zero;
        bool isRaceActive = false;

        if (race.startTime != null) {
          final DateTime endTime = race.status == RaceStatus.finished
              ? (race.endTime ?? DateTime.now())
              : DateTime.now();

          elapsedTime = endTime.difference(race.startTime!);
        }

        isRaceActive = race.status == RaceStatus.started;

        return Column(
          children: [
                                    Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Participants: $totalItems',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
                        if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                    ),
                                        ...List.generate(
                      totalPages > 7 ? 7 : totalPages,
                      (index) {
                                                int pageToDisplay = index;
                        if (totalPages > 7 && _currentPage > 3) {
                                                    pageToDisplay = _currentPage + index - 3;
                          if (pageToDisplay >= totalPages) {
                            pageToDisplay = totalPages - (7 - index);
                          }
                        }
                        
                        final isCurrentPage = pageToDisplay == _currentPage;
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentPage = pageToDisplay;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isCurrentPage ? RaceColors.primary : Colors.transparent,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                pageToDisplay.toString(),
                                style: TextStyle(
                                  color: isCurrentPage ? Colors.white : Colors.black,
                                  fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < totalPages - 1
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              
                        Expanded(
              child: participantBibNumbers.isEmpty
                ? const Center(child: Text('No participants found'))
                : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _getItemCount(totalItems, totalPages),
                    itemBuilder: (context, index) {
                      final actualIndex = _currentPage * _itemsPerPage + index;
                                            if (actualIndex >= totalItems) {
                        return const SizedBox.shrink();
                      }
                      
                      final bibNumber = participantBibNumbers[actualIndex];

                                            final participantTime = segmentTimes
                          .where((time) =>
                              time.participantBibNumber == bibNumber &&
                              time.segmentName.toLowerCase() ==
                                  widget.segmentName.toLowerCase())
                          .firstOrNull;

                                            final bool isCompleted = participantTime != null &&
                          participantTime.endTime != null;

                      return ParticipantButton(
                        id: bibNumber,
                        isActive: isCompleted,
                        timestamp: _getTimestamp(participantTime),
                        onTap: () => _handleSegmentTracking(bibNumber, timeProvider),
                      );
                    },
                  ),
                ),
            ),
          ],
        );
      },
    );
  }
}
