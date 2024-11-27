import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class LocationEvent extends Equatable {
  const LocationEvent({
    required this.id,
    required this.odometer,
    required this.activityConfidence,
    required this.activityType,
    required this.batteryLevel,
    required this.isCharging,
    required this.altitude,
    required this.heading,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
    required this.isMoving,
    required this.timeStamp,
  });

  final String id;
  final double odometer;
  final int activityConfidence;
  final String activityType;
  final double batteryLevel;
  final bool isCharging;
  final double altitude;
  final double heading;
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;
  final bool isMoving;
  final DateTime timeStamp;

  factory LocationEvent.fromJson(Map<String, dynamic> json) {
    return LocationEvent(
        id: json['id'],
        odometer: double.parse(json['odometer'].toString()),
        activityConfidence: json['activityConfidence'],
        activityType: json['activityType'],
        batteryLevel: double.parse(json['batteryLevel'].toString()),
        isCharging: json['isCharging'],
        altitude: double.parse(json['altitude'].toString()),
        heading: double.parse(json['heading'].toString()),
        latitude: double.parse(json['latitude'].toString()),
        longitude: double.parse(json['longitude'].toString()),
        speed: double.parse(json['speed'].toString()),
        accuracy: double.parse(json['accuracy'].toString()),
        isMoving: json['isMoving'],
        timeStamp: DateTime.parse(json['timeStamp']));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'odometer': odometer,
        'activityConfidence': activityConfidence,
        'activityType': activityType,
        'batteryLevel': batteryLevel,
        'isCharging': isCharging,
        'altitude': altitude,
        'heading': heading,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'accuracy': accuracy,
        'isMoving': isMoving,
        'timeStamp': timeStamp.toIso8601String()
      };

  @override
  List<Object?> get props => [
        id,
        odometer,
        activityConfidence,
        activityType,
        batteryLevel,
        isCharging,
        altitude,
        heading,
        latitude,
        longitude,
        speed,
        accuracy,
        isMoving,
        timeStamp
      ];

  static final placeHolder = LocationEvent(
      id: '1234567890',
      odometer: 0,
      activityConfidence: 100,
      activityType: 'still',
      batteryLevel: 0.50,
      isCharging: false,
      altitude: 50.0,
      heading: -1,
      latitude: 33.872498363366745,
      longitude: 151.2074850127101,
      speed: 0.0,
      accuracy: 20.0,
      isMoving: false,
      timeStamp: DateTime.now());

  @override
  String toString() =>
      "Location Event: id: $id, odometer: $odometer, activityConfidence: $activityConfidence, activityType: $activityType, batteryLevel: $batteryLevel,isCharging: $isCharging,altitude: $altitude,heading: $heading,latitude: $latitude, longitude: $longitude, speed: $speed, accuracy: $accuracy, isMoving: $isMoving, timeStamp: $timeStamp ";

  LatLng get latLng => LatLng(latitude, longitude);

  int distanceInMetersTo(LocationEvent other) {
    const double earthRadius = 6371000.0;

    double lat1 = latitude * pi / 180;
    double lon1 = longitude * pi / 180;
    double lat2 = other.latitude * pi / 180;
    double lon2 = other.longitude * pi / 180;

    // Calculate the differences between coordinates
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    // Haversine formula
    final a = pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    final distance = earthRadius * c;
    return distance.round();
  }
}

// Serialize LatLngBounds to a Map
Map<String, dynamic> latLngBoundsToJson(LatLngBounds bounds) {
  return {
    'southwest': {
      'latitude': bounds.southwest.latitude,
      'longitude': bounds.southwest.longitude,
    },
    'northeast': {
      'latitude': bounds.northeast.latitude,
      'longitude': bounds.northeast.longitude,
    },
  };
}

// Deserialize Map to LatLngBounds
LatLngBounds latLngBoundsFromJson(Map<String, dynamic> json) {
  final southwest = LatLng(
    json['southwest']['latitude'],
    json['southwest']['longitude'],
  );
  final northeast = LatLng(
    json['northeast']['latitude'],
    json['northeast']['longitude'],
  );
  return LatLngBounds(southwest: southwest, northeast: northeast);
}
