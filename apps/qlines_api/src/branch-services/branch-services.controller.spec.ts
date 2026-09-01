import { Test, TestingModule } from '@nestjs/testing';
import { BranchServicesController } from './branch-services.controller';
import { BranchServicesService } from './branch-services.service';

describe('BranchServicesController', () => {
  let controller: BranchServicesController;
  const services = [
    {
      id: 'mazzeh-civil-record',
      branchId: 'citizen-center-mazzeh',
      name: 'إخراج قيد مدني',
      description: 'إصدار وثيقة قيد مدني للمواطن',
      requiredDocuments: ['البطاقة الشخصية'],
      requirements: [],
      steps: [],
      notes: [],
      feeAmount: 5000,
      currency: 'SYP',
      peopleWaiting: 6,
      bookingsAhead: 2,
      activeServiceCounters: 2,
      averageServiceDurationMinutes: 8,
      isAvailable: true,
    },
  ];

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [BranchServicesController],
      providers: [
        {
          provide: BranchServicesService,
          useValue: { findByBranchId: jest.fn().mockResolvedValue(services) },
        },
      ],
    }).compile();
    controller = module.get(BranchServicesController);
  });

  it('should return services for the requested branch', async () => {
    await expect(
      controller.findByBranchId('citizen-center-mazzeh'),
    ).resolves.toEqual(services);
  });
});
