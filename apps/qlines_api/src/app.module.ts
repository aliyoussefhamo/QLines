import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CreateOrganizations1788283200000 } from './database/migrations/1788283200000-create-organizations';
import { CreateBranches1788286800000 } from './database/migrations/1788286800000-create-branches';
import { CreateBranchServices1788290400000 } from './database/migrations/1788290400000-create-branch-services';
import { CreateReservations1788294000000 } from './database/migrations/1788294000000-create-reservations';
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
        ],
        migrationsRun: true,
        synchronize: false,
      }),
    }),
    OrganizationsModule,
    BranchesModule,
    BranchServicesModule,
    ReservationsModule,
  ],
})
export class AppModule {}
