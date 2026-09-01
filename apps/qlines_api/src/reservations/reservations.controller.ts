import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { TokenPayload } from '../auth/token.service';
import { CreateReservationDto } from './dto/create-reservation.dto';
import { VerifyReservationQrDto } from './dto/verify-reservation-qr.dto';
import type { Reservation } from './models/reservation';
import { ReservationsService } from './reservations.service';

@Controller('reservations')
export class ReservationsController {
  constructor(private readonly reservationsService: ReservationsService) {}

  @Post()
  @UseGuards(AuthGuard)
  create(
    @CurrentUser() user: TokenPayload,
    @Body() createReservationDto: CreateReservationDto,
  ): Promise<Reservation> {
    return this.reservationsService.create(user.sub, createReservationDto);
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
  @UseGuards(AuthGuard)
  findAll(@CurrentUser() user: TokenPayload): Promise<Reservation[]> {
    return this.reservationsService.findByUserId(user.sub);
  }

  @Get(':reservationId')
  @UseGuards(AuthGuard)
  findById(
    @CurrentUser() user: TokenPayload,
    @Param('reservationId') reservationId: string,
  ): Promise<Reservation> {
    return this.reservationsService.findById(reservationId, user.sub);
  }

  @Patch(':reservationId/cancel')
  @UseGuards(AuthGuard)
  cancel(
    @CurrentUser() user: TokenPayload,
    @Param('reservationId') reservationId: string,
  ): Promise<Reservation> {
    return this.reservationsService.cancel(reservationId, user.sub);
  }
}
