import '../../domain/entities/analytics_summary_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_local_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsLocalDataSource _localDataSource;

  AnalyticsRepositoryImpl(this._localDataSource);

  @override
  Future<AnalyticsSummaryEntity> getAnalyticsSummary() async {
    final models = await _localDataSource.getLogs();
    final logs = models.map((m) => m.toEntity()).toList();

    int totalTaps = 0;
    int totalSessions = 0;
    for (final log in logs) {
      totalTaps += log.taps;
      totalSessions += log.completedSessions;
    }

    // Calculate active streak
    int streak = 0;
    for (int i = logs.length - 1; i >= 0; i--) {
      if (logs[i].taps > 0) {
        streak++;
      } else {
        break;
      }
    }

    final topZikr = await _localDataSource.getMostRecitedZikr();

    return AnalyticsSummaryEntity(
      totalTapsAllTime: totalTaps,
      totalSessionsAllTime: totalSessions,
      currentStreakDays: streak,
      topZikrName: topZikr,
      logs: logs,
    );
  }
}
