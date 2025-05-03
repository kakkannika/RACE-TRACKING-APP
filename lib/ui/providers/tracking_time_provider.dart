import 'package:flutter/material.dart';

class TrackingTimeProvider with ChangeNotifier {
  String _selectedSegment = "";

  String get selectedSegment => _selectedSegment;

  Duration? get elapsedTime => null;

  void selectSegment(String segment) {
    _selectedSegment = segment;
    notifyListeners();
  }
}
