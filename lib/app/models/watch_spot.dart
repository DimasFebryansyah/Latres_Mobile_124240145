class WatchSpot {
  const WatchSpot({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final double latitude;
  final double longitude;
}

const watchSpots = [
  WatchSpot(
    name: 'Kampus UPN Veteran Yogyakarta',
    latitude: -7.7823837,
    longitude: 110.4158661,
  ),
  WatchSpot(name: 'Tugu Yogyakarta', latitude: -7.7829, longitude: 110.3671),
  WatchSpot(name: 'Malioboro', latitude: -7.7936, longitude: 110.3658),
];
