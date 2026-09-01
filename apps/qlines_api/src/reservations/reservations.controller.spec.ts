import { Test, TestingModule } from '@nestjs/testing';
import { ReservationsController } from './reservations.controller';
import { ReservationsService } from './reservations.service';

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
    }).compile();
    controller = module.get(ReservationsController);
  });

  it('should create a reservation', async () => {
    await expect(
      controller.create({
        userId: 'demo-user',
        branchId: 'citizen-center-mazzeh',
        serviceId: 'mazzeh-civil-record',
      }),
    ).resolves.toEqual(reservation);
  });
});
