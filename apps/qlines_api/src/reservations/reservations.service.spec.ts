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

  it('should find a reservation by id', () => {
    const createdReservation = service.create({
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
    });

    expect(service.findById(createdReservation.id)).toEqual(createdReservation);
  });

  it('should cancel a waiting reservation', () => {
    const createdReservation = service.create({
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
    });

    const cancelledReservation = service.cancel(createdReservation.id);

    expect(cancelledReservation.status).toBe('cancelled');
  });

  it('should reject an unknown reservation id', () => {
    expect(() => service.findById('missing-reservation')).toThrow(
      'Reservation not found',
    );
  });

  it('should verify an active reservation QR token', () => {
    const createdReservation = service.create({
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
    });

    expect(service.verifyQrToken(createdReservation.qrToken)).toEqual(
      createdReservation,
    );
  });

  it('should reject a cancelled reservation QR token', () => {
    const createdReservation = service.create({
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
    });

    service.cancel(createdReservation.id);

    expect(() => service.verifyQrToken(createdReservation.qrToken)).toThrow(
      'Reservation QR code is no longer active',
    );
  });
});
