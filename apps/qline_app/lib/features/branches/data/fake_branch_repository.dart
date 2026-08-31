import '../../../core/location/geo_point.dart';
import '../domain/branch.dart';
import '../domain/branch_repository.dart';

class FakeBranchRepository implements BranchRepository {
  @override
  Future<List<Branch>> getBranchesByOrganization(String organizationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final branches = const [
      Branch(
        id: 'branch-1',
        organizationId: 'citizen-center',
        name: 'فرع المزة',
        organizationName: 'مركز خدمة المواطن',
        address: 'دمشق، أوتوستراد المزة',
        peopleWaiting: 8,
        estimatedWaitMinutes: 18,
        isOpen: true,
        location: GeoPoint(latitude: 33.5038, longitude: 36.2501),
      ),
      Branch(
        id: 'branch-2',
        organizationId: 'telecom',
        name: 'فرع أبو رمانة',
        organizationName: 'شركة الاتصالات',
        address: 'دمشق، شارع الجلاء',
        peopleWaiting: 3,
        estimatedWaitMinutes: 7,
        isOpen: true,
        location: GeoPoint(latitude: 33.5207, longitude: 36.2870),
      ),
      Branch(
        id: 'branch-3',
        organizationId: 'university',
        name: 'فرع البرامكة',
        organizationName: 'مركز الخدمات الجامعية',
        address: 'دمشق، البرامكة',
        peopleWaiting: 0,
        estimatedWaitMinutes: 0,
        isOpen: false,
        location: GeoPoint(latitude: 33.5102, longitude: 36.2915),
      ),
      Branch(
        id: 'branch-4',
        organizationId: 'citizen-center',
        name: 'فرع دمشق القديمة',
        organizationName: 'مركز خدمة المواطن',
        address: 'دمشق، باب توما',
        peopleWaiting: 5,
        estimatedWaitMinutes: 14,
        isOpen: true,
        location: GeoPoint(latitude: 33.5149, longitude: 36.3149),
      ),
      Branch(
        id: 'branch-5',
        organizationId: 'citizen-center',
        name: 'فرع كفرسوسة',
        organizationName: 'مركز خدمة المواطن',
        address: 'دمشق، كفرسوسة',
        peopleWaiting: 11,
        estimatedWaitMinutes: 25,
        isOpen: true,
        location: GeoPoint(latitude: 33.4974, longitude: 36.2701),
      ),
      Branch(
        id: 'branch-6',
        organizationId: 'telecom',
        name: 'فرع المزة',
        organizationName: 'شركة الاتصالات',
        address: 'دمشق، المزة',
        peopleWaiting: 6,
        estimatedWaitMinutes: 16,
        isOpen: true,
        location: GeoPoint(latitude: 33.5050, longitude: 36.2530),
      ),
    ];

    return branches
        .where((branch) => branch.organizationId == organizationId)
        .toList(growable: false);
  }
}
