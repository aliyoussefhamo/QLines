import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BranchEntity } from './entities/branch.entity';
import { Branch } from './models/branch';
import { NearbyBranch } from './models/nearby-branch';
import { TravelMode } from './models/travel-mode';
import { calculateDistanceKm } from './utils/calculate-distance';
import { calculateQueueDurationMinutes } from './utils/calculate-queue-duration';
import { calculateTravelDurationMinutes } from './utils/calculate-travel-duration';

@Injectable()
export class BranchesService {
  constructor(
    @InjectRepository(BranchEntity)
    private readonly branchesRepository: Repository<BranchEntity>,
  ) {}

  async findAll(): Promise<Branch[]> {
    const branches = await this.branchesRepository.find({
      where: { isActive: true },
      order: { name: 'ASC' },
    });
    return branches.map((branch) => this.toBranch(branch));
  }

  async findById(branchId: string): Promise<Branch | undefined> {
    const branch = await this.branchesRepository.findOne({
      where: { id: branchId, isActive: true },
    });
    return branch ? this.toBranch(branch) : undefined;
  }

  async findByOrganizationId(organizationId: string): Promise<Branch[]> {
    const branches = await this.branchesRepository.find({
      where: { organizationId, isActive: true },
      order: { name: 'ASC' },
    });
    return branches.map((branch) => this.toBranch(branch));
  }

  async findNearbyByOrganizationId(
    organizationId: string,
    userLatitude: number,
    userLongitude: number,
    travelMode: TravelMode,
  ): Promise<NearbyBranch[]> {
    const branches = await this.findByOrganizationId(organizationId);

    return branches
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

        return {
          ...branch,
          distanceKm: Number(distanceKm.toFixed(2)),
          travelMode,
          estimatedTravelMinutes,
          peopleAhead,
          estimatedQueueMinutes,
          estimatedWaitAfterArrivalMinutes,
          estimatedTotalMinutes:
            estimatedTravelMinutes + estimatedWaitAfterArrivalMinutes,
        };
      })
      .sort((firstBranch, secondBranch) => {
        return firstBranch.distanceKm - secondBranch.distanceKm;
      });
  }

  private toBranch(entity: BranchEntity): Branch {
    return {
      id: entity.id,
      organizationId: entity.organizationId,
      name: entity.name,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      peopleWaiting: entity.peopleWaiting,
      bookingsAhead: entity.bookingsAhead,
      activeServiceCounters: entity.activeServiceCounters,
      averageServiceDurationMinutes: entity.averageServiceDurationMinutes,
      isActive: entity.isActive,
    };
  }
}
