import 'dart:convert';
import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';
import 'package:lm_teams_app/services/preference_utils.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import '../../presentation/widgets/markers.dart';
import '../../services/utils_service.dart';
import 'image models/image_object.dart';

enum ETableChangeType { Inserted, Deleted, Updated }

// ignore: must_be_immutable
class UserLocation extends Equatable {
  UserLocation({
    required this.id,
    this.user,
    this.teamId,
    this.eventId,
    this.latestLocation,
    this.locations,
    this.shareWithLeader,
    this.shareWithMembers,
  });

  final String id;
  String? teamId;
  String? eventId;
  LocationEvent? latestLocation;
  List<LocationEvent>? locations;
  bool? shareWithLeader;
  bool? shareWithMembers;
  User? user;

  final _utils = UtilsService();
  final _geolocationService = GeolocationService();

  Future<MemberMarker?> toMemberMarker(PinType pinType) async {
    if (latestLocation == null) return null;

    BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
    ImageObject? _image = user?.image;

    bool hasInternet = await _utils.hasInternet;
    int now = DateTime.now().millisecondsSinceEpoch;
    int anHourInMs = 1000 * 60 * 60;
    var isActive = now - latestLocation!.timeStamp.millisecondsSinceEpoch < anHourInMs;

    try {
      String prefKey = 'memberMarker' + id;

      if (hasInternet) {
        var pinUrl = _geolocationService.getUserPinUrl(_image?.url, user?.initials, pinType,
            isActive: isActive);
        var imageAsBytes = await _utils.urlToBytes(pinUrl);

        // Save image as bytes to preference
        String encoded = base64Encode(imageAsBytes);
        PreferenceUtils().saveData(prefKey, encoded);

        icon = BitmapDescriptor.fromBytes(imageAsBytes);
      } else {
        // Read image as bytes from preference
        String? encoded = await PreferenceUtils().getString(prefKey);
        if (encoded != null && encoded.isNotEmpty) {
          List<int> intList = base64Decode(encoded);
          icon = BitmapDescriptor.fromBytes(Uint8List.fromList(intList));
        }
      }
    } catch (e) {
      print(e);
    }

    return MemberMarker(
      markerId: MarkerId(user?.id ?? 'markerID'),
      icon: icon,
      position: LatLng(latestLocation!.latitude, latestLocation!.longitude),
      infoWindow:
          InfoWindow(title: user?.name ?? 'Anonymous', snippet: latestLocation!.timeStamp.timeAgo),
      user: user ?? User.empty,
      userLocation: this,
      // onTap: () => context.read<MapBloc>().add(ShowUsersPreviousLocation(userlocation: this))
    );
  }

  @override
  List<Object?> get props =>
      [id, teamId, eventId, latestLocation, locations, shareWithLeader, shareWithMembers, user];

  UserLocation.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        teamId = json['teamId'],
        eventId = json['eventId'],
        latestLocation = decodeLocationEvent(json['latestLocation']),
        locations = decodeLocationEvents(json['locations']),
        shareWithLeader = json['shareWithLeader'],
        shareWithMembers = json['shareWithMembers'],
        user = _decodeUser(json['user']) ?? User.empty;

  Map<String, dynamic> toJson() => {
        'id': id,
        if (teamId != null && teamId != '-') 'teamId': teamId,
        if (eventId != null && eventId != '-') 'eventId': eventId,
        if (latestLocation != null) 'latestLocation': latestLocation,
        if (locations != null) 'locations': serializeLocations(locations),
        if (shareWithLeader != null) 'shareWithLeader': shareWithLeader,
        if (shareWithMembers != null) 'shareWithMembers': shareWithMembers,
        if (user != null) 'user': user
      };

  static final empty =
      UserLocation(id: '-', teamId: '-', eventId: '-', latestLocation: LocationEvent.placeHolder);

  @override
  String toString() {
    return 'UserLocation(id: $id, teamId: $teamId, eventId: $eventId, latestLocation: $latestLocation, locations: $locations, shareWithLeader: $shareWithLeader, shareWithMembers: $shareWithMembers)';
  }
}

List<Map<String, dynamic>>? serializeLocations(List<LocationEvent>? locations) {
  if (locations == null) return null;
  return locations.map((e) => e.toJson()).toList();
}

LocationEvent? decodeLocationEvent(dynamic object) {
  try {
    if (object == null) return null;
    if (object is LocationEvent) return object;
    if (object is String) return LocationEvent.fromJson(jsonDecode(object));
    return LocationEvent.fromJson(object);
  } catch (e) {
    print('Decode location event error: $e');
    return null;
  }
}

List<LocationEvent> decodeLocationEvents(dynamic object) {
  try {
    List<LocationEvent> locations = [];
    for (var event in object) {
      var location = decodeLocationEvent(event);
      if (location != null) {
        locations.add(location);
      }
    }
    return locations;
  } catch (e) {
    return [];
  }
}

User? _decodeUser(dynamic object) {
  try {
    if (object == null) return null;
    if (object is User) return object;
    if (object is String) {
      return User.fromJson(jsonDecode(object));
    }
    return User.fromJson(object);
  } catch (e) {
    print('Decode user error: $e');
    return null;
  }
}

class UserLocationUpdate {
  UserLocationUpdate(
      {this.id,
      this.teamId,
      this.eventId,
      this.latestLocation,
      this.locations,
      this.shareWithLeader,
      this.shareWithMembers,
      this.user});
  final String? id;
  final String? teamId;
  final String? eventId;
  final LocationEvent? latestLocation;
  final List<LocationEvent>? locations;
  final bool? shareWithLeader;
  final bool? shareWithMembers;
  final User? user;

  UserLocationUpdate.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        teamId = json['teamId'],
        eventId = json['eventId'],
        latestLocation = decodeLocationEvent(json['latestLocation']),
        locations = decodeLocationEvents(json['locations']),
        shareWithLeader = json['shareWithLeader'],
        shareWithMembers = json['shareWithMembers'],
        user = json['user'] != null ? User.fromJson(_decodeIfJson(json['user'])) : null;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (teamId != null) 'teamId': teamId,
        if (eventId != null) 'eventId': eventId,
        if (latestLocation != null) 'latestLocation': latestLocation,
        if (locations != null) 'locations': locations,
        if (shareWithLeader != null) 'shareWithLeader': shareWithLeader,
        if (shareWithMembers != null) 'shareWithMembers': shareWithMembers,
        if (user != null) 'user': user
      };

  static UserLocationUpdate updateFromUserlocation(UserLocation userLocation) {
    return UserLocationUpdate(
        id: userLocation.id,
        user: userLocation.user,
        teamId: userLocation.teamId,
        eventId: userLocation.eventId,
        latestLocation: userLocation.latestLocation,
        locations: userLocation.locations,
        shareWithLeader: userLocation.shareWithLeader,
        shareWithMembers: userLocation.shareWithMembers);
  }

  @override
  String toString() => 'UserlocationUpdate(${id != null ? 'id: $id, ' : ''}'
      '${teamId != null ? 'teamId: $teamId, ' : ''}'
      '${eventId != null ? 'eventId: $eventId, ' : ''}'
      '${latestLocation != null ? 'locationEvent: $latestLocation, ' : ''}'
      '${locations != null ? 'locations: $locations, ' : ''}'
      '${shareWithLeader != null ? 'shareWithLeader: $shareWithLeader, ' : ''}'
      '${shareWithMembers != null ? 'shareWithMembers: $shareWithMembers, ' : ''}'
      '${user != null ? 'user: $user' : ''})';
}

class UserLocationChangeData {
  UserLocationChangeData(this.type, this.data);
  final ETableChangeType type;
  final UserLocationUpdate data;

  UserLocationChangeData.fromJson(Map<String, dynamic> json)
      : type = _getChangeType(json['type']),
        data = UserLocationUpdate.fromJson(_decodeIfJson(json['data']));
  @override
  String toString() => 'UserLocationChangeData(type: $type, data: $data)';
}

_getChangeType(int type) {
  switch (type) {
    case 0:
      return ETableChangeType.Inserted;
    case 1:
      return ETableChangeType.Deleted;
    case 2:
      return ETableChangeType.Updated;
  }
}

dynamic _decodeIfJson(dynamic object) {
  if (object.runtimeType == String) {
    return jsonDecode(object);
  }
  return object;
}
