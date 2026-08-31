export type Branch = {
  id: string;
  organizationId: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
  peopleWaiting: number;
  averageServiceDurationMinutes: number;
  isActive: boolean;
};
