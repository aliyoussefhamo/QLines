import { Module } from '@nestjs/common';
import { BranchServicesModule } from '../branch-services/branch-services.module';
import { BranchesModule } from '../branches/branches.module';
import { ReservationsController } from './reservations.controller';
import { ReservationsService } from './reservations.service';

@Module({
  imports: [BranchesModule, BranchServicesModule],
  controllers: [ReservationsController],
  providers: [ReservationsService],
})
export class ReservationsModule {}
