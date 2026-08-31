import { Controller, Get } from '@nestjs/common';
import { Organization } from './models/organization';
import { OrganizationsService } from './organizations.service';

@Controller('organizations')
export class OrganizationsController {
  constructor(private readonly organizationsService: OrganizationsService) {}

  @Get()
  findAll(): Organization[] {
    return this.organizationsService.findAll();
  }
}
