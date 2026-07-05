import '../../domain/entities/prayer_times.dart';

class AlAdhanResponseModel {
  final int code;
  final String status;
  final Map<String, String> timings;
  final String dateReadable;

  AlAdhanResponseModel({
    required this.code,
    required this.status,
    required this.timings,
    required this.dateReadable,
  });

  factory AlAdhanResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final timingsJson = data['timings'] as Map<String, dynamic>? ?? {};
    final dateJson = data['date'] as Map<String, dynamic>? ?? {};

    final timingsMap = <String, String>{};
    timingsJson.forEach((key, value) {
      timingsMap[key] = value.toString();
    });

    return AlAdhanResponseModel(
      code: json['code'] as int? ?? 200,
      status: json['status'] as String? ?? 'OK',
      timings: timingsMap,
      dateReadable: dateJson['readable'] as String? ?? '',
    );
  }

  PrayerTimesEntity toEntity({required String city, required String country}) {
    final now = DateTime.now();

    DateTime parseTime(String rawTime) {
      // Clean time string like "04:12 (EET)" to "04:12"
      final cleanTime = rawTime.split(' ').first.trim();
      final parts = cleanTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return DateTime(now.year, now.month, now.day, hour, minute);
    }

    return PrayerTimesEntity(
      fajr: parseTime(timings['Fajr'] ?? '04:00'),
      sunrise: parseTime(timings['Sunrise'] ?? '06:00'),
      dhuhr: parseTime(timings['Dhuhr'] ?? '12:00'),
      asr: parseTime(timings['Asr'] ?? '15:30'),
      maghrib: parseTime(timings['Maghrib'] ?? '18:00'),
      isha: parseTime(timings['Isha'] ?? '19:30'),
      dateReadable: dateReadable,
      city: city,
      country: country,
    );
  }
}
