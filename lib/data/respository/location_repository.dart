import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/repository_response.dart';
import 'package:quilmedic/domain/location.dart';

/// Repositorio que gestiona las operaciones relacionadas con las ubicaciones.
/// Proporciona métodos para obtener las ubicaciones disponibles en un hospital específico.
class LocationRepository {
  /// Cliente de API utilizado para realizar las peticiones al servidor
  final ApiClient apiClient;

  /// Constructor que recibe una instancia de ApiClient
  /// @param apiClient Cliente de API para realizar las peticiones
  LocationRepository({required this.apiClient});

  /// Obtiene todas las ubicaciones disponibles para un hospital específico
  /// @param id ID del hospital del que se quieren obtener las ubicaciones
  /// @return RepositoryResponse con la lista de ubicaciones o un mensaje de error
  Future<RepositoryResponse> getLocationsForAStore(int id) async {
    try {
      final response = await apiClient.getAll(
        '${ApiConfig.locationEndpoint}/store/$id',
        null,
      );

      if (response is List) {
        var locations = response.map((item) => Location.fromJson(item as Map<String, dynamic>)).toList();
        
        return RepositoryResponse.success(locations, message: 'Ubicaciones obtenidas correctamente');
      } 
      
      return RepositoryResponse.error('Error al obtener ubicaciones');
    } catch (e) {
      return RepositoryResponse.error('Error al obtener ubicaciones: ${e.toString()}');
    }
  }
}
