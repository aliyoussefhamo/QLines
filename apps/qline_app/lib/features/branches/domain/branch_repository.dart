import 'branch.dart';

abstract interface class BranchRepository {
  Future<List<Branch>> getBranchesByOrganization(String organizationId);
}
