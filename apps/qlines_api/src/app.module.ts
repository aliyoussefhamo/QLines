import { Module } from '@nestjs/common';
import { HealthController } from './health/health.controller';
import { OrganizationsModule } from './organizations/organizations.module';

@Module({
  controllers: [HealthController],
  imports: [OrganizationsModule],
})
export class AppModule {}
