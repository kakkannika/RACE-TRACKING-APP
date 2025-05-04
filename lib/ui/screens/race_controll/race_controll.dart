import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/ui/providers/timer_provider.dart';
import 'package:race_traking_app/ui/screens/race_controll/widget/controll_buttons.dart';
import 'package:race_traking_app/ui/screens/race_controll/widget/header.dart';
import 'package:race_traking_app/ui/screens/tracking_time/widget/timer_display.dart';
import 'package:race_traking_app/ui/widgets/navBar.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timerProvider, _) {
        return Scaffold(
          body: Column(
            children: [
              // Header
              const Header(),

              // Timer Section
              Expanded(
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Timer Display
                      TimerDisplay(elapsedTime: timerProvider.elapsedTime),

                      const SizedBox(height: 60),

                      // Control Buttons
                      ControlButtons(
                        isRunning: timerProvider.isRunning,
                        onStartPause: () {
                          if (timerProvider.isRunning) {
                            timerProvider.pauseTimer();
                          } else {
                            timerProvider.startTimer();
                          }
                        },
                        onReset: timerProvider.resetTimer,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Custom Navbar
          bottomNavigationBar: const Navbar(selectedIndex: 1),
        );
      },
    );
  }
}
