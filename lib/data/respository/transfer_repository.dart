import 'package:quilmedic/data/config.dart';
import 'package:quilmedic/data/json/api_client.dart';
import 'package:quilmedic/data/respository/repository_response.dart';
import 'package:quilmedic/domain/transfer_request.dart';

class TransferRepository {
  final ApiClient apiClient;

  TransferRepository({required this.apiClient});

  Future<RepositoryResponse> transferProducts(TransferRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConfig.transferEndpoint,
        request.toJson(),
      );

      return RepositoryResponse.success(
        response,
        message: 'Solicitud de traslado enviada correctamente',
      );
    } catch (e) {
      return RepositoryResponse.error('Error al enviar solicitud de traslado: ${e.toString()}');
    }
  }
}
