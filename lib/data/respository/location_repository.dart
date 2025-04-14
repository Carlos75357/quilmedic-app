import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/repository_response.dart';
import 'package:quilmedic/domain/location.dart';

class LocationRepository {
  final ApiClient apiClient;

  LocationRepository({required this.apiClient});

  Future<RepositoryResponse> getAllLocations() async {
    try {
      final response = await apiClient.getAll(
        ApiConfig.locationEndpoint,
        null,
      );

      if (response is List) {
        var locations = response
            .map((item) => Location.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return RepositoryResponse.success(locations, message: 'Ubicaciones obtenidas correctamente');
      } 
      
      return RepositoryResponse.error('Error al obtener ubicaciones');
    } catch (e) {
      return RepositoryResponse.error('Error al obtener ubicaciones: ${e.toString()}');
    }
  }

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
