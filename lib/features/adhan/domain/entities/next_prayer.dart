import 'package:flutter/foundation.dart';

@immutable
class NextPrayer {
  final String name;
  final DateTime time;
  final Duration timeRemaining;
  final bool isToday;

  const NextPrayer({
    required this.name,
    required this.time,
    required this.timeRemaining,
    required this.isToday,
  });

  bool get isReached => timeRemaining.inSeconds <= 0 && timeRemaining.inSeconds >= -5;

  String get formattedRemaining {
    final hours = timeRemaining.inHours.abs().toString().padLeft(2, '0');
    final minutes = (timeRemaining.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final seconds = (timeRemaining.inSeconds.abs() % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
