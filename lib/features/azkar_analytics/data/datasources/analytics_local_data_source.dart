import '../../../azkar/data/datasources/azkar_local_data_source.dart';
import '../models/daily_log_model.dart';

abstract class AnalyticsLocalDataSource {
  Future<List<DailyLogModel>> getLogs();
  Future<String> getMostRecitedZikr();
}

class AnalyticsLocalDataSourceImpl implements AnalyticsLocalDataSource {
  final AzkarLocalDataSource _azkarLocalDataSource;

  AnalyticsLocalDataSourceImpl(this._azkarLocalDataSource);

  @override
  Future<List<DailyLogModel>> getLogs() async {
    final rawMap = await _azkarLocalDataSource.getDailyLogMap();
    final list = <DailyLogModel>[];

    rawMap.forEach((key, value) {
      if (value is Map) {
        list.add(DailyLogModel.fromJson(Map<String, dynamic>.from(value)));
      }
    });

    list.sort((a, b) => a.dateStr.compareTo(b.dateStr));
    return list;
  }

  @override
  Future<String> getMostRecitedZikr() async {
    final azkarList = await _azkarLocalDataSource.getAzkar();
    if (azkarList.isEmpty) return 'سبحان الله وبحمده';

    azkarList.sort((a, b) => b.todayTapCount.compareTo(a.todayTapCount));
    final top = azkarList.first;
    return top.todayTapCount > 0 ? top.textAr : 'سبحان الله وبحمده';
  }
}
