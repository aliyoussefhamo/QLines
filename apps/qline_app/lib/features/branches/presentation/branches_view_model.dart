import 'package:flutter/foundation.dart';

import '../../../core/location/distance_calculator.dart';
import '../../../core/location/location_service.dart';
import '../domain/branch.dart';
import '../domain/branch_repository.dart';

enum BranchesStatus { initial, loading, success, failure }

enum TravelMode { walking, driving }

class BranchesViewModel extends ChangeNotifier {
  BranchesViewModel(
    this._repository,
    this._locationService,
    this._distanceCalculator,
  );

  final BranchRepository _repository;
  final LocationService _locationService;
  final DistanceCalculator _distanceCalculator;
  BranchesStatus status = BranchesStatus.initial;
  List<Branch> branches = const [];
  Map<String, double> distanceByBranchId = const {};
  String? errorMessage;
  TravelMode travelMode = TravelMode.walking;

  Future<void> loadBranches(
    String organizationId,
    String organizationName,
  ) async {
    status = BranchesStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final userLocation = await _locationService.getCurrentLocation();
      final loadedBranches = List<Branch>.of(
        await _repository.getBranchesByOrganization(
          organizationId,
          organizationName,
        ),
      );
      final distances = {
        for (final branch in loadedBranches)
          branch.id: _distanceCalculator.distanceInKilometers(
            userLocation,
            branch.location,
          ),
      };
      loadedBranches.sort(
        (first, second) =>
            distances[first.id]!.compareTo(distances[second.id]!),
      );
      branches = loadedBranches;
      distanceByBranchId = distances;
      status = BranchesStatus.success;
    } catch (_) {
      status = BranchesStatus.failure;
      errorMessage = 'تعذر تحميل الفروع. حاول مرة أخرى.';
    }
    notifyListeners();
  }

  double distanceFor(Branch branch) => distanceByBranchId[branch.id] ?? 0;

  void selectTravelMode(TravelMode mode) {
    if (travelMode == mode) return;
    travelMode = mode;
    notifyListeners();
  }

  int travelMinutesFor(Branch branch) {
    final assumedSpeedKmPerHour = switch (travelMode) {
      TravelMode.walking => 6.0,
      TravelMode.driving => 30.0,
    };
    final minutes = (distanceFor(branch) / assumedSpeedKmPerHour * 60).ceil();
    return minutes < 1 ? 1 : minutes;
  }
}
