import { Module } from '@nestjs/common';
import { BranchServicesController } from './branch-services.controller';
import { BranchServicesService } from './branch-services.service';

@Module({
  controllers: [BranchServicesController],
  providers: [BranchServicesService],
  exports: [BranchServicesService],
})
export class BranchServicesModule {}
