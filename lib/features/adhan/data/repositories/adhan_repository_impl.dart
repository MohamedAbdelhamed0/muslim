import '../../../../core/network/api_exceptions.dart';
import '../../../../core/network/failure.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/repositories/adhan_repository.dart';
import '../datasources/adhan_remote_data_source.dart';

class AdhanRepositoryImpl implements AdhanRepository {
  final AdhanRemoteDataSource _remoteDataSource;

  AdhanRepositoryImpl(this._remoteDataSource);

  @override
  Future<PrayerTimesEntity> getPrayerTimesByCity({
    required String city,
    required String country,
    int method = 5,
  }) async {
    try {
      final model = await _remoteDataSource.getTimingsByCity(
        city: city,
        country: country,
        method: method,
      );
      return model.toEntity(city: city, country: country);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, code: e.statusCode?.toString());
    } on ApiException catch (e) {
      throw UnknownFailure(message: e.message);
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }
}
