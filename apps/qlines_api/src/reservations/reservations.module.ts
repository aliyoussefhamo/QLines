import { Module } from '@nestjs/common';
import { BranchServicesModule } from '../branch-services/branch-services.module';
import { BranchesModule } from '../branches/branches.module';
import { ReservationsController } from './reservations.controller';
import { ReservationsService } from './reservations.service';
import { StaffQueueController } from './staff-queue.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReservationEntity } from './entities/reservation.entity';
import { AuthModule } from '../auth/auth.module';
import { ReservationEventsGateway } from './reservation-events.gateway';

@Module({
  imports: [
    TypeOrmModule.forFeature([ReservationEntity]),
    AuthModule,
    BranchesModule,
    BranchServicesModule,
  ],
  controllers: [ReservationsController, StaffQueueController],
  providers: [ReservationsService, ReservationEventsGateway],
})
export class ReservationsModule {}
