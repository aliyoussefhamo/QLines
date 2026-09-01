import { Controller, Get } from '@nestjs/common';
import type { Organization } from './models/organization';
import { OrganizationsService } from './organizations.service';

@Controller('organizations')
export class OrganizationsController {
  constructor(private readonly organizationsService: OrganizationsService) {}

  @Get()
  findAll(): Promise<Organization[]> {
    return this.organizationsService.findAll();
  }
}
