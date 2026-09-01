import { Test, TestingModule } from '@nestjs/testing';
import { BranchServicesModule } from '../branch-services/branch-services.module';
import { BranchesModule } from '../branches/branches.module';
import { ReservationsService } from './reservations.service';

describe('ReservationsService', () => {
  let service: ReservationsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [BranchesModule, BranchServicesModule],
      providers: [ReservationsService],
    }).compile();

    service = module.get<ReservationsService>(ReservationsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should create a reservation', () => {
    const reservation = service.create({
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
    });

    expect(reservation.ticketNumber).toBe(1);
    expect(reservation.status).toBe('waiting');
    expect(reservation.qrToken).toBeTruthy();
  });
});
