import { calculateDistanceKm } from './calculate-distance';

describe('calculateDistanceKm', () => {
  it('should return zero for the same location', () => {
    const distance = calculateDistanceKm(33.5038, 36.2501, 33.5038, 36.2501);

    expect(distance).toBeCloseTo(0, 5);
  });

  it('should calculate approximately 111.2 km for one latitude degree', () => {
    const distance = calculateDistanceKm(0, 0, 1, 0);

    expect(distance).toBeCloseTo(111.2, 1);
  });

  it('should return the same distance in both directions', () => {
    const firstDirection = calculateDistanceKm(
      33.5038,
      36.2501,
      33.5148,
      36.3164,
    );

    const oppositeDirection = calculateDistanceKm(
      33.5148,
      36.3164,
      33.5038,
      36.2501,
    );

    expect(firstDirection).toBeCloseTo(oppositeDirection, 5);
  });
});
