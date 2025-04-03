import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/domain/alarm.dart';
import 'package:quilmedic/data/respository/repository_response.dart';

class AlarmRepository {
  final ApiClient apiClient;

  AlarmRepository({required this.apiClient});

  Future<RepositoryResponse> getAllAlarms() async {
    try {
      final response = await apiClient.getAll(ApiConfig.alarmasEndpoint, null);

      if (response is List) {
        var alarms =
            response
                .map((item) => Alarm.fromJson(item as Map<String, dynamic>))
                .toList();

        return RepositoryResponse.success(
          alarms,
          message: 'Alarmas obtenidas correctamente',
        );
      }

      return RepositoryResponse.error('Error al obtener alarmas');
    } catch (e) {
      throw Exception('Error al obtener alarmas: ${e.toString()}');
    }
  }

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

  // Future<RepositoryResponse> getAlarmasEspecificas(List<String> serialNumbers) async {
    
  // }

  Future<RepositoryResponse> getAlarmById(int id) async {
    try {
      final response = await apiClient.getAll(
        '${ApiConfig.alarmasEndpoint}/$id',
        null,
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

  Future<RepositoryResponse> getAlarmByProductId(String productId) async {
    try {
      final response = await apiClient.getAll(
        '${ApiConfig.alarmasEndpoint}/byProductId/$productId',
        null,
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

  Future<RepositoryResponse> getAlarmsByProducts(List<String> serialNumbers) async {
    try {
      final Map<String, dynamic> queryParams = {};
      for (int i = 0; i < serialNumbers.length; i++) {
        queryParams['serial_numbers[$i]'] = serialNumbers[i];
      }

      final response = await apiClient.getAll(
        '${ApiConfig.alarmasEndpoint}/bySerialNumbers',
        queryParams,
      );

      if (response is List) {
        var alarms = response
            .map((item) => Alarm.fromJson(item as Map<String, dynamic>))
            .toList();

        return RepositoryResponse.success(
          alarms,
          message: 'Alarmas obtenidas correctamente',
        );
      }

      return RepositoryResponse.error('Error al obtener alarmas por números de serie');
    } catch (e) {
      return RepositoryResponse.error('Error al obtener alarmas: ${e.toString()}');
    }
  }
}
