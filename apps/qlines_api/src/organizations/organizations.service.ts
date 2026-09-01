import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import type { Repository } from 'typeorm';
import { OrganizationEntity } from './entities/organization.entity';
import type { Organization } from './models/organization';

@Injectable()
export class OrganizationsService {
  constructor(
    @InjectRepository(OrganizationEntity)
    private readonly organizationRepository: Repository<OrganizationEntity>,
  ) {}

  async findAll(): Promise<Organization[]> {
    const organizations = await this.organizationRepository.find({
      where: { isActive: true },
      order: { name: 'ASC' },
    });

    return organizations.map(
      ({ id, name, category, branchCount, isActive }) => ({
        id,
        name,
        category,
        branchCount,
        isActive,
      }),
    );
  }
}
