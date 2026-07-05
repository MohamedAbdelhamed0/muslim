import 'package:flutter/foundation.dart';
import 'next_prayer.dart';

@immutable
class PrayerTimesEntity {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String dateReadable;
  final String city;
  final String country;

  const PrayerTimesEntity({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.dateReadable,
    required this.city,
    required this.country,
  });

  Map<String, DateTime> toMap() {
    return {
      'Fajr': fajr,
      'Sunrise': sunrise,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
  }

  /// Calculates the next upcoming prayer relative to [currentTime]
  NextPrayer getNextPrayer(DateTime currentTime) {
    final prayers = toMap();

    // Check today's prayers
    for (final entry in prayers.entries) {
      if (entry.value.isAfter(currentTime)) {
        final remaining = entry.value.difference(currentTime);
        return NextPrayer(
          name: entry.key,
          time: entry.value,
          timeRemaining: remaining,
          isToday: true,
        );
      }
    }

    // If all today's prayers have passed, next prayer is Fajr tomorrow
    final tomorrowFajr = fajr.add(const Duration(days: 1));
    final remaining = tomorrowFajr.difference(currentTime);
    return NextPrayer(
      name: 'Fajr',
      time: tomorrowFajr,
      timeRemaining: remaining,
      isToday: false,
    );
  }
}
