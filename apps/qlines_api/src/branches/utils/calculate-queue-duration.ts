export function calculateQueueDurationMinutes(
  peopleWaiting: number,
  bookingsAhead: number,
  activeServiceCounters: number,
  averageServiceDurationMinutes: number,
): number {
  if (activeServiceCounters <= 0) {
    throw new RangeError('Active service counters must be greater than zero');
  }

  const totalPeopleAhead = peopleWaiting + bookingsAhead;

  if (totalPeopleAhead <= 0) {
    return 0;
  }

  const serviceRounds = Math.ceil(totalPeopleAhead / activeServiceCounters);

  return serviceRounds * averageServiceDurationMinutes;
}
