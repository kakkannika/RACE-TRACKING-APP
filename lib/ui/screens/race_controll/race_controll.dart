import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/model/race.dart';
import 'package:race_traking_app/ui/providers/race_provider.dart';
import 'package:race_traking_app/ui/providers/participant_provider.dart';
import 'package:race_traking_app/ui/screens/race_controll/widget/controll_buttons.dart';
import 'package:race_traking_app/ui/widgets/time_display.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/navBar.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<RaceProvider, ParticipantProvider>(
      builder: (context, raceProvider, participantProvider, child) {
        final raceState = raceProvider.currentRace;
        final participantsState = participantProvider.participantsValue;
        
        if (raceState == null || raceState.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (raceState.isError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Error loading race data'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => raceProvider.fetchCurrentRace(),
                    child: const Text('Retry'),
                  )
                ],
              ),
            ),
          );
        }

        final race = raceState.data!;
        
        bool hasParticipants = false;
        if (participantsState.isSuccess) {
          hasParticipants = participantsState.data?.isNotEmpty ?? false;
        }
        
        final bool isRaceActive = race.status == RaceStatus.started;
        final bool isRaceFinished = race.status == RaceStatus.finished;
        
        return Scaffold(
          body: Column(
            children: [
              _buildCustomHeader(),

              Expanded(
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      _buildRaceStatus(race, hasParticipants),

                      if (!hasParticipants && race.status == RaceStatus.notStarted)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.amber,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Add participants to start the race',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      TimerDisplay(
                        isRunning: isRaceActive,
                      ),

                      const SizedBox(height: 40),

                      ControlButtons(
                        isRunning: isRaceActive,
                        startButtonEnabled: !isRaceFinished,
                        onStartFinish: () async {
                          if (isRaceActive) {
                            raceProvider.finishRace();
                          } else if (!isRaceFinished) {
                            try {
                              await raceProvider.startRace();
                            } catch (error) {
                              if (error.toString().contains('Cannot start race without participants')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Cannot start race without participants. Please add participants first.'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to start race: ${error.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        onReset: () {
                          raceProvider.resetRace();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          bottomNavigationBar: const Navbar(selectedIndex: 1),
        );
      },
    );
  }

  

  Widget _buildCustomHeader() {
    return Container(
      width: double.infinity,
      color: RaceColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const Text(
        'RACE CONTROL',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildRaceStatus(Race race, bool hasParticipants) {
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    switch (race.status) {
      case RaceStatus.notStarted:
        if (!hasParticipants) {
          statusText = 'Race Not Started';
          statusColor = Colors.grey;
        } else {
          statusText = 'Race Ready';
          statusColor = Colors.blue;
        }
        statusIcon = Icons.timer;
        break;
      case RaceStatus.started:
        statusText = 'Race Active';
        statusColor = Colors.green;
        statusIcon = Icons.play_circle_fill;
        break;
      case RaceStatus.finished:
        statusText = 'Race Finished';
        statusColor = Colors.orange;
        statusIcon = Icons.flag;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
