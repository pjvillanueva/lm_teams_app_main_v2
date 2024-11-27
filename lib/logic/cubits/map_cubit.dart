import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_model.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/data/models/user_location.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/cubits/users_cubit.dart';
import 'package:lm_teams_app/presentation/screens/map%20screen%202/app_map_functions.dart';
import 'package:lm_teams_app/presentation/widgets/markers.dart';
import 'package:lm_teams_app/services/entry_service.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';
import 'package:lm_teams_app/services/helpers/map_cubit_helpers.dart';
import 'package:lm_teams_app/services/map_service.dart';
import 'package:lm_teams_app/services/team_service.dart';

enum ShowMarkerToggle { showItems, showContacts, showMembers }

// ignore: must_be_immutable
class MapCubitState extends Equatable {
  MapCubitState(
      {required this.userMarker,
      required this.mapType,
      required this.mapZoom,
      required this.mapBounds,
      required this.showItemMarkers,
      required this.showContactMarkers,
      required this.showMemberMarkers,
      required this.shareWithLeader,
      required this.shareWithMembers,
      required this.userLocations,
      required this.memberMarkers,
      required this.contactMarkers,
      required this.itemMarkers,
      required this.entryIds,
      required this.focusMarker,
      this.isDragging});

  MemberMarker? userMarker;
  MapType mapType;
  double mapZoom;
  LatLngBounds mapBounds;
  bool showItemMarkers;
  bool showContactMarkers;
  bool showMemberMarkers;
  bool shareWithLeader;
  bool shareWithMembers;
  List<UserLocation> userLocations;
  List<MemberMarker>? memberMarkers;
  List<ContactMarker>? contactMarkers;
  List<ItemMarker>? itemMarkers;
  List<String>? entryIds;
  String? focusMarker;
  bool? isDragging = false;

  @override
  List<Object?> get props => [
        userMarker,
        mapType,
        mapZoom,
        mapBounds,
        showItemMarkers,
        showContactMarkers,
        showMemberMarkers,
        shareWithLeader,
        shareWithMembers,
        userLocations,
        memberMarkers,
        contactMarkers,
        itemMarkers,
        entryIds,
        focusMarker,
        isDragging
      ];

  MapCubitState copyWith(
      {MemberMarker? userMarker,
      MapType? mapType,
      double? mapZoom,
      LatLngBounds? mapBounds,
      bool? showItemMarkers,
      bool? showContactMarkers,
      bool? showMemberMarkers,
      bool? shareWithLeader,
      bool? shareWithMembers,
      List<UserLocation>? userLocations,
      List<MemberMarker>? memberMarkers,
      List<ContactMarker>? contactMarkers,
      List<ItemMarker>? itemMarkers,
      List<String>? entryIds,
      String? focusMarker,
      bool? isDragging}) {
    return MapCubitState(
        userMarker: userMarker ?? this.userMarker,
        mapType: mapType ?? this.mapType,
        mapZoom: mapZoom ?? this.mapZoom,
        mapBounds: mapBounds ?? this.mapBounds,
        showItemMarkers: showItemMarkers ?? this.showItemMarkers,
        showContactMarkers: showContactMarkers ?? this.showContactMarkers,
        showMemberMarkers: showMemberMarkers ?? this.showMemberMarkers,
        shareWithLeader: shareWithLeader ?? this.shareWithLeader,
        shareWithMembers: shareWithMembers ?? this.shareWithMembers,
        userLocations: userLocations ?? this.userLocations,
        memberMarkers: memberMarkers ?? this.memberMarkers,
        contactMarkers: contactMarkers ?? this.contactMarkers,
        itemMarkers: itemMarkers ?? this.itemMarkers,
        entryIds: entryIds ?? this.entryIds,
        focusMarker: focusMarker ?? this.focusMarker,
        isDragging: isDragging ?? this.isDragging);
  }

  Set<Marker> get allMarkers {
    Set<Marker> markers = {};
    if (userMarker != null) markers.add(userMarker!);
    if (memberMarkers != null && memberMarkers!.isNotEmpty) markers.addAll(memberMarkers!);
    if (contactMarkers != null && contactMarkers!.isNotEmpty && showContactMarkers) {
      markers.addAll(contactMarkers!);
    }
    if (itemMarkers != null && itemMarkers!.isNotEmpty && showItemMarkers) {
      markers.addAll(itemMarkers!);
    }

    if (focusMarker != null) {
      try {
        var _markers = List<Marker>.from(markers);
        var marker = _markers.firstWhere((marker) => marker.markerId.value == focusMarker);
        //remove marker from the list
        _markers.removeWhere((marker) => marker.markerId.value == focusMarker);

        if (marker is MemberMarker) {
          marker = marker.newZindex;
        } else if (marker is ContactMarker) {
          marker = marker.newZindex;
        } else if (marker is ItemMarker) {
          marker = marker.newZindex;
        }
        _markers.add(marker);
        return _markers.toSet();
      } catch (e) {
        return markers;
      }
    }
    return markers;
  }

  int get allMarkersLength {
    return allMarkers.length - 1;
  }

  List<String> get itemIds {
    if (itemMarkers == null) return [];
    return itemMarkers!.map((e) => e.data.itemID).toList();
  }

  List<bool> get sharingSettings {
    if (shareWithLeader && shareWithMembers) {
      return [false, false, true];
    } else if (shareWithLeader != shareWithMembers) {
      return [false, true, false];
    } else {
      return [true, false, false];
    }
  }

  Map<String, dynamic> toJson() => {
        'mapType': mapType.name,
        'mapZoom': mapZoom,
        'mapBounds': latLngBoundsToJson(mapBounds),
        'showItemMarkers': showItemMarkers,
        'showContactMarkers': showContactMarkers,
        'showMemberMarkers': showMemberMarkers,
        'shareWithLeader': shareWithLeader,
        'shareWithMembers': shareWithMembers,
        'userLocations': userLocations
      };

  MapCubitState.fromJson(Map<String, dynamic> json)
      : mapType = stringToEnum<MapType>(MapType.values, json['mapType']),
        mapZoom = double.parse(json['mapZoom'].toString()),
        mapBounds = latLngBoundsFromJson(json['mapBounds']),
        showItemMarkers = json['showItemMarkers'],
        showMemberMarkers = json['showMemberMarkers'],
        showContactMarkers = json['showContactMarkers'],
        shareWithLeader = json['shareWithLeader'],
        shareWithMembers = json['shareWithMembers'],
        userLocations =
            List.from(json['userLocations']).map((e) => UserLocation.fromJson(e)).toList();
}

class MapCubit extends HydratedCubit<MapCubitState> {
  MapCubit({required this.userId, required this.context})
      : super(MapCubitState(
            userMarker: null,
            mapType: MapType.normal,
            mapZoom: 18.0,
            mapBounds: LatLngBounds(southwest: const LatLng(0, 0), northeast: const LatLng(0, 0)),
            showItemMarkers: false,
            showContactMarkers: false,
            showMemberMarkers: false,
            shareWithLeader: false,
            shareWithMembers: false,
            userLocations: const [],
            memberMarkers: const [],
            contactMarkers: const [],
            itemMarkers: const [],
            entryIds: const [],
            focusMarker: null)) {
    _listenToUserLocationChangeStreamEvents(context, _userLocationStreamSubscription, userId);
  }

  final String userId;
  final BuildContext context;
  StreamSubscription? _userLocationStreamSubscription;
  final _geolocationService = GeolocationService();
  final _entryService = EntryService();

  //emit if not closed
  _emit(MapCubitState state) {
    if (!isClosed) emit(state);
  }

  //initial event
  initialEvent(BuildContext context) async {
    //set userMarker initial position
    var userLocation = userLocationFromStates(context);
    var userMarker = await userLocation.toMemberMarker(PinType.owner);
    _emit(state.copyWith(userMarker: userMarker));

    //set initial state of user's userlocation in db
    _geolocationService.updateUserLocation(UserLocationUpdate.updateFromUserlocation(userLocation));
  }

//update user marker
  Future<void> updateUserMarkerPosition(BuildContext context,
      Completer<GoogleMapController> completer, double zoom, LatLng? coords) async {
    if (coords != null) {
      final GoogleMapController _controller = await completer.future;

      //move camera if not dragging
      if (state.isDragging == false) {
        _controller
            .moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: coords, zoom: zoom)));
      }

      // update user marker in the map
      UserLocation userLocation = userLocationFromStates(context);
      MemberMarker? _userMarker = await userLocation.toMemberMarker(PinType.owner);
      _emit(state.copyWith(userMarker: _userMarker));
    }
  }

  //update location sharing
  updateLocationSharing(int locationSharingIndex) async {
    switch (locationSharingIndex) {
      case 0:
        _emit(state.copyWith(shareWithLeader: false, shareWithMembers: false));
        break;
      case 1:
        _emit(state.copyWith(shareWithLeader: true, shareWithMembers: false));
        break;
      case 2:
        _emit(state.copyWith(shareWithLeader: true, shareWithMembers: true));
        break;
    }
  }

  //toggle show marker
  toggleShowMarker(ShowMarkerToggle property, bool value, User user, BuildContext context) async {
    switch (property) {
      case ShowMarkerToggle.showItems:
        _emit(state.copyWith(showItemMarkers: value));
        break;
      case ShowMarkerToggle.showContacts:
        _emit(state.copyWith(showContactMarkers: value));
        break;
      case ShowMarkerToggle.showMembers:
        _emit(state.copyWith(showMemberMarkers: value));
        break;
    }

    //refetch markers
    final _homeState = context.read<HomeScreenBloc>().state;
    getMarkers(context, userId, [userId], _homeState.team.id, _homeState.event.id, state.mapBounds,
        state.entryIds ?? [], property);
  }

  //change map type
  changeMapType(String index) {
    _emit(state.copyWith(mapType: getMapType(index)));
  }

  //change map bounds
  changeMapBounds(LatLngBounds bounds) {
    _emit(state.copyWith(mapBounds: bounds));
  }

  changeDraggingState(bool isDragging) {
    _emit(state.copyWith(isDragging: isDragging));
  }

  //on camera move
  onCameraMove(BuildContext context, CameraPosition position,
      Completer<GoogleMapController> completer) async {
    //update zoom level
    if (position.zoom != state.mapZoom) {
      _emit(state.copyWith(mapZoom: position.zoom));
    }

    //check if user is dragging map
    changeDraggingState(state.userMarker != null && state.userMarker!.position != position.target);

    //get visible region and update map bounds
    final _controller = await completer.future;
    final bounds = await _controller.getVisibleRegion();

    if (bounds != state.mapBounds) {
      _emit(state.copyWith(mapBounds: bounds));

      //get markers events
      final _homeState = context.read<HomeScreenBloc>().state;
      getMarkers(context, userId, [userId], _homeState.team.id, _homeState.event.id, bounds,
          state.itemIds);
    }
  }

  //get markers
  getMarkers(BuildContext context, String userId, List<String> userIds, String teamId,
      String eventId, LatLngBounds bounds, List<String> entryIds,
      [ShowMarkerToggle? specificMarker]) async {
    switch (specificMarker) {
      case ShowMarkerToggle.showItems:
        await getEntryMarkers(false, state.showItemMarkers, [userId], teamId, bounds);
        break;
      case ShowMarkerToggle.showContacts:
        await getEntryMarkers(state.showContactMarkers, false, [userId], teamId, bounds);
        break;
      case ShowMarkerToggle.showMembers:
        await getMemberMarkers(state.showMemberMarkers, context, userId, teamId, eventId, bounds);
        break;
      default:
        await getEntryMarkers(
            state.showContactMarkers, state.showItemMarkers, [userId], teamId, bounds);
        await getMemberMarkers(state.showMemberMarkers, context, userId, teamId, eventId, bounds);
    }
  }

  //fetch member markers
  Future<void> getMemberMarkers(bool isVisible, BuildContext context, String userId, String teamId,
      String eventId, LatLngBounds bounds) async {
    if (isVisible) {
      final _mapService = MapService();
      final _teamService = TeamService();

      var _userLocations = await _mapService.getTeamMembersUserlocations(userId: userId);
      _emit(state.copyWith(userLocations: _userLocations));
      var _myTeamRole = await _teamService.getMyTeamRole(userId, teamId);
      var _memberMarkers = await _mapService.convertUserlocationToMarker(
          context, _userLocations, teamId, eventId, _myTeamRole);
      _emit(state.copyWith(memberMarkers: _memberMarkers.toList()));
    }
  }

  //fetch entry markers
  Future<void> getEntryMarkers(bool isContactMarkersVisible, bool isItemMarkersVisible,
      List<String> userIds, String teamId, LatLngBounds bounds) async {
    if (!isContactMarkersVisible || !isItemMarkersVisible) return;

    List<String> types = [];
    List<String> _entryIds = [...state.entryIds ?? []];

    if (isContactMarkersVisible) types.add('contact');
    if (isItemMarkersVisible) types.add('book');

    //remove out of bounds entry markers
    _removeOutOfBoundsMarker(bounds);

    //get entries
    var entries =
        await _entryService.getEntriesWithinRange(bounds, userIds, teamId, _entryIds, types);

    //convert entries to markers and emit
    _entriesToMarkers(entries, _entryIds);
  }

  //focus marker
  focusMarker(String markerId) {
    _emit(state.copyWith(focusMarker: markerId));
  }

  _listenToUserLocationChangeStreamEvents(BuildContext context,
      StreamSubscription? _userLocationStreamSubscription, String userId) async {
    final _geolocationService = GeolocationService();
    final _homeState = context.read<HomeScreenBloc>().state;

    final teamId = _homeState.team.id;
    final eventId = _homeState.event.id;

    //cancel stream subscription if subscribed
    if (_userLocationStreamSubscription != null) {
      _userLocationStreamSubscription.cancel();
    }

    //get userlocation stream
    var _userLocationStream = await _geolocationService.userLocationStream();

    //listen to userlocation change stream if not null
    if (_userLocationStream != null) {
      _userLocationStreamSubscription = _userLocationStream.listen((changeEvent) async {
        try {
          ETableChangeType? changeType = getChangeType(changeEvent.data['type']);
          if (changeType != null) {
            switch (changeType) {
              case ETableChangeType.Inserted:
                var _userlocation = UserLocation.fromJson(changeEvent.data['data']);
                _addUserLocation(_userlocation, userId, teamId, eventId);
                break;
              case ETableChangeType.Deleted:
                _deleteUserLocation(changeEvent.data['data'], userId, teamId, eventId);
                break;
              case ETableChangeType.Updated:
                UserLocationUpdate update = UserLocationUpdate.fromJson(changeEvent.data['data']);
                _updateUserLocation(update, userId, teamId, eventId);
                break;
            }
          }
        } catch (e) {
          print('USERLOCATION STREAM ERROR, $e');
        }
      });
    }
  }

  //add userlocation
  _addUserLocation(UserLocation userLocation, String userId, String teamId, String eventId) {
    var index = state.userLocations.indexWhere((ul) => ul.id == userLocation.id);
    if (index == -1 && userLocation.id == userId) {
      _emit(state.copyWith(userLocations: [...state.userLocations]..add(userLocation)));
    }
    _updateMemberMarkers(context, state.userLocations, userId, teamId, eventId);
  }

//update userlocation
  _updateUserLocation(UserLocationUpdate update, String userId, String teamId, String eventId) {
    var index = state.userLocations.indexWhere((ul) => ul.id == update.id);
    if (index != -1 && update.id != userId) {
      UserLocation userLocation = state.userLocations[index];
      UserLocationUpdate _update = update;

      if (_update.user != null) {
        userLocation.user = _update.user;
      }

      if (_update.latestLocation != null) {
        userLocation.latestLocation = _update.latestLocation;
      }

      if (_update.teamId != null && _update.eventId != null) {
        userLocation.teamId = _update.teamId;
        userLocation.eventId = _update.eventId;
      }

      if (_update.shareWithLeader != null && _update.shareWithMembers != null) {
        userLocation.shareWithLeader = _update.shareWithLeader ?? false;
        userLocation.shareWithMembers = _update.shareWithMembers ?? false;
      }

      _emit(state.copyWith(
          userLocations: [...state.userLocations]
            ..removeAt(index)
            ..insert(index, userLocation)));

      _updateMemberMarkers(context, state.userLocations, userId, teamId, eventId);
    }
  }

//delete userlocation
  _deleteUserLocation(String userLocationId, String userId, String teamId, String eventId) {
    var index = state.userLocations.indexWhere((ul) => ul.id == userLocationId);
    if (index != -1) {
      _emit(state.copyWith(userLocations: [...state.userLocations]..removeAt(index)));
    }
    _updateMemberMarkers(context, state.userLocations, userId, teamId, eventId);
  }

  _updateMemberMarkers(BuildContext context, List<UserLocation> userLocations, String userId,
      String teamId, String eventId) async {
    final _teamService = TeamService();

    //get my team role
    final teamRole = await _teamService.getMyTeamRole(userId, teamId);
    final _markers =
        await convertUserlocationToMarker(context, userLocations, teamId, eventId, teamRole);

    //update member markers state
    _emit(state.copyWith(memberMarkers: _markers.toList()));
  }

  Future<void> _entriesToMarkers(List<Entry> entries, List<String> entryIds) async {
    List<ItemMarker> _itemMarkers = [];
    List<ContactMarker> _contactMarkers = [];
    List<String> _entryIds = [...entryIds];

    for (var entry in entries) {
      if (entry.type == EntryType.book) {
        var _marker = await entry.toItemMarker();
        if (_marker != null) _itemMarkers.add(_marker);
      } else if (entry.type == EntryType.contact) {
        var _marker = await entry.toContactMarker();
        if (_marker != null) _contactMarkers.add(_marker);
      }
      _entryIds.add(entry.id);
    }

    //add markers to existing list
    List<ContactMarker> allContactMarkers =
        _mergeNewMarkers<ContactMarker>(state.contactMarkers ?? [], _contactMarkers);
    List<ItemMarker> allItemMarkers =
        _mergeNewMarkers<ItemMarker>(state.itemMarkers ?? [], _itemMarkers);

    //emit markers
    _emit(state.copyWith(
        entryIds: _entryIds, contactMarkers: allContactMarkers, itemMarkers: allItemMarkers));
  }

  List<T> _mergeNewMarkers<T extends Marker>(List<T> markers, List<T> newMarkers) {
    var mergedMarkers = List<T>.from(markers);
    var markerIds = markers.map((e) => e.markerId.value).toSet();

    for (var newMarker in newMarkers) {
      if (!markerIds.contains(newMarker.markerId.value)) {
        mergedMarkers.add(newMarker);
        markerIds.add(newMarker.markerId.value);
      }
    }
    return mergedMarkers;
  }

  _removeOutOfBoundsMarker(LatLngBounds bounds) {
    List<ItemMarker> _itemMarkers = [];
    List<ContactMarker> _contactMarkers = [];
    List<String> entryIds = [];

    //remove out of bounds markers
    for (Marker marker in [...state.itemMarkers ?? [], ...state.contactMarkers ?? []]) {
      if (bounds.contains(marker.position)) {
        if (marker is ItemMarker) {
          _itemMarkers.add(marker);
        } else if (marker is ContactMarker) {
          _contactMarkers.add(marker);
        }
        entryIds.add(marker.markerId.value);
      }
    }

    _emit(state.copyWith(
        itemMarkers: _itemMarkers, contactMarkers: _contactMarkers, entryIds: entryIds));
  }

  @override
  MapCubitState? fromJson(Map<String, dynamic> json) {
    return MapCubitState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(MapCubitState state) {
    return state.toJson();
  }
}

List<Marker> putMarkerToLast(String markerId, List<Marker> markers) {
  int index = markers.indexWhere((item) => item.markerId.value == markerId);
  if (index == -1) return [];
  var marker = markers.removeAt(index);
  markers.add(marker);
  return markers;
}
