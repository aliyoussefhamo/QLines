import { getRepositoryToken } from '@nestjs/typeorm';
import { Test, TestingModule } from '@nestjs/testing';
import { Repository } from 'typeorm';
import { BranchEntity } from './entities/branch.entity';
import { BranchesService } from './branches.service';

describe('BranchesService', () => {
  let service: BranchesService;
  let repository: Pick<Repository<BranchEntity>, 'find' | 'findOne'>;

  const branch = {
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
  } as BranchEntity;

  beforeEach(async () => {
    repository = { find: jest.fn(), findOne: jest.fn() };
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BranchesService,
        { provide: getRepositoryToken(BranchEntity), useValue: repository },
      ],
    }).compile();
    service = module.get(BranchesService);
  });

  it('should return active branches for an organization', async () => {
    jest.mocked(repository.find).mockResolvedValue([branch]);
    await expect(
      service.findByOrganizationId('citizen-center'),
    ).resolves.toEqual([expect.objectContaining({ id: branch.id })]);
  });

  it('should find an active branch by id', async () => {
    jest.mocked(repository.findOne).mockResolvedValue(branch);
    await expect(service.findById(branch.id)).resolves.toEqual(
      expect.objectContaining({ id: branch.id }),
    );
  });
});
