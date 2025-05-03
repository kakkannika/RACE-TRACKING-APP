import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_traking_app/data/repository/timer_repository.dart';
import 'package:race_traking_app/service/timer_service.dart';
import 'package:race_traking_app/ui/providers/participant_provider.dart';
import 'package:race_traking_app/ui/providers/timer_provider.dart';
import 'package:race_traking_app/ui/screens/participants/crud_participants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ParticipantProvider()),
        ChangeNotifierProvider(create: (context) => TimerProvider(TimerRepository(TimerService()))),
      ],
      child: MaterialApp(
        title: 'Race Tracking App',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF5E64D1),
          ),
        ),
        home:const  ParticipantScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}