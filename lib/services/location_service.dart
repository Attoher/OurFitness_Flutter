import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  final List<Position> _routePositions = [];
  StreamSubscription<Position>? _positionSubscription;
  bool _isTracking = false;
  double _totalDistanceMeters = 0.0;
  bool _permissionGranted = false;
  bool _isLoading = false;

  Position? get currentPosition => _currentPosition;
  List<Position> get routePositions => List.unmodifiable(_routePositions);
  double get totalDistanceKm => _totalDistanceMeters / 1000;
  bool get isTracking => _isTracking;
  bool get permissionGranted => _permissionGranted;
  bool get isLoading => _isLoading;

  Future<bool> requestPermission() async {
    _isLoading = true;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _permissionGranted = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _permissionGranted = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Position?> fetchCurrentPosition() async {
    if (!_permissionGranted) {
      final granted = await requestPermission();
      if (!granted) return null;
    }
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
      return _currentPosition;
    } catch (_) {
      return null;
    }
  }

  void startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    _routePositions.clear();
    _totalDistanceMeters = 0.0;
    notifyListeners();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((position) {
      if (_routePositions.isNotEmpty) {
        final last = _routePositions.last;
        _totalDistanceMeters += Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          position.latitude,
          position.longitude,
        );
      }
      _routePositions.add(position);
      _currentPosition = position;
      notifyListeners();
    });
  }

  void pauseTracking() {
    _positionSubscription?.pause();
  }

  void resumeTracking() {
    if (_positionSubscription?.isPaused ?? false) {
      _positionSubscription?.resume();
    }
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    notifyListeners();
  }

  List<Map<String, double>> getRouteForSave() {
    return _routePositions
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
