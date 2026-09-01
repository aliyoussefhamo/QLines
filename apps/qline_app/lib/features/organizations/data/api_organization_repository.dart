import '../../../core/network/api_client.dart';
import '../domain/organization.dart';
import '../domain/organization_repository.dart';

class ApiOrganizationRepository implements OrganizationRepository {
  const ApiOrganizationRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Organization>> getOrganizations() async {
    final response = await _apiClient.get('/organizations');

    if (response is! List<dynamic>) {
      throw const FormatException('Invalid organizations response');
    }

    return response
        .map((item) => Organization.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
