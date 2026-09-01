import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'node:crypto';
import { BranchServicesService } from '../branch-services/branch-services.service';
import { BranchesService } from '../branches/branches.service';
import { calculateQueueDurationMinutes } from '../branches/utils/calculate-queue-duration';
import { CreateReservationDto } from './dto/create-reservation.dto';
import { Reservation } from './models/reservation';
import { ReservationStatus } from './models/reservation-status';

@Injectable()
export class ReservationsService {
  private readonly reservations: Reservation[] = [];

  constructor(
    private readonly branchesService: BranchesService,
    private readonly branchServicesService: BranchServicesService,
  ) {}

  create(createReservationDto: CreateReservationDto): Reservation {
    const branch = this.branchesService.findById(createReservationDto.branchId);

    if (!branch) {
      throw new NotFoundException('Branch not found');
    }

    const branchService = this.branchServicesService.findById(
      createReservationDto.serviceId,
    );

    if (!branchService) {
      throw new NotFoundException('Service not found');
    }

    if (branchService.branchId !== branch.id) {
      throw new BadRequestException(
        'The selected service does not belong to this branch',
      );
    }

    const activeReservationsAhead = this.reservations.filter(
      (reservation) =>
        reservation.branchId === branch.id &&
        reservation.serviceId === branchService.id &&
        reservation.status === ReservationStatus.Waiting,
    ).length;

    const estimatedWaitMinutes = calculateQueueDurationMinutes(
      branchService.peopleWaiting,
      branchService.bookingsAhead + activeReservationsAhead,
      branchService.activeServiceCounters,
      branchService.averageServiceDurationMinutes,
    );

    const ticketNumber = this.getNextTicketNumber(branch.id);
    const createdAt = new Date();

    const reservation: Reservation = {
      id: randomUUID(),
      userId: createReservationDto.userId,
      branchId: branch.id,
      serviceId: branchService.id,
      ticketNumber,
      status: ReservationStatus.Waiting,
      createdAt: createdAt.toISOString(),
      estimatedTurnAt: new Date(
        createdAt.getTime() + estimatedWaitMinutes * 60_000,
      ).toISOString(),
      qrToken: randomUUID(),
    };

    this.reservations.push(reservation);

    return reservation;
  }

  findAll(): Reservation[] {
    return [...this.reservations];
  }

  findById(reservationId: string): Reservation {
    const reservation = this.reservations.find(
      (item) => item.id === reservationId,
    );

    if (!reservation) {
      throw new NotFoundException('Reservation not found');
    }

    return reservation;
  }

  cancel(reservationId: string): Reservation {
    const reservation = this.findById(reservationId);

    if (reservation.status !== ReservationStatus.Waiting) {
      throw new BadRequestException(
        'Only waiting reservations can be cancelled',
      );
    }

    reservation.status = ReservationStatus.Cancelled;

    return reservation;
  }

  verifyQrToken(qrToken: string): Reservation {
    const reservation = this.reservations.find(
      (item) => item.qrToken === qrToken,
    );

    if (!reservation) {
      throw new NotFoundException('Reservation QR code is invalid');
    }

    if (
      reservation.status === ReservationStatus.Cancelled ||
      reservation.status === ReservationStatus.Completed
    ) {
      throw new BadRequestException('Reservation QR code is no longer active');
    }

    return reservation;
  }

  private getNextTicketNumber(branchId: string): number {
    const branchTicketNumbers = this.reservations
      .filter((reservation) => reservation.branchId === branchId)
      .map((reservation) => reservation.ticketNumber);

    return Math.max(0, ...branchTicketNumbers) + 1;
  }
}
