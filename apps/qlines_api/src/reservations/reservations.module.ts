import { Module } from '@nestjs/common';
import { BranchServicesModule } from '../branch-services/branch-services.module';
import { BranchesModule } from '../branches/branches.module';
import { ReservationsController } from './reservations.controller';
import { ReservationsService } from './reservations.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReservationEntity } from './entities/reservation.entity';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([ReservationEntity]),
    AuthModule,
    BranchesModule,
    BranchServicesModule,
  ],
  controllers: [ReservationsController],
  providers: [ReservationsService],
})
export class ReservationsModule {}
