import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/domain/hospital.dart';

class HospitalRepository {
  final ApiClient apiClient;

  HospitalRepository({required this.apiClient});

  Future<List<Hospital>> getAllHospitals() async {
    try {
      final response = await apiClient.getAll(
        ApiConfig.hospitalesEndpoint,
        null,
      );

      // La respuesta es directamente una lista de mapas
      if (response is List) {
        return response
            .map((item) => Hospital.fromJson(item as Map<String, dynamic>))
            .toList();
      } 
      
      // Si por alguna razón no es una lista, devolver una lista vacía
      return [];
    } catch (e) {
      throw Exception('Error al obtener hospitales: ${e.toString()}');
    }
  }
}
