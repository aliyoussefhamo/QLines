import { Module } from '@nestjs/common';
import { HealthController } from './health/health.controller';
import { OrganizationsModule } from './organizations/organizations.module';
import { BranchesModule } from './branches/branches.module';

@Module({
  controllers: [HealthController],
  imports: [OrganizationsModule, BranchesModule],
})
export class AppModule {}
