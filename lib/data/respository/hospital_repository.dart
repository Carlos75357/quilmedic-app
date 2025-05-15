import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/domain/hospital.dart';
import 'package:quilmedic/data/respository/repository_response.dart';

class HospitalRepository {
  final ApiClient apiClient;

  HospitalRepository({required this.apiClient});

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
