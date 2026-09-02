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
import { StaffGuard } from '../auth/staff.guard';
import type { TokenPayload } from '../auth/token.service';
import { UpdateStaffReservationStatusDto } from './dto/update-staff-reservation-status.dto';
import { VerifyReservationQrDto } from './dto/verify-reservation-qr.dto';
import type { StaffQueueItem } from './models/staff-queue-item';
import { ReservationsService } from './reservations.service';

@Controller('staff/queue')
@UseGuards(AuthGuard, StaffGuard)
export class StaffQueueController {
  constructor(private readonly reservationsService: ReservationsService) {}

  @Get()
  findQueue(@CurrentUser() user: TokenPayload): Promise<StaffQueueItem[]> {
    return this.reservationsService.findStaffQueue(user.employeeBranchId!);
  }

  @Patch('next')
  callNext(@CurrentUser() user: TokenPayload): Promise<StaffQueueItem> {
    return this.reservationsService.callNext(user.employeeBranchId!);
  }

  @Patch(':reservationId/status')
  updateStatus(
    @CurrentUser() user: TokenPayload,
    @Param('reservationId') reservationId: string,
    @Body() dto: UpdateStaffReservationStatusDto,
  ): Promise<StaffQueueItem> {
    return this.reservationsService.updateByStaff(
      user.employeeBranchId!,
      reservationId,
      dto.status,
    );
  }

  @Post('check-in')
  checkIn(
    @CurrentUser() user: TokenPayload,
    @Body() dto: VerifyReservationQrDto,
  ): Promise<StaffQueueItem> {
    return this.reservationsService.checkInByQr(
      user.employeeBranchId!,
      dto.qrToken,
    );
  }
}
