import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BranchServiceEntity } from './entities/branch-service.entity';
import { BranchService } from './models/branch-service';

@Injectable()
export class BranchServicesService {
  constructor(
    @InjectRepository(BranchServiceEntity)
    private readonly servicesRepository: Repository<BranchServiceEntity>,
  ) {}

  async findAll(): Promise<BranchService[]> {
    const services = await this.servicesRepository.find({
      where: { isAvailable: true },
      order: { name: 'ASC' },
    });
    return services.map((service) => this.toBranchService(service));
  }

  async findById(serviceId: string): Promise<BranchService | undefined> {
    const service = await this.servicesRepository.findOne({
      where: { id: serviceId, isAvailable: true },
    });
    return service ? this.toBranchService(service) : undefined;
  }

  async findByBranchId(branchId: string): Promise<BranchService[]> {
    const services = await this.servicesRepository.find({
      where: { branchId, isAvailable: true },
      order: { name: 'ASC' },
    });
    return services.map((service) => this.toBranchService(service));
  }

  private toBranchService(entity: BranchServiceEntity): BranchService {
    return {
      id: entity.id,
      branchId: entity.branchId,
      name: entity.name,
      description: entity.description,
      requiredDocuments: entity.requiredDocuments,
      requirements: entity.requirements,
      steps: entity.steps,
      notes: entity.notes,
      feeAmount: entity.feeAmount,
      currency: entity.currency,
      peopleWaiting: entity.peopleWaiting,
      bookingsAhead: entity.bookingsAhead,
      activeServiceCounters: entity.activeServiceCounters,
      averageServiceDurationMinutes: entity.averageServiceDurationMinutes,
      isAvailable: entity.isAvailable,
    };
  }
}
