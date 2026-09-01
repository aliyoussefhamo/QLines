import { Test, TestingModule } from '@nestjs/testing';
import { OrganizationsController } from './organizations.controller';
import { OrganizationsService } from './organizations.service';

describe('OrganizationsController', () => {
  let controller: OrganizationsController;
  const organizations = [
    {
      id: 'citizen-center',
      name: 'مركز خدمة المواطن',
      category: 'خدمات حكومية',
      branchCount: 3,
      isActive: true,
    },
  ];
  const organizationsService = {
    findAll: jest.fn(),
  };

  beforeEach(async () => {
    organizationsService.findAll.mockReset();
    organizationsService.findAll.mockResolvedValue(organizations);

    const module: TestingModule = await Test.createTestingModule({
      controllers: [OrganizationsController],
      providers: [
        {
          provide: OrganizationsService,
          useValue: organizationsService,
        },
      ],
    }).compile();

    controller = module.get<OrganizationsController>(OrganizationsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should return all organizations', async () => {
    await expect(controller.findAll()).resolves.toEqual(organizations);
    expect(organizationsService.findAll).toHaveBeenCalledTimes(1);
  });
});
