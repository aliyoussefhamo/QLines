import { Test, TestingModule } from '@nestjs/testing';
import { ReservationsController } from './reservations.controller';
import { ReservationsService } from './reservations.service';
import { AuthGuard } from '../auth/auth.guard';

describe('ReservationsController', () => {
  let controller: ReservationsController;
  const reservation = {
    id: 'reservation-1',
    userId: 'demo-user',
    branchId: 'citizen-center-mazzeh',
    serviceId: 'mazzeh-civil-record',
    ticketNumber: 1,
    status: 'waiting',
    createdAt: '2026-09-01T00:00:00.000Z',
    estimatedTurnAt: '2026-09-01T00:30:00.000Z',
    qrToken: 'qr-token',
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ReservationsController],
      providers: [
        {
          provide: ReservationsService,
          useValue: { create: jest.fn().mockResolvedValue(reservation) },
        },
      ],
    })
      .overrideGuard(AuthGuard)
      .useValue({ canActivate: () => true })
      .compile();
    controller = module.get(ReservationsController);
  });

  it('should create a reservation', async () => {
    await expect(
      controller.create(
        {
          sub: 'user-1',
          email: 'ali@example.com',
          iat: 1,
          exp: 2,
        },
        {
          branchId: 'citizen-center-mazzeh',
          serviceId: 'mazzeh-civil-record',
        },
      ),
    ).resolves.toEqual(reservation);
  });
});
