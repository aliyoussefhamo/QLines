import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CreateOrganizations1788283200000 } from './database/migrations/1788283200000-create-organizations';
import { CreateBranches1788286800000 } from './database/migrations/1788286800000-create-branches';
import { CreateBranchServices1788290400000 } from './database/migrations/1788290400000-create-branch-services';
import { CreateReservations1788294000000 } from './database/migrations/1788294000000-create-reservations';
import { CreateUsers1788297600000 } from './database/migrations/1788297600000-create-users';
import { AddEmailVerification1788301200000 } from './database/migrations/1788301200000-add-email-verification';
import { CreatePasswordResetCodes1788304800000 } from './database/migrations/1788304800000-create-password-reset-codes';
import { AddStaffRoles1788308400000 } from './database/migrations/1788308400000-add-staff-roles';
import { AddReservationCheckIn1788312000000 } from './database/migrations/1788312000000-add-reservation-check-in';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { HealthController } from './health/health.controller';
import { OrganizationsModule } from './organizations/organizations.module';
import { BranchesModule } from './branches/branches.module';
import { BranchServicesModule } from './branch-services/branch-services.module';
import { ReservationsModule } from './reservations/reservations.module';

@Module({
  controllers: [HealthController],
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.getOrThrow<string>('DB_HOST'),
        port: Number(configService.getOrThrow<string>('DB_PORT')),
        username: configService.getOrThrow<string>('DB_USERNAME'),
        password: configService.getOrThrow<string>('DB_PASSWORD'),
        database: configService.getOrThrow<string>('DB_NAME'),
        autoLoadEntities: true,
        migrations: [
          CreateOrganizations1788283200000,
          CreateBranches1788286800000,
          CreateBranchServices1788290400000,
          CreateReservations1788294000000,
          CreateUsers1788297600000,
          AddEmailVerification1788301200000,
          CreatePasswordResetCodes1788304800000,
          AddStaffRoles1788308400000,
          AddReservationCheckIn1788312000000,
        ],
        migrationsRun: true,
        synchronize: false,
      }),
    }),
    OrganizationsModule,
    BranchesModule,
    BranchServicesModule,
    ReservationsModule,
    UsersModule,
    AuthModule,
  ],
})
export class AppModule {}
