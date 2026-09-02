import { IsEnum } from 'class-validator';
import { ReservationStatus } from '../models/reservation-status';

export class UpdateStaffReservationStatusDto {
  @IsEnum([ReservationStatus.Completed, ReservationStatus.NoShow])
  status!: ReservationStatus.Completed | ReservationStatus.NoShow;
}
