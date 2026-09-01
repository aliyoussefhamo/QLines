import { Test, TestingModule } from '@nestjs/testing';
import { BranchServicesController } from './branch-services.controller';
import { BranchServicesService } from './branch-services.service';

describe('BranchServicesController', () => {
  let controller: BranchServicesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [BranchServicesController],
      providers: [BranchServicesService],
    }).compile();

    controller = module.get<BranchServicesController>(BranchServicesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should return services for the requested branch', () => {
    const services = controller.findByBranchId('citizen-center-mazzeh');

    expect(services).toHaveLength(2);
    expect(
      services.every((service) => service.branchId === 'citizen-center-mazzeh'),
    ).toBe(true);
  });
});
