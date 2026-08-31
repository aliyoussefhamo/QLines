import '../domain/organization.dart';
import '../domain/organization_repository.dart';

class FakeOrganizationRepository implements OrganizationRepository {
  @override
  Future<List<Organization>> getOrganizations() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const [
      Organization(
        id: 'citizen-center',
        name: 'مركز خدمة المواطن',
        category: 'خدمات حكومية',
        branchCount: 3,
        isActive: true,
      ),
      Organization(
        id: 'telecom',
        name: 'شركة الاتصالات',
        category: 'اتصالات',
        branchCount: 2,
        isActive: true,
      ),
      Organization(
        id: 'university',
        name: 'مركز الخدمات الجامعية',
        category: 'تعليم',
        branchCount: 1,
        isActive: true,
      ),
    ];
  }
}
