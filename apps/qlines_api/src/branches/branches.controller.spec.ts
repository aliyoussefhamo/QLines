import { Test, TestingModule } from '@nestjs/testing';
import { BranchesController } from './branches.controller';
import { BranchesService } from './branches.service';

describe('BranchesController', () => {
  const branches = [
    {
      id: 'citizen-center-mazzeh',
      organizationId: 'citizen-center',
      name: 'مركز خدمة المواطن - المزة',
      address: 'المزة، دمشق',
      latitude: 33.5038,
      longitude: 36.2501,
      peopleWaiting: 12,
      bookingsAhead: 4,
      activeServiceCounters: 2,
      averageServiceDurationMinutes: 8,
      isActive: true,
    },
  ];
  let controller: BranchesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [BranchesController],
      providers: [
        {
          provide: BranchesService,
          useValue: {
            findByOrganizationId: jest.fn().mockResolvedValue(branches),
          },
        },
      ],
    }).compile();
    controller = module.get(BranchesController);
  });

  it('should return branches for the requested organization', async () => {
    await expect(
      controller.findByOrganizationId('citizen-center'),
    ).resolves.toEqual(branches);
  });
});
