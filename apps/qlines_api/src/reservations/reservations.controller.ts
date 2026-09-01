import { Body, Controller, Get, Param, Patch, Post } from '@nestjs/common';
import { CreateReservationDto } from './dto/create-reservation.dto';
import { VerifyReservationQrDto } from './dto/verify-reservation-qr.dto';
import type { Reservation } from './models/reservation';
import { ReservationsService } from './reservations.service';

@Controller('reservations')
export class ReservationsController {
  constructor(private readonly reservationsService: ReservationsService) {}

  @Post()
  create(
    @Body() createReservationDto: CreateReservationDto,
  ): Promise<Reservation> {
    return this.reservationsService.create(createReservationDto);
  }

  @Post('verify-qr')
  verifyQr(
    @Body() verifyReservationQrDto: VerifyReservationQrDto,
  ): Promise<Reservation> {
    return this.reservationsService.verifyQrToken(
      verifyReservationQrDto.qrToken,
    );
  }

  @Get()
  findAll(): Promise<Reservation[]> {
    return this.reservationsService.findAll();
  }

  @Get(':reservationId')
  findById(
    @Param('reservationId') reservationId: string,
  ): Promise<Reservation> {
    return this.reservationsService.findById(reservationId);
  }

  @Patch(':reservationId/cancel')
  cancel(@Param('reservationId') reservationId: string): Promise<Reservation> {
    return this.reservationsService.cancel(reservationId);
  }
}
