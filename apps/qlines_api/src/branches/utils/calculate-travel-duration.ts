import { TravelMode } from '../models/travel-mode';

const walkingSpeedKmPerHour = 5;
const drivingSpeedKmPerHour = 30;

export function calculateTravelDurationMinutes(
  distanceKm: number,
  travelMode: TravelMode,
): number {
  const speedKmPerHour =
    travelMode === TravelMode.Walking
      ? walkingSpeedKmPerHour
      : drivingSpeedKmPerHour;

  const durationHours = distanceKm / speedKmPerHour;
  const durationMinutes = durationHours * 60;

  return Math.max(1, Math.ceil(durationMinutes));
}
