import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/repository_response.dart';
import 'package:quilmedic/domain/alarm.dart';

class AlarmRepository {
  final ApiClient apiClient;

  AlarmRepository({required this.apiClient});

  Future<RepositoryResponse> getGeneralAlarms() async {
    try {
      final response = await apiClient.getAll(
        '${ApiConfig.alarmasEndpoint}/general',
        null,
      );

      if (response is List) {
        var alarms =
            response
                .map((item) => Alarm.fromJson(item as Map<String, dynamic>))
                .toList();

        return RepositoryResponse.success(
          alarms,
          message: 'Alarmas generales obtenidas correctamente',
        );
      }

      return RepositoryResponse.error('Error al obtener alarmas generales');
    } catch (e) {
      throw Exception('Error al obtener alarmas generales: ${e.toString()}');
    }
  }

  Future<RepositoryResponse> getAlarmsByProduct(List<String> productIds) async {
    try {
      final response = await apiClient.getAll(
        '${ApiConfig.alarmasEndpoint}/byProductIds',
        {'product_ids': productIds},
      );

      var alarms =
          response
              .map((item) => Alarm.fromJson(item as Map<String, dynamic>))
              .toList();

      return RepositoryResponse.success(
        alarms,
        message: 'Alarmas obtenidas correctamente',
      );
    } catch (e) {
      return RepositoryResponse.error(e.toString());
    }
  }

  Future<RepositoryResponse> getAlarmsByProducts(List<int> productIds) async {
    try {
      final response = await apiClient.post(
        '${ApiConfig.alarmasEndpoint}/byProducts',
        {
          'products_ids': productIds,
        },
      );

      if (response is List) {
        var productAlarms = response
            .map((item) => Alarm.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return RepositoryResponse.success(
          productAlarms,
          message: 'Alarmas obtenidas correctamente',
        );
      }

      return RepositoryResponse.error('Error al obtener alarmas para los productos');
    } catch (e) {
      return RepositoryResponse.error('Error al obtener alarmas: ${e.toString()}');
    }
  }
}
