import '../entities/prayer_times.dart';

abstract class AdhanRepository {
  Future<PrayerTimesEntity> getPrayerTimesByCity({
    required String city,
    required String country,
    int method = 5,
  });
}
