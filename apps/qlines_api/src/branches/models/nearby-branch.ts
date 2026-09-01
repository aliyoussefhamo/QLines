import { Branch } from './branch';
import { TravelMode } from './travel-mode';

export type NearbyBranch = Branch & {
  distanceKm: number;
  travelMode: TravelMode;
  estimatedTravelMinutes: number;
  peopleAhead: number;
  estimatedQueueMinutes: number;
  estimatedWaitAfterArrivalMinutes: number;
  estimatedTotalMinutes: number;
};
