// ignore_for_file: non_constant_identifier_names
import 'dart:async';
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/data/models/user_location.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:lm_teams_app/presentation/dialogs/interaction_dialog.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../data/models/db_operation_object.dart';

enum PinType { owner, member, item }

enum BGEventType {
  initial,
  location,
  motionchange,
  activitychange,
  providerchange,
  connectivitychange,
  http,
  heartbeat,
  schedule,
  powersavechange,
  enabledchange,
  notificationaction,
  authorization
}

class BGStreamData {
  BGStreamData({
    required this.eventType,
    required this.data,
  });
  final BGEventType eventType;
  final dynamic data;

  Map<String, dynamic> toJson() => {'eventType': eventType.name, 'data': data};
  BGStreamData.fromJson(Map<String, dynamic> json)
      : eventType = stringToEnum<BGEventType>(BGEventType.values, json['eventType']),
        data = json['data'];
}

class GetUserLocationFilterData extends Equatable {
  const GetUserLocationFilterData({
    this.teamID,
    this.eventID,
  });

  final String? teamID;
  final String? eventID;

  Map<String, dynamic> toJson() => {
        if (teamID != null && teamID != '-') 'teamId': teamID,
        if (eventID != null && eventID != '-') 'eventId': eventID,
      };

  @override
  List<Object?> get props => [teamID, eventID];

  @override
  toString() =>
      'GetUserlocationFilterData(${teamID != null ? 'teamId: $teamID, ' : ''}${eventID != null ? 'eventId: $eventID' : ''})';
}

class GeolocationService {
  static final GeolocationService _geolocationService = GeolocationService._internal();
  factory GeolocationService() {
    return _geolocationService;
  }
  GeolocationService._internal();
  final UtilsService _utils = UtilsService();
  final _socket = WebSocketService();
  final StreamController<BGStreamData> _BGStreamController = StreamController<BGStreamData>();

  Stream<BGStreamData> get backgroundGeolocationStream {
    return _BGStreamController.stream;
  }

  void init() async {
    if (_utils.isMobile()) {
      var state = await bg.BackgroundGeolocation.ready(bg.Config(
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
          distanceFilter: 1.0,
          stopOnTerminate: false,
          startOnBoot: true,
          debug: true,
          logLevel: bg.Config.LOG_LEVEL_VERBOSE,
          backgroundPermissionRationale: bg.PermissionRationale(
              title: "Allow LE Teams to access to this device's location in the background?",
              message:
                  "In order to use background location while canvassing, please select '{backgroundPermissionOptionLabel}'.",
              positiveAction: "Change to {backgroundPermissionOptionLabel}",
              negativeAction: "Cancel"),
          reset: true));

      _BGStreamController.add(BGStreamData(eventType: BGEventType.initial, data: state.enabled));

      //listeners
      bg.BackgroundGeolocation.onLocation((location) =>
          _BGStreamController.add(BGStreamData(eventType: BGEventType.location, data: location)));

      bg.BackgroundGeolocation.onMotionChange((location) => _BGStreamController.add(
          BGStreamData(eventType: BGEventType.motionchange, data: location)));

      bg.BackgroundGeolocation.onActivityChange((activityChangeEvent) =>
          BGStreamData(eventType: BGEventType.activitychange, data: activityChangeEvent));

      bg.BackgroundGeolocation.onProviderChange((providerChangeEvent) => _BGStreamController.add(
          BGStreamData(eventType: BGEventType.providerchange, data: providerChangeEvent)));

      bg.BackgroundGeolocation.onConnectivityChange((connectivityChangeEvent) =>
          _BGStreamController.add(BGStreamData(
              eventType: BGEventType.connectivitychange, data: connectivityChangeEvent)));

      bg.BackgroundGeolocation.onHttp((httpEvent) =>
          _BGStreamController.add(BGStreamData(eventType: BGEventType.http, data: httpEvent)));

      bg.BackgroundGeolocation.onHeartbeat((heartbeatEvent) => _BGStreamController.add(
          BGStreamData(eventType: BGEventType.heartbeat, data: heartbeatEvent)));

      bg.BackgroundGeolocation.onSchedule((state) =>
          _BGStreamController.add(BGStreamData(eventType: BGEventType.schedule, data: state)));

      bg.BackgroundGeolocation.onPowerSaveChange((isPowerSavingEnabled) => _BGStreamController.add(
          BGStreamData(eventType: BGEventType.powersavechange, data: isPowerSavingEnabled)));

      bg.BackgroundGeolocation.onEnabledChange((isPluginEnabled) => _BGStreamController.add(
          BGStreamData(eventType: BGEventType.enabledchange, data: isPluginEnabled)));

      bg.BackgroundGeolocation.onNotificationAction((p0) => _BGStreamController.add(
          BGStreamData(eventType: BGEventType.notificationaction, data: p0)));

      bg.BackgroundGeolocation.onAuthorization((authorizationEvent) => _BGStreamController.add(
          BGStreamData(eventType: BGEventType.authorization, data: authorizationEvent)));
    }
  }

  Future<LocationEvent?> getCurrentLocation(
    BuildContext context,
  ) async {
    try {
      var geoState = context.read<GeolocationBloc>().state;
      if (geoState.isEnabled) {
        final rawLocation = await bg.BackgroundGeolocation.getCurrentPosition();

        return LocationEvent(
            id: rawLocation.uuid,
            odometer: rawLocation.odometer,
            activityConfidence: rawLocation.activity.confidence,
            activityType: rawLocation.activity.type,
            batteryLevel: rawLocation.battery.level,
            isCharging: rawLocation.battery.isCharging,
            altitude: rawLocation.coords.altitude,
            heading: rawLocation.coords.heading,
            latitude: rawLocation.coords.latitude,
            longitude: rawLocation.coords.longitude,
            speed: rawLocation.coords.speed,
            accuracy: rawLocation.coords.accuracy,
            isMoving: rawLocation.isMoving,
            timeStamp: DateTime.parse(rawLocation.timestamp).toLocal());
      } else {
        print('not enable');
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  LocationEvent simplifiedLocation(bg.Location rawLocation) {
    return LocationEvent(
      id: rawLocation.uuid,
      odometer: rawLocation.odometer,
      activityConfidence: rawLocation.activity.confidence,
      activityType: rawLocation.activity.type,
      batteryLevel: rawLocation.battery.level,
      isCharging: rawLocation.battery.isCharging,
      altitude: rawLocation.coords.altitude,
      heading: rawLocation.coords.heading,
      latitude: rawLocation.coords.latitude,
      longitude: rawLocation.coords.longitude,
      speed: rawLocation.coords.speed,
      accuracy: rawLocation.coords.accuracy,
      isMoving: rawLocation.isMoving,
      timeStamp: DateTime.parse(rawLocation.timestamp),
    );
  }

//updates userlocation object in db
  updateUserLocation(UserLocationUpdate userLocationUpdate) {
    if (userLocationUpdate.id != '-') {
      _socket.send(Message('Write',
          data:
              IDBOperationObject(table: DBTableType.userLocation.name, data: userLocationUpdate)));
    }
  }

  String getUserPinUrl(String? imageUrl, String? userInitials, PinType type,
      {bool isActive = true}) {
    final initials = '&txt=${userInitials ?? 'UN'}&txt-size=60&txt-align=center,middle';

    final blend = isActive ? kColoredBlend : kNotColoredBlend;
    final frame = isActive ? kActiveMemberPinFrameUrl : kInactiveMemberPinFrameUrl;
    final imageUrlWBlend =
        imageUrl != null ? imageUrl + blend : kGreyBackgroundImg + blend + initials;

    final encoded = _imageUrlToBase64(imageUrlWBlend);

    if (type == PinType.owner) {
      final imageUrlWBlendOwner = imageUrl != null
          ? imageUrl + kColoredBlend
          : kGreyBackgroundImg + kColoredBlend + initials;
      final encodedOwner = _imageUrlToBase64(imageUrlWBlendOwner);
      return kUserPinFrameUrl + encodedOwner;
    } else if (type == PinType.member) {
      return frame + encoded;
    } else {
      return '';
    }
  }

  String getItemPinUrl(String? imageUrl, String? code) {
    var _code = '&txt=${code ?? 'UN'}&txt-size=60&txt-align=center,middle';

    //add the blend to image
    var imageUrlWBlend = imageUrl != null
        ? imageUrl + kItemImageBlend
        : kGreyBackgroundImg + kItemImageBlend + _code;

    //convert image url to base64
    var encoded = _imageUrlToBase64(imageUrlWBlend);
    return kItemPinFrameUrl + encoded;
  }

  String _imageUrlToBase64(String imageUrl) {
    return base64.encode(utf8.encode(imageUrl)).replaceAll('=', '').replaceAll('/', '_');
  }

  Future<Stream<Message<dynamic>>?> userLocationStream() async {
    if (!_socket.isConnected) return null;
    var observer = _socket.sendAndListen(Message('OnChanges', data: DBTableType.userLocation.name),
        customFingerPrint: 'userLocationChanges');
    return observer.observable.stream;
  }
}
