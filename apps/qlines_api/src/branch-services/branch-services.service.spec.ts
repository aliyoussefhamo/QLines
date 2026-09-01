import { Test, TestingModule } from '@nestjs/testing';
import { BranchServicesService } from './branch-services.service';

describe('BranchServicesService', () => {
  let service: BranchServicesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [BranchServicesService],
    }).compile();

    service = module.get<BranchServicesService>(BranchServicesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
