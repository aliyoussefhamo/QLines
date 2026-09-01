import '../../../core/network/api_client.dart';
import '../domain/branch.dart';
import '../domain/branch_repository.dart';

class ApiBranchRepository implements BranchRepository {
  const ApiBranchRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Branch>> getBranchesByOrganization(
    String organizationId,
    String organizationName,
  ) async {
    final response = await _apiClient.get(
      '/organizations/$organizationId/branches',
    );

    if (response is! List<dynamic>) {
      throw const FormatException('Invalid branches response');
    }

    return response
        .map(
          (item) => Branch.fromJson(
            item as Map<String, dynamic>,
            organizationName: organizationName,
          ),
        )
        .toList(growable: false);
  }
}
