import { getRepositoryToken } from '@nestjs/typeorm';
import { Test, TestingModule } from '@nestjs/testing';
import { Repository } from 'typeorm';
import { BranchServicesService } from '../branch-services/branch-services.service';
import { BranchesService } from '../branches/branches.service';
import { ReservationEntity } from './entities/reservation.entity';
import { ReservationStatus } from './models/reservation-status';
import { ReservationsService } from './reservations.service';

describe('ReservationsService', () => {
  let service: ReservationsService;
  let repository: Pick<
    Repository<ReservationEntity>,
    'count' | 'findOne' | 'create' | 'save' | 'find'
  >;

  beforeEach(async () => {
    repository = {
      count: jest.fn().mockResolvedValue(0),
      findOne: jest.fn().mockResolvedValue(null),
      create: jest.fn((value) => value as ReservationEntity),
      save: jest.fn((value) => Promise.resolve(value as ReservationEntity)),
      find: jest.fn().mockResolvedValue([]),
    };
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReservationsService,
        {
          provide: getRepositoryToken(ReservationEntity),
          useValue: repository,
        },
        {
          provide: BranchServicesService,
          useValue: {
            findById: jest.fn().mockResolvedValue({
              id: 'mazzeh-civil-record',
              branchId: 'citizen-center-mazzeh',
              peopleWaiting: 6,
              bookingsAhead: 2,
              activeServiceCounters: 2,
              averageServiceDurationMinutes: 8,
              isAvailable: true,
            }),
          },
        },
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

  it('should persist a reservation with the next ticket number', async () => {
    const reservation = await service.create({
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
    });
    expect(reservation.ticketNumber).toBe(1);
    expect(reservation.status).toBe(ReservationStatus.Waiting);
    expect(repository.save).toHaveBeenCalled();
  });

  it('should cancel a waiting reservation', async () => {
    const entity = {
      id: '1e35558a-b52e-4d1f-9133-8bd604a926f1',
      userId: 'demo-user',
      branchId: 'citizen-center-mazzeh',
      serviceId: 'mazzeh-civil-record',
      ticketNumber: 1,
      status: ReservationStatus.Waiting,
      createdAt: new Date(),
      estimatedTurnAt: new Date(),
      qrToken: 'a8536644-a386-4498-bfb8-f827da3ca240',
    } as ReservationEntity;
    jest.mocked(repository.findOne).mockResolvedValue(entity);

    await expect(service.cancel(entity.id)).resolves.toEqual(
      expect.objectContaining({ status: ReservationStatus.Cancelled }),
    );
  });

  it('should reject an unknown reservation id', async () => {
    await expect(service.findById('missing-reservation')).rejects.toThrow(
      'Reservation not found',
    );
  });
});
