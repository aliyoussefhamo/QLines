import { Injectable } from '@nestjs/common';
import { Branch } from './models/branch';
import { NearbyBranch } from './models/nearby-branch';
import { calculateDistanceKm } from './utils/calculate-distance';
import { TravelMode } from './models/travel-mode';
import { calculateTravelDurationMinutes } from './utils/calculate-travel-duration';
import { calculateQueueDurationMinutes } from './utils/calculate-queue-duration';

@Injectable()
export class BranchesService {
  private readonly branches: Branch[] = [
    {
      id: 'citizen-center-mazzeh',
      organizationId: 'citizen-center',
      name: 'مركز خدمة المواطن - المزة',
      address: 'المزة، دمشق',
      latitude: 33.5038,
      longitude: 36.2501,
      peopleWaiting: 12,
      bookingsAhead: 4,
      activeServiceCounters: 2,
      averageServiceDurationMinutes: 8,
      isActive: true,
    },
    {
      id: 'citizen-center-baramekeh',
      organizationId: 'citizen-center',
      name: 'مركز خدمة المواطن - البرامكة',
      address: 'البرامكة، دمشق',
      latitude: 33.5062,
      longitude: 36.2911,
      peopleWaiting: 7,
      bookingsAhead: 3,
      activeServiceCounters: 2,
      averageServiceDurationMinutes: 8,
      isActive: true,
    },
    {
      id: 'citizen-center-bab-touma',
      organizationId: 'citizen-center',
      name: 'مركز خدمة المواطن - باب توما',
      address: 'باب توما، دمشق',
      latitude: 33.5148,
      longitude: 36.3164,
      peopleWaiting: 18,
      bookingsAhead: 5,
      activeServiceCounters: 3,
      averageServiceDurationMinutes: 8,
      isActive: true,
    },
    {
      id: 'telecom-mazzeh',
      organizationId: 'telecom',
      name: 'فرع الاتصالات - المزة',
      address: 'المزة، دمشق',
      latitude: 33.5017,
      longitude: 36.2478,
      peopleWaiting: 9,
      bookingsAhead: 2,
      activeServiceCounters: 2,
      averageServiceDurationMinutes: 6,
      isActive: true,
    },
    {
      id: 'telecom-victoria',
      organizationId: 'telecom',
      name: 'فرع الاتصالات - الحريقة',
      address: 'الحريقة، دمشق',
      latitude: 33.5102,
      longitude: 36.3047,
      peopleWaiting: 14,
      bookingsAhead: 4,
      activeServiceCounters: 2,
      averageServiceDurationMinutes: 6,
      isActive: true,
    },
    {
      id: 'university-baramekeh',
      organizationId: 'university',
      name: 'مركز الخدمات الجامعية - البرامكة',
      address: 'البرامكة، دمشق',
      latitude: 33.5053,
      longitude: 36.2894,
      peopleWaiting: 20,
      bookingsAhead: 6,
      activeServiceCounters: 3,
      averageServiceDurationMinutes: 10,
      isActive: true,
    },
  ];

  findAll(): Branch[] {
    return this.branches;
  }

  findByOrganizationId(organizationId: string): Branch[] {
    return this.branches.filter(
      (branch) => branch.organizationId === organizationId && branch.isActive,
    );
  }

  findNearbyByOrganizationId(
    organizationId: string,
    userLatitude: number,
    userLongitude: number,
    travelMode: TravelMode,
  ): NearbyBranch[] {
    return this.findByOrganizationId(organizationId)
      .map((branch) => {
        const distanceKm = calculateDistanceKm(
          userLatitude,
          userLongitude,
          branch.latitude,
          branch.longitude,
        );

        const estimatedTravelMinutes = calculateTravelDurationMinutes(
          distanceKm,
          travelMode,
        );

        const peopleAhead = branch.peopleWaiting + branch.bookingsAhead;

        const estimatedQueueMinutes = calculateQueueDurationMinutes(
          branch.peopleWaiting,
          branch.bookingsAhead,
          branch.activeServiceCounters,
          branch.averageServiceDurationMinutes,
        );

        const estimatedWaitAfterArrivalMinutes = Math.max(
          0,
          estimatedQueueMinutes - estimatedTravelMinutes,
        );

        const estimatedTotalMinutes =
          estimatedTravelMinutes + estimatedWaitAfterArrivalMinutes;

        return {
          ...branch,
          distanceKm: Number(distanceKm.toFixed(2)),
          travelMode,
          estimatedTravelMinutes,
          peopleAhead,
          estimatedQueueMinutes,
          estimatedWaitAfterArrivalMinutes,
          estimatedTotalMinutes,
        };
      })
      .sort((firstBranch, secondBranch) => {
        return firstBranch.distanceKm - secondBranch.distanceKm;
      });
  }
}
