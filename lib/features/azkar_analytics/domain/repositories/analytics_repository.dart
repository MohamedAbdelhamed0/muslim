import '../entities/analytics_summary_entity.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsSummaryEntity> getAnalyticsSummary();
}
