import { Test, TestingModule } from '@nestjs/testing';
import { BranchServicesModule } from '../branch-services/branch-services.module';
import { BranchesModule } from '../branches/branches.module';
import { ReservationsController } from './reservations.controller';
import { ReservationsService } from './reservations.service';

describe('ReservationsController', () => {
  let controller: ReservationsController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [BranchesModule, BranchServicesModule],
      controllers: [ReservationsController],
      providers: [ReservationsService],
    }).compile();

    controller = module.get<ReservationsController>(ReservationsController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should create a reservation', () => {
    const reservation = controller.create({
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
    });

    expect(reservation.ticketNumber).toBe(1);
    expect(reservation.status).toBe('waiting');
  });

  it('should return and cancel a reservation', () => {
    const createdReservation = controller.create({
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
    });

    expect(controller.findById(createdReservation.id)).toEqual(
      createdReservation,
    );
    expect(controller.cancel(createdReservation.id).status).toBe('cancelled');
  });

  it('should verify a reservation QR token', () => {
    const createdReservation = controller.create({
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
    });

    expect(
      controller.verifyQr({ qrToken: createdReservation.qrToken }),
    ).toEqual(createdReservation);
  });
});
