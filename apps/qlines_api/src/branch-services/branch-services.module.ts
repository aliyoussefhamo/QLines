import { Module } from '@nestjs/common';
import { BranchServicesController } from './branch-services.controller';
import { BranchServicesService } from './branch-services.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BranchServiceEntity } from './entities/branch-service.entity';

@Module({
  imports: [TypeOrmModule.forFeature([BranchServiceEntity])],
  controllers: [BranchServicesController],
  providers: [BranchServicesService],
  exports: [BranchServicesService],
})
export class BranchServicesModule {}
