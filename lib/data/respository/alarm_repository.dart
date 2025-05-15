import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/repository_response.dart';
import 'package:quilmedic/domain/alarm.dart';

/// Repositorio que gestiona las operaciones relacionadas con las alarmas.
/// Proporciona métodos para obtener alarmas generales y específicas por producto
/// desde la API.
class AlarmRepository {
  /// Cliente de API utilizado para realizar las peticiones al servidor
  final ApiClient apiClient;

  /// Constructor que recibe una instancia de ApiClient
  /// @param apiClient Cliente de API para realizar las peticiones
  AlarmRepository({required this.apiClient});

  /// Obtiene todas las alarmas generales desde la API
  /// @return RepositoryResponse con la lista de alarmas generales o un mensaje de error
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

  /// Obtiene las alarmas específicas para una lista de productos identificados por sus IDs en formato String
  /// @param productIds Lista de IDs de productos en formato String
  /// @return RepositoryResponse con la lista de alarmas específicas o un mensaje de error
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

  /// Obtiene las alarmas específicas para una lista de productos identificados por sus IDs en formato entero
  /// Utiliza el método POST para enviar la lista de IDs
  /// @param productIds Lista de IDs de productos en formato entero
  /// @return RepositoryResponse con la lista de alarmas específicas o un mensaje de error
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
