export type Branch = {
  id: string;
  organizationId: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
  peopleWaiting: number;
  bookingsAhead: number;
  activeServiceCounters: number;
  averageServiceDurationMinutes: number;
  isActive: boolean;
};
