import 'dart:async';
import 'package:flutter/material.dart';

class TimerProvider extends ChangeNotifier {
  int _secondsRemaining = 60;
  bool _isRunning = false;
  bool _isExpired = false;
  Timer? _timer;

  int get secondsRemaining => _secondsRemaining;
  bool get isRunning => _isRunning;
  bool get isExpired => _isExpired;
  bool get isUrgent => _secondsRemaining <= 10;

  void start(int seconds) {
    _secondsRemaining = seconds;
    _isRunning = true;
    _isExpired = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
    notifyListeners();
  }

  void tick() {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
      notifyListeners();
    } else {
      _isRunning = false;
      _isExpired = true;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _secondsRemaining = 60;
    _isRunning = false;
    _isExpired = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
