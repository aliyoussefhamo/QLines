import { Branch } from './branch';
import { TravelMode } from './travel-mode';

export type NearbyBranch = Branch & {
  distanceKm: number;
  travelMode: TravelMode;
  estimatedTravelMinutes: number;
};
