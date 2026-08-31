import { Controller, Get, Param } from '@nestjs/common';
import { BranchesService } from './branches.service';
import { Branch } from './models/branch';

@Controller('organizations/:organizationId/branches')
export class BranchesController {
  constructor(private readonly branchesService: BranchesService) {}

  @Get()
  findByOrganizationId(
    @Param('organizationId') organizationId: string,
  ): Branch[] {
    return this.branchesService.findByOrganizationId(organizationId);
  }
}
