import { Body, Controller, Get, Post } from '@nestjs/common';
import { CreateReservationDto } from './dto/create-reservation.dto';
import type { Reservation } from './models/reservation';
import { ReservationsService } from './reservations.service';

@Controller('reservations')
export class ReservationsController {
  constructor(private readonly reservationsService: ReservationsService) {}

  @Post()
  create(@Body() createReservationDto: CreateReservationDto): Reservation {
    return this.reservationsService.create(createReservationDto);
  }

  @Get()
  findAll(): Reservation[] {
    return this.reservationsService.findAll();
  }
}
