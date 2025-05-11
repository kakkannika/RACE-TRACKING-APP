import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/ui/screens/view_segment/2step/widget/TwoStep_list_tile.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/headerRow.dart';
import 'package:race_traking_app/ui/providers/segment_time_provider.dart';
import 'package:race_traking_app/ui/providers/race_provider.dart';
import 'package:race_traking_app/ui/providers/participant_provider.dart';
import 'package:race_traking_app/utils/timestamp_formatter.dart';

class TwoStepView extends StatefulWidget {
  final String segment;
  const TwoStepView({Key? key, required this.segment}) : super(key: key);

  @override
  State<TwoStepView> createState() => _TwoStepViewState();
}

class _TwoStepViewState extends State<TwoStepView> {
  int? selectedIndex;
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  final List<DateTime> finishTimes = [];
  final Map<DateTime, String> assignedBibs = {};

  @override
  void initState() {
    super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
      final timeProvider = Provider.of<SegmentTimeProvider>(context, listen: false);
      timeProvider.fetchSegmentTimes();
      final participantProvider = Provider.of<ParticipantProvider>(context, listen: false);
      participantProvider.fetchParticipants();
    });
  }

  void _markTime() {
        setState(() {
      finishTimes.add(DateTime.now());
    });
  }

  Future<void> _showBibSelectionDialog(int index) async {
    if (index >= finishTimes.length) return;
    
    final finishTime = finishTimes[index];
    
        final usedBibs = assignedBibs.values.toSet();

    final selectedBib = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select BIB number'),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, size: 32, color: RaceColors.black),
            ),
          ],
        ),
        backgroundColor: RaceColors.white,
        content: SizedBox(
          width: 300,
          height: 250,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 9,
            itemBuilder: (context, gridIndex) {
              final bibNumber = (gridIndex + 1).toString().padLeft(3, '0');
              final isUsed = usedBibs.contains(bibNumber);

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUsed ? RaceColors.disabled : RaceColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RaceSpacings.radius),
                  ),
                ),
                onPressed: isUsed ? null : () => Navigator.pop(context, bibNumber),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bibNumber,
                      style: TextStyle(
                        fontSize: RaceTextStyles.body.fontSize,
                        fontWeight: FontWeight.bold,
                        color: RaceColors.white,
                      ),
                    ),
                    Text(
                      'Finish',
                      style: TextStyle(
                        fontSize: RaceTextStyles.label.fontSize,
                        color: RaceColors.white
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    if (selectedBib != null) {
            final provider = Provider.of<SegmentTimeProvider>(context, listen: false);
      try {
        await provider.assignBibToFinishTime(selectedBib, widget.segment, finishTime);
        
        setState(() {
          selectedIndex = index;
          assignedBibs[finishTime] = selectedBib;
        });
        
                if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('BIB $selectedBib successfully assigned')),
          );
        }
      } catch (e) {
                if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _resetSelection(DateTime finishTime) {
    setState(() {
      assignedBibs.remove(finishTime);
            if (selectedIndex != null && selectedIndex! < finishTimes.length && 
          finishTimes[selectedIndex!] == finishTime) {
        selectedIndex = null;
      }
    });
  }

  String _formatFinishTime(DateTime time) {
    return TimestampFormatter.formatTimestamp(time);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SegmentTimeProvider, RaceProvider, ParticipantProvider>(
      builder: (context, timeProvider, raceProvider, participantProvider, child) {
        final segmentTimesValue = timeProvider.segmentTimesValue;
        final raceState = raceProvider.currentRaceValue;
        final participantsState = participantProvider.participantsValue;
        
                if (segmentTimesValue.isLoading || raceState.isLoading || participantsState.isLoading) {
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
        
                
                final int totalItems = finishTimes.length;
        final int totalPages = (totalItems / _itemsPerPage).ceil();
        
                List<DateTime> currentPageItems = [];
        if (finishTimes.isNotEmpty) {
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex = startIndex + _itemsPerPage;
          currentPageItems = finishTimes.sublist(
            startIndex,
            endIndex > finishTimes.length ? finishTimes.length : endIndex
          );
        }
        
        return Column(
          children: [
                        ElevatedButton(
              onPressed: _markTime,
              style: ElevatedButton.styleFrom(
                backgroundColor: RaceColors.primary,
                foregroundColor: RaceColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RaceSpacings.radius),
                ),
              ),
              child: Text('Mark Time',
                  style: TextStyle(fontSize: RaceTextStyles.subtitle.fontSize)),
            ),
            
            const SizedBox(height: RaceSpacings.xs),
            
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
                                selectedIndex = null;
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
                              selectedIndex = null;
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
                                selectedIndex = null;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),

                        const Padding(
              padding: EdgeInsets.symmetric(horizontal: RaceSpacings.xs),
              child: Row(
                children: [
                  HeaderRow(title: 'Finish Time', flex: 3),
                  HeaderRow(title: 'BIB', flex: 3),
                  SizedBox(width: 50),
                ],
              ),
            ),
            const Divider(),

                        Expanded(
              child: finishTimes.isEmpty 
                ? const Center(child: Text('No finish times recorded yet'))
                : ListView.builder(
                  itemCount: currentPageItems.length,
                  itemBuilder: (context, index) {
                    final actualIndex = _currentPage * _itemsPerPage + index;
                    final finishTime = currentPageItems[index];
                    final formattedTime = _formatFinishTime(finishTime);
                    final assignedBib = assignedBibs[finishTime];
                    
                    return TwoStepListTile(
                      finishTime: formattedTime,
                      isSelected: actualIndex == selectedIndex,
                      selectedBib: assignedBib,
                      onSelectBib: () => _showBibSelectionDialog(actualIndex),
                      onReset: () => _resetSelection(finishTime),
                    );
                  },
                ),
            ),
          ],
        );
      },
    );
  }
}