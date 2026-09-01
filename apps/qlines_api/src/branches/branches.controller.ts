import {
  Controller,
  Get,
  Param,
  ParseEnumPipe,
  ParseFloatPipe,
  Query,
} from '@nestjs/common';
import { BranchesService } from './branches.service';
import { Branch } from './models/branch';
import { NearbyBranch } from './models/nearby-branch';
import { TravelMode } from './models/travel-mode';

@Controller('organizations/:organizationId/branches')
export class BranchesController {
  constructor(private readonly branchesService: BranchesService) {}

  @Get('nearby')
  findNearbyByOrganizationId(
    @Param('organizationId') organizationId: string,
    @Query('latitude', ParseFloatPipe) latitude: number,
    @Query('longitude', ParseFloatPipe) longitude: number,
    @Query('mode', new ParseEnumPipe(TravelMode))
    travelMode: TravelMode,
  ): Promise<NearbyBranch[]> {
    return this.branchesService.findNearbyByOrganizationId(
      organizationId,
      latitude,
      longitude,
      travelMode,
    );
  }

  @Get()
  findByOrganizationId(
    @Param('organizationId') organizationId: string,
  ): Promise<Branch[]> {
    return this.branchesService.findByOrganizationId(organizationId);
  }
}
