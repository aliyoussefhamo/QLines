import { Test, TestingModule } from '@nestjs/testing';
import { BranchesController } from './branches.controller';
import { BranchesService } from './branches.service';

describe('BranchesController', () => {
  let controller: BranchesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [BranchesController],
      providers: [BranchesService],
    }).compile();

    controller = module.get<BranchesController>(BranchesController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should return branches for the requested organization', () => {
    const branches = controller.findByOrganizationId('citizen-center');

    expect(branches).toHaveLength(3);
    expect(
      branches.every((branch) => branch.organizationId === 'citizen-center'),
    ).toBe(true);
  });
});
