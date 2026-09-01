import { calculateQueueDurationMinutes } from './calculate-queue-duration';

describe('calculateQueueDurationMinutes', () => {
  it('should calculate the queue duration', () => {
    const duration = calculateQueueDurationMinutes(12, 4, 2, 8);

    expect(duration).toBe(64);
  });

  it('should round incomplete service rounds up', () => {
    const duration = calculateQueueDurationMinutes(7, 2, 2, 8);

    expect(duration).toBe(40);
  });

  it('should return zero when nobody is ahead', () => {
    const duration = calculateQueueDurationMinutes(0, 0, 2, 8);

    expect(duration).toBe(0);
  });

  it('should reject a branch without active counters', () => {
    expect(() => calculateQueueDurationMinutes(5, 2, 0, 8)).toThrow(RangeError);
  });
});
