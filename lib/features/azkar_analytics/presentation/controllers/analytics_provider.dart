import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/analytics_summary_entity.dart';
import '../../domain/entities/daily_log_entity.dart';
import '../../domain/repositories/analytics_repository.dart';

enum AnalyticsPeriod { day, week, month, year }

class AnalyticsState {
  final AnalyticsPeriod period;
  final AsyncValue<AnalyticsSummaryEntity> summary;

  AnalyticsState({
    this.period = AnalyticsPeriod.week,
    this.summary = const AsyncValue.loading(),
  });

  AnalyticsState copyWith({
    AnalyticsPeriod? period,
    AsyncValue<AnalyticsSummaryEntity>? summary,
  }) {
    return AnalyticsState(
      period: period ?? this.period,
      summary: summary ?? this.summary,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsRepository _repository = getIt<AnalyticsRepository>();

  AnalyticsNotifier() : super(AnalyticsState()) {
    loadSummary();
  }

  Future<void> loadSummary() async {
    state = state.copyWith(summary: const AsyncValue.loading());
    try {
      final summaryData = await _repository.getAnalyticsSummary();
      state = state.copyWith(summary: AsyncValue.data(summaryData));
    } catch (e, st) {
      state = state.copyWith(summary: AsyncValue.error(e, st));
    }
  }

  void setPeriod(AnalyticsPeriod newPeriod) {
    state = state.copyWith(period: newPeriod);
  }
}

final analyticsNotifierProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier();
});

class AnalyticsDataMapper {
  static Map<String, int> getPeriodData(
      AnalyticsPeriod period, List<DailyLogEntity> logs) {
    final Map<String, int> map = {};
    if (logs.isEmpty) return map;

    final now = DateTime.now();

    switch (period) {
      case AnalyticsPeriod.day:
      case AnalyticsPeriod.week:
        // Show last 7 days of daily taps
        final recent = logs.length > 7 ? logs.sublist(logs.length - 7) : logs;
        for (final log in recent) {
          final parts = log.dateStr.split('-');
          final label = parts.length == 3 ? '${parts[1]}/${parts[2]}' : log.dateStr;
          map[label] = log.taps;
        }
        break;

      case AnalyticsPeriod.month:
        // Group into 4 weeks of current month
        map['Week 1'] = 0;
        map['Week 2'] = 0;
        map['Week 3'] = 0;
        map['Week 4'] = 0;

        for (final log in logs) {
          try {
            final date = DateTime.parse(log.dateStr);
            if (date.month == now.month && date.year == now.year) {
              final day = date.day;
              if (day <= 7) {
                map['Week 1'] = (map['Week 1'] ?? 0) + log.taps;
              } else if (day <= 14) {
                map['Week 2'] = (map['Week 2'] ?? 0) + log.taps;
              } else if (day <= 21) {
                map['Week 3'] = (map['Week 3'] ?? 0) + log.taps;
              } else {
                map['Week 4'] = (map['Week 4'] ?? 0) + log.taps;
              }
            }
          } catch (_) {}
        }
        break;

      case AnalyticsPeriod.year:
        // Group by 12 months of current year
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        for (final m in months) {
          map[m] = 0;
        }

        for (final log in logs) {
          try {
            final date = DateTime.parse(log.dateStr);
            if (date.year == now.year) {
              final mName = months[date.month - 1];
              map[mName] = (map[mName] ?? 0) + log.taps;
            }
          } catch (_) {}
        }
        // Remove trailing empty future months
        map.removeWhere((key, val) {
          final monthIndex = months.indexOf(key) + 1;
          return monthIndex > now.month && val == 0;
        });
        break;
    }

    return map;
  }
}
