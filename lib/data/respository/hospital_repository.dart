import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/data/respository/repository_response.dart';

/// Repositorio que gestiona las operaciones relacionadas con los hospitales.
/// Proporciona métodos para obtener la lista de hospitales desde la API.
class HospitalRepository {
  /// Cliente de API utilizado para realizar las peticiones al servidor
  final ApiClient apiClient;

  /// Constructor que recibe una instancia de ApiClient
  /// @param apiClient Cliente de API para realizar las peticiones
  HospitalRepository({required this.apiClient});

  /// Obtiene todos los hospitales desde la API
  /// @return RepositoryResponse con la lista de hospitales o un mensaje de error
  Future<RepositoryResponse> getAllHospitals() async {
    try {
      final response = await apiClient.getAll(
        ApiConfig.hospitalesEndpoint,
        null,
      );

      if (response is List) {
        var hospitals = response
            .map((item) => Hospital.fromJson(item as Map<String, dynamic>))
            .toList();
        
        return RepositoryResponse.success(hospitals, message: 'Hospitales obtenidos correctamente');
      } 
      
      return RepositoryResponse.error('Error al obtener hospitales');
    } catch (e) {
      throw Exception('Error al obtener hospitales: ${e.toString()}');
    }
  }
}
