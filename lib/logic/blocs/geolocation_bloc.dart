// ignore_for_file: must_be_immutable, unused_local_variable
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_settings/app_settings.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/presentation/dialogs/permission_needed_dialog.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:lm_teams_app/services/time_helpers.dart';
import '../../data/models/user_location.dart';
import '../../presentation/dialogs/prominent_disclosure_dialog.dart';

class GeolocationState extends Equatable {
  GeolocationState({
    required this.latestLocation,
    required this.locations,
    required this.isEnabled,
    required this.isProminentDisclosureAccepted,
    required this.activity,
    this.logs,
  });

  LocationEvent? latestLocation;
  List<LocationEvent> locations;
  bool isEnabled;
  bool isProminentDisclosureAccepted;
  String activity;
  List<BGStreamData>? logs;

  GeolocationState copyWith({
    LocationEvent? latestLocation,
    List<LocationEvent>? locations,
    bool? isEnabled,
    bool? isProminentDisclosureAccepted,
    String? activity,
    MapType? mapType,
    List<BGStreamData>? logs,
  }) {
    return GeolocationState(
      latestLocation: latestLocation ?? this.latestLocation,
      locations: locations ?? this.locations,
      isEnabled: isEnabled ?? this.isEnabled,
      isProminentDisclosureAccepted:
          isProminentDisclosureAccepted ?? this.isProminentDisclosureAccepted,
      activity: activity ?? this.activity,
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object?> get props =>
      [latestLocation, locations, isEnabled, activity, logs, isProminentDisclosureAccepted];

  Map<String, dynamic> toJson() => {
        'latestLocation': latestLocation,
        'locations': locations,
        'isEnabled': isEnabled,
        'isProminentDisclosureAccepted': isProminentDisclosureAccepted,
        'activity': activity,
      };

  GeolocationState.fromJson(Map<String, dynamic> json)
      : latestLocation = decodeLocationEvent(json['latestLocation']),
        locations = decodeLocationEvents(json['locations']),
        isEnabled = json['isEnabled'],
        isProminentDisclosureAccepted = json['isProminentDisclosureAccepted'],
        activity = json['activity'];
}

abstract class GeolocationEvent extends Equatable {
  const GeolocationEvent();

  @override
  List<Object?> get props => [];
}

class InitialPluginState extends GeolocationEvent {
  const InitialPluginState({required this.isEnabled});
  final bool isEnabled;

  @override
  List<Object?> get props => [isEnabled];
}

class EnableGeolocation extends GeolocationEvent {
  const EnableGeolocation({required this.isEnabled, required this.context});

  final bool isEnabled;
  final BuildContext context;
  @override
  List<Object?> get props => [isEnabled, context];
}

class LogIncoming extends GeolocationEvent {
  LogIncoming({required this.incomingData});
  BGStreamData incomingData;

  @override
  List<Object?> get props => [incomingData];
}

class LocationUpdate extends GeolocationEvent {
  LocationUpdate({required this.locationEvent, required this.user});
  LocationEvent locationEvent;
  final User user;

  @override
  List<Object?> get props => [locationEvent, user];
}

class ClearState extends GeolocationEvent {
  const ClearState();
}

class ActivityUpdate extends GeolocationEvent {
  ActivityUpdate({required this.activity});
  String activity;

  @override
  List<Object?> get props => [activity];
}

class GeolocationBloc extends HydratedBloc<GeolocationEvent, GeolocationState> {
  StreamSubscription? backgroundGeoSubscription;
  StreamSubscription? userLocationStreamSubscription;
  final User user;

  final _geoService = GeolocationService();
  GeolocationBloc({required this.user})
      : super(GeolocationState(
          latestLocation: LocationEvent.placeHolder,
          locations: const [],
          isEnabled: false,
          isProminentDisclosureAccepted: false,
          activity: 'UNKNOWN',
          logs: const [],
        )) {
    on<GeolocationEvent>(_onEvent);

    backgroundGeoSubscription = GeolocationService().backgroundGeolocationStream.listen((incoming) {
      add(LogIncoming(incomingData: incoming));

      switch (incoming.eventType) {
        case BGEventType.initial:
          final _isPlugginEnabled = incoming.data as bool;
          add(InitialPluginState(isEnabled: _isPlugginEnabled));
          break;
        case BGEventType.location:
          final _rawLocation = incoming.data as bg.Location;
          add(LocationUpdate(
              locationEvent: _geoService.simplifiedLocation(_rawLocation), user: user));
          break;
        case BGEventType.motionchange:
          final _rawLocation = incoming.data as bg.Location;
          add(LocationUpdate(
              locationEvent: _geoService.simplifiedLocation(_rawLocation), user: user));
          break;
        case BGEventType.activitychange:
          final _changeEvent = incoming.data as bg.ActivityChangeEvent;
          add(ActivityUpdate(activity: _changeEvent.activity));
          break;
        case BGEventType.providerchange:
          final _changeEvent = incoming.data as bg.ProviderChangeEvent;
          break;
        case BGEventType.connectivitychange:
          final _changeEvent = incoming.data as bg.ConnectivityChangeEvent;
          break;
        case BGEventType.http:
          final _event = incoming.data as bg.HttpEvent;
          break;
        case BGEventType.heartbeat:
          final _heartbeat = incoming.data as bg.HeartbeatEvent;
          break;
        case BGEventType.schedule:
          final _state = incoming.data as bg.State;
          break;
        case BGEventType.powersavechange:
          final _isPowerSavingEnabled = incoming.data as bool;
          break;
        case BGEventType.enabledchange:
          final _isPluginEnabled = incoming.data as bool;
          break;
        case BGEventType.notificationaction:
          final _action = incoming.data as String;
          break;
        case BGEventType.authorization:
          final _event = incoming.data as bg.Authorization;
          break;
        default:
      }
    });
  }

  Future<void> _onEvent(GeolocationEvent event, Emitter<GeolocationState> emit) async {
    if (event is InitialPluginState) {
      emit(state.copyWith(isEnabled: event.isEnabled));
      //keep only today's locations
      var previousLocations = state.locations;
      if (previousLocations.isNotEmpty) {
        previousLocations =
            previousLocations.where((location) => location.timeStamp.isToday).toList();
        emit(state.copyWith(locations: previousLocations));
      }
    } else if (event is EnableGeolocation) {
      if (event.isEnabled) {
        if (!state.isProminentDisclosureAccepted) {
          var isAccepted = await showProminentDisclosureDialog(event.context);
          if (isAccepted == null || !isAccepted) {
            return;
          } else {
            emit(state.copyWith(isProminentDisclosureAccepted: true));
          }
        }
        var isGranted = await isLocationPermissionGranted;
        if (isGranted) {
          var _geoState = await bg.BackgroundGeolocation.start();
          emit(state.copyWith(isEnabled: _geoState.enabled));
        } else {
          var proceed = await showPermissionNeededDialog(
              context: event.context,
              title: 'Location Permission Denied',
              message: 'You need to manually grant location service permissions in settings');
          if (proceed) {
            await AppSettings.openAppSettings();
          }
          emit(state.copyWith(isEnabled: isGranted));
        }
      } else {
        var _geoState = await bg.BackgroundGeolocation.stop();
        emit(state.copyWith(isEnabled: false));
      }
    } else if (event is LogIncoming) {
      emit(state.copyWith(logs: [...state.logs ?? []]..add(event.incomingData)));
    } else if (event is LocationUpdate) {
      LocationEvent? lastLocation = state.latestLocation;
      LocationEvent latestLocation = event.locationEvent;
      List<LocationEvent> previousLocations = List.from(state.locations);

      //update saved stop locations
      // if (lastLocation != null &&
      //     lastLocation != LocationEvent.placeHolder &&
      //     !lastLocation.isMoving &&
      //     lastLocation.activityType == 'still') {
      //   if (previousLocations.isNotEmpty) {
      //     var distance = lastLocation.distanceInMetersTo(previousLocations.last);

      //     if (distance > 50) {
      //       previousLocations.add(lastLocation);
      //     }
      //   } else {
      //     previousLocations.add(lastLocation);
      //   }
      // }

      //will save location every 10 meters
      // if (lastLocation != null && lastLocation != LocationEvent.placeHolder) {
      //   if (previousLocations.isNotEmpty) {
      //     var distance = lastLocation.distanceInMetersTo(previousLocations.last);
      //     if (distance > 20) {
      //       previousLocations.add(lastLocation);
      //     }
      //   } else {
      //     previousLocations.add(lastLocation);
      //   }
      // }

      //record all previous locations
      if (lastLocation != null && lastLocation != LocationEvent.placeHolder) {
        previousLocations.add(lastLocation);
      }

      emit(state.copyWith(latestLocation: latestLocation, locations: previousLocations));

      //update userlocation latest location in db
      _geoService.updateUserLocation(UserLocationUpdate(
          id: event.user.id,
          latestLocation: state.latestLocation,
          locations: state.locations,
          user: user));
    } else if (event is ClearState) {
      emit(state.copyWith(
          locations: [],
          latestLocation: LocationEvent.placeHolder,
          logs: [],
          isEnabled: false,
          isProminentDisclosureAccepted: false));
    }
  }

  @override
  Map<String, dynamic> toJson(GeolocationState state) {
    return state.toJson();
  }

  @override
  GeolocationState fromJson(Map<String, dynamic> json) {
    return GeolocationState.fromJson(json);
  }
}

Future<bool> get isLocationPermissionGranted async {
  try {
    int status = await bg.BackgroundGeolocation.requestPermission();

    switch (status) {
      case bg.ProviderChangeEvent.AUTHORIZATION_STATUS_ALWAYS:
        return true;
      case bg.ProviderChangeEvent.AUTHORIZATION_STATUS_WHEN_IN_USE:
        return true;
      case bg.ProviderChangeEvent.AUTHORIZATION_STATUS_DENIED:
        return false;
      case bg.ProviderChangeEvent.AUTHORIZATION_STATUS_NOT_DETERMINED:
        return false;
      case bg.ProviderChangeEvent.AUTHORIZATION_STATUS_RESTRICTED:
        return false;
      default:
        return false;
    }
  } catch (e) {
    return false;
  }
}
