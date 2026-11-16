import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../models/watch_spot.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class LocationController extends GetxController {
  LocationController(this._service);

  static const proximityRadiusMeters = 150;

  final LocationService _service;
  final position = Rxn<Position>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final proximityMessage = ''.obs;
  String? _lastNotifiedSpotName;

  Future<void> loadCurrentLocation() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final currentPosition = await _service.getCurrentPosition();
      position.value = currentPosition;
      await _notifyIfNearby(currentPosition);
    } on Exception catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String nearestSpot(Position currentPosition) {
    final nearest = _nearestSpot(currentPosition);
    final distanceText = nearest.distanceMeters < 1000
        ? '${nearest.distanceMeters.round()} m'
        : '${(nearest.distanceMeters / 1000).toStringAsFixed(1)} km';
    return '${nearest.spot.name} · $distanceText';
  }

  Future<void> _notifyIfNearby(Position currentPosition) async {
    final nearest = _nearestSpot(currentPosition);
    if (nearest.distanceMeters > proximityRadiusMeters) {
      _lastNotifiedSpotName = null;
      proximityMessage.value = '';
      return;
    }

    if (!NotificationService.isSupported ||
        _lastNotifiedSpotName == nearest.spot.name) {
      return;
    }
    _lastNotifiedSpotName = nearest.spot.name;

    try {
      final sent = await NotificationService().showInstantNotification(
        title: 'Kamu dekat ${nearest.spot.name}',
        body: 'Jarakmu sekitar ${nearest.distanceMeters.round()} meter.',
      );
      proximityMessage.value = sent
          ? 'Notifikasi kedekatan dikirim (${nearest.distanceMeters.round()} m).'
          : 'Izin notifikasi diperlukan untuk memberi tahu saat kamu dekat.';
    } on Exception catch (error) {
      proximityMessage.value = 'Notifikasi lokasi gagal: $error';
    }
  }

  ({WatchSpot spot, double distanceMeters}) _nearestSpot(
    Position currentPosition,
  ) {
    var nearestSpot = watchSpots.first;
    var nearestDistance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      nearestSpot.latitude,
      nearestSpot.longitude,
    );

    for (final spot in watchSpots.skip(1)) {
      final distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        spot.latitude,
        spot.longitude,
      );
      if (distance < nearestDistance) {
        nearestSpot = spot;
        nearestDistance = distance;
      }
    }

    return (spot: nearestSpot, distanceMeters: nearestDistance);
  }
}
