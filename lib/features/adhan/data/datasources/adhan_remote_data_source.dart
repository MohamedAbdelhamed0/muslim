import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/aladhan_response_model.dart';

abstract class AdhanRemoteDataSource {
  Future<AlAdhanResponseModel> getTimingsByCity({
    required String city,
    required String country,
    int method = 5,
  });
}

class AdhanRemoteDataSourceImpl implements AdhanRemoteDataSource {
  final ApiClient _apiClient;

  AdhanRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AlAdhanResponseModel> getTimingsByCity({
    required String city,
    required String country,
    int method = 5,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.timingsByCity,
      queryParameters: {
        'city': city,
        'country': country,
        'method': method,
      },
    );

    return AlAdhanResponseModel.fromJson(response as Map<String, dynamic>);
  }
}
