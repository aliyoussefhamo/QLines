import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'node:crypto';
import { In, Repository } from 'typeorm';
import { BranchServicesService } from '../branch-services/branch-services.service';
import { BranchesService } from '../branches/branches.service';
import { calculateQueueDurationMinutes } from '../branches/utils/calculate-queue-duration';
import { CreateReservationDto } from './dto/create-reservation.dto';
import { ReservationEntity } from './entities/reservation.entity';
import { ReservationStatus } from './models/reservation-status';
import { Reservation } from './models/reservation';
import { StaffQueueItem } from './models/staff-queue-item';

@Injectable()
export class ReservationsService {
  constructor(
    @InjectRepository(ReservationEntity)
    private readonly reservationsRepository: Repository<ReservationEntity>,
    private readonly branchesService: BranchesService,
    private readonly branchServicesService: BranchServicesService,
  ) {}

  async create(
    userId: string,
    createReservationDto: CreateReservationDto,
  ): Promise<Reservation> {
    const branch = await this.branchesService.findById(
      createReservationDto.branchId,
    );
    if (!branch) {
      throw new NotFoundException('Branch not found');
    }

    const branchService = await this.branchServicesService.findById(
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

    const activeReservationsAhead = await this.reservationsRepository.count({
      where: {
        branchId: branch.id,
        serviceId: branchService.id,
        status: ReservationStatus.Waiting,
      },
    });
    const estimatedWaitMinutes = calculateQueueDurationMinutes(
      branchService.peopleWaiting,
      branchService.bookingsAhead + activeReservationsAhead,
      branchService.activeServiceCounters,
      branchService.averageServiceDurationMinutes,
    );
    const lastBranchReservation = await this.reservationsRepository.findOne({
      where: { branchId: branch.id },
      order: { ticketNumber: 'DESC' },
    });
    const createdAt = new Date();
    const entity = this.reservationsRepository.create({
      id: randomUUID(),
      userId,
      branchId: branch.id,
      serviceId: branchService.id,
      ticketNumber: (lastBranchReservation?.ticketNumber ?? 0) + 1,
      status: ReservationStatus.Waiting,
      estimatedTurnAt: new Date(
        createdAt.getTime() + estimatedWaitMinutes * 60_000,
      ),
      qrToken: randomUUID(),
      createdAt,
    });

    return this.toReservation(await this.reservationsRepository.save(entity));
  }

  async findByUserId(userId: string): Promise<Reservation[]> {
    const reservations = await this.reservationsRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
    return reservations.map((reservation) => this.toReservation(reservation));
  }

  async findById(reservationId: string, userId: string): Promise<Reservation> {
    const reservation = await this.findEntityById(reservationId, userId);
    return this.toReservation(reservation);
  }

  async cancel(reservationId: string, userId: string): Promise<Reservation> {
    const reservation = await this.findEntityById(reservationId, userId);
    if (reservation.status !== ReservationStatus.Waiting) {
      throw new BadRequestException(
        'Only waiting reservations can be cancelled',
      );
    }
    reservation.status = ReservationStatus.Cancelled;
    return this.toReservation(
      await this.reservationsRepository.save(reservation),
    );
  }

  async verifyQrToken(qrToken: string): Promise<Reservation> {
    const reservation = await this.reservationsRepository.findOne({
      where: { qrToken },
    });
    if (!reservation) {
      throw new NotFoundException('Reservation QR code is invalid');
    }
    if (
      reservation.status === ReservationStatus.Cancelled ||
      reservation.status === ReservationStatus.Completed
    ) {
      throw new BadRequestException('Reservation QR code is no longer active');
    }
    return this.toReservation(reservation);
  }

  async findStaffQueue(branchId: string): Promise<StaffQueueItem[]> {
    const reservations = await this.reservationsRepository.find({
      where: {
        branchId,
        status: In([
          ReservationStatus.Waiting,
          ReservationStatus.CheckedIn,
          ReservationStatus.Called,
        ]),
      },
      relations: { service: true },
      order: { ticketNumber: 'ASC' },
    });
    return reservations.map((reservation) =>
      this.toStaffQueueItem(reservation),
    );
  }

  async callNext(branchId: string): Promise<StaffQueueItem> {
    const alreadyCalled = await this.reservationsRepository.findOne({
      where: { branchId, status: ReservationStatus.Called },
      relations: { service: true },
      order: { ticketNumber: 'ASC' },
    });
    if (alreadyCalled) return this.toStaffQueueItem(alreadyCalled);

    const next = await this.reservationsRepository.findOne({
      where: {
        branchId,
        status: ReservationStatus.CheckedIn,
      },
      relations: { service: true },
      order: { ticketNumber: 'ASC' },
    });
    if (!next) {
      throw new NotFoundException('There are no checked-in reservations');
    }
    next.status = ReservationStatus.Called;
    return this.toStaffQueueItem(await this.reservationsRepository.save(next));
  }

  async updateByStaff(
    branchId: string,
    reservationId: string,
    status: ReservationStatus.Completed | ReservationStatus.NoShow,
  ): Promise<StaffQueueItem> {
    const reservation = await this.reservationsRepository.findOne({
      where: { id: reservationId, branchId },
      relations: { service: true },
    });
    if (!reservation) throw new NotFoundException('Reservation not found');
    if (reservation.status !== ReservationStatus.Called) {
      throw new BadRequestException('Only a called reservation can be updated');
    }
    reservation.status = status;
    return this.toStaffQueueItem(
      await this.reservationsRepository.save(reservation),
    );
  }

  async checkInByQr(
    branchId: string,
    qrToken: string,
  ): Promise<StaffQueueItem> {
    const reservation = await this.reservationsRepository.findOne({
      where: { qrToken },
      relations: { service: true },
    });
    if (!reservation || reservation.branchId !== branchId) {
      throw new NotFoundException(
        'Reservation QR code is invalid for this branch',
      );
    }
    if (reservation.status === ReservationStatus.CheckedIn) {
      return this.toStaffQueueItem(reservation);
    }
    if (reservation.status !== ReservationStatus.Waiting) {
      throw new BadRequestException('Reservation cannot be checked in');
    }
    reservation.status = ReservationStatus.CheckedIn;
    return this.toStaffQueueItem(
      await this.reservationsRepository.save(reservation),
    );
  }

  private async findEntityById(
    reservationId: string,
    userId: string,
  ): Promise<ReservationEntity> {
    const reservation = await this.reservationsRepository.findOne({
      where: { id: reservationId, userId },
    });
    if (!reservation) {
      throw new NotFoundException('Reservation not found');
    }
    return reservation;
  }

  private toReservation(entity: ReservationEntity): Reservation {
    return {
      id: entity.id,
      userId: entity.userId,
      branchId: entity.branchId,
      serviceId: entity.serviceId,
      ticketNumber: entity.ticketNumber,
      status: entity.status,
      createdAt: entity.createdAt.toISOString(),
      estimatedTurnAt: entity.estimatedTurnAt.toISOString(),
      qrToken: entity.qrToken,
    };
  }

  private toStaffQueueItem(entity: ReservationEntity): StaffQueueItem {
    return {
      ...this.toReservation(entity),
      serviceName: entity.service.name,
    };
  }
}
