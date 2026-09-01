import { Controller, Get, Param } from '@nestjs/common';
import { BranchServicesService } from './branch-services.service';
import { BranchService } from './models/branch-service';

@Controller('branches/:branchId/services')
export class BranchServicesController {
  constructor(private readonly branchServicesService: BranchServicesService) {}

  @Get()
  findByBranchId(@Param('branchId') branchId: string): BranchService[] {
    return this.branchServicesService.findByBranchId(branchId);
  }
}
