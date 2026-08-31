const earthRadiusKm = 6371;

function degreesToRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}

export function calculateDistanceKm(
  startLatitude: number,
  startLongitude: number,
  endLatitude: number,
  endLongitude: number,
): number {
  const latitudeDifference = degreesToRadians(endLatitude - startLatitude);

  const longitudeDifference = degreesToRadians(endLongitude - startLongitude);

  const startLatitudeRadians = degreesToRadians(startLatitude);
  const endLatitudeRadians = degreesToRadians(endLatitude);

  const haversine =
    Math.sin(latitudeDifference / 2) ** 2 +
    Math.cos(startLatitudeRadians) *
      Math.cos(endLatitudeRadians) *
      Math.sin(longitudeDifference / 2) ** 2;

  const angularDistance =
    2 * Math.atan2(Math.sqrt(haversine), Math.sqrt(1 - haversine));

  return earthRadiusKm * angularDistance;
}
