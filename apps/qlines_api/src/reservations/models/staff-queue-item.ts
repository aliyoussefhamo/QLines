import { Reservation } from './reservation';

export type StaffQueueItem = Reservation & {
  serviceName: string;
};
