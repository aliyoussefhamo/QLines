import { ReservationStatus } from './reservation-status';

export type Reservation = {
  id: string;
  userId: string;
  branchId: string;
  serviceId: string;
  ticketNumber: number;
  status: ReservationStatus;
  createdAt: string;
  estimatedTurnAt: string;
  qrToken: string;
};
