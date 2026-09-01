import { IsUUID } from 'class-validator';

export class VerifyReservationQrDto {
  @IsUUID()
  qrToken!: string;
}
