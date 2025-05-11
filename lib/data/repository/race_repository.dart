import 'package:race_traking_app/model/race.dart';

abstract class RaceRepository {
    Future<Race> getCurrentRace();
  
    Stream<Race> getRaceStream();
  
    Future<void> startRace();
  
    Future<void> finishRace();
  
    Future<void> resetRace();
  

}