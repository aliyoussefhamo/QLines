import { getRepositoryToken } from '@nestjs/typeorm';
import { Test, TestingModule } from '@nestjs/testing';
import { Repository } from 'typeorm';
import { BranchServicesService } from './branch-services.service';
import { BranchServiceEntity } from './entities/branch-service.entity';

describe('BranchServicesService', () => {
  let service: BranchServicesService;
  let repository: Pick<Repository<BranchServiceEntity>, 'find' | 'findOne'>;
  const branchService = {
    id: 'mazzeh-civil-record',
    branchId: 'citizen-center-mazzeh',
    name: 'إخراج قيد مدني',
    description: 'إصدار وثيقة قيد مدني للمواطن',
    requiredDocuments: ['البطاقة الشخصية'],
    requirements: ['حضور صاحب العلاقة'],
    steps: ['حجز الدور'],
    notes: [],
    feeAmount: 5000,
    currency: 'SYP',
    peopleWaiting: 6,
    bookingsAhead: 2,
    activeServiceCounters: 2,
    averageServiceDurationMinutes: 8,
    isAvailable: true,
  } as BranchServiceEntity;

  beforeEach(async () => {
    repository = { find: jest.fn(), findOne: jest.fn() };
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BranchServicesService,
        {
          provide: getRepositoryToken(BranchServiceEntity),
          useValue: repository,
        },
      ],
    }).compile();
    service = module.get(BranchServicesService);
  });

  it('should return available services for a branch', async () => {
    jest.mocked(repository.find).mockResolvedValue([branchService]);
    await expect(
      service.findByBranchId('citizen-center-mazzeh'),
    ).resolves.toEqual([expect.objectContaining({ id: branchService.id })]);
  });

  it('should find an available service by id', async () => {
    jest.mocked(repository.findOne).mockResolvedValue(branchService);
    await expect(service.findById(branchService.id)).resolves.toEqual(
      expect.objectContaining({ id: branchService.id }),
    );
  });
});
