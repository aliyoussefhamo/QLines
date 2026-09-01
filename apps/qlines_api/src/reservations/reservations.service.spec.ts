import { Test, TestingModule } from '@nestjs/testing';
import { BranchServicesService } from '../branch-services/branch-services.service';
import { BranchesService } from '../branches/branches.service';
import { ReservationsService } from './reservations.service';

describe('ReservationsService', () => {
  let service: ReservationsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReservationsService,
        BranchServicesService,
        {
          provide: BranchesService,
          useValue: {
            findById: jest.fn().mockResolvedValue({
              id: 'citizen-center-mazzeh',
              isActive: true,
            }),
          },
        },
      ],
    }).compile();
    service = module.get(ReservationsService);
  });

  it('should create and cancel a reservation', async () => {
    const reservation = await service.create({
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
    });
    expect(reservation.ticketNumber).toBe(1);
    expect(service.cancel(reservation.id).status).toBe('cancelled');
  });

  it('should reject an unknown reservation id', () => {
    expect(() => service.findById('missing-reservation')).toThrow(
      'Reservation not found',
    );
  });
});
