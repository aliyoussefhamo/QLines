import 'organization.dart';

abstract interface class OrganizationRepository {
  Future<List<Organization>> getOrganizations();
}
