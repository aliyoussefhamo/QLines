import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { OrganizationEntity } from './entities/organization.entity';
import { OrganizationsService } from './organizations.service';

describe('OrganizationsService', () => {
  let service: OrganizationsService;
  const organizationRepository = {
    find: jest.fn(),
  };

  beforeEach(async () => {
    organizationRepository.find.mockReset();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OrganizationsService,
        {
          provide: getRepositoryToken(OrganizationEntity),
          useValue: organizationRepository,
        },
      ],
    }).compile();

    service = module.get<OrganizationsService>(OrganizationsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should return active organizations from the repository', async () => {
    organizationRepository.find.mockResolvedValue([
      {
        id: 'citizen-center',
        name: 'مركز خدمة المواطن',
        category: 'خدمات حكومية',
        branchCount: 3,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ]);

    await expect(service.findAll()).resolves.toEqual([
      {
        id: 'citizen-center',
        name: 'مركز خدمة المواطن',
        category: 'خدمات حكومية',
        branchCount: 3,
        isActive: true,
      },
    ]);
  });
});
