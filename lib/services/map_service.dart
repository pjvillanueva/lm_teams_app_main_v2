import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/db_operation_object.dart';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/data/models/user_location.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/presentation/widgets/markers.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';
import 'package:lm_teams_app/services/response-handlers/response-handlers.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

class MapService {
  final _socket = WebSocketService();

  Future<List<UserLocation>> getTeamMembersUserlocations(
      {String? teamId, String? eventId, required String userId}) async {
    //get all team member's userlocations
    List<UserLocation> _userLocations = await _getMembersSavedUserlocations(
        GetUserLocationFilterData(teamID: teamId, eventID: eventId));

    //filter own userlocation
    _userLocations.removeWhere((userLocation) => userLocation.id == userId);

    return _userLocations;
  }

  Future<Set<MemberMarker>> convertUserlocationToMarker(BuildContext context,
      List<UserLocation> userLocations, String teamId, String eventId, ETeamRole teamRole) async {
    Set<MemberMarker> allMarkers = {};
    var _filteredUserlocations =
        await _filterUserlocationsToConvert(userLocations, teamId, eventId, teamRole);

    for (var userLocation in _filteredUserlocations) {
      var _marker = await userLocation.toMemberMarker(PinType.member);
      if (_marker != null) {
        allMarkers.add(_marker);
      }
    }
    return allMarkers;
  }

  Future<List<UserLocation>> _filterUserlocationsToConvert(
      List<UserLocation> userlocations, String teamId, String eventId, ETeamRole teamRole) async {
    List<UserLocation> _filteredUserlocations = [];

    for (var userlocation in userlocations) {
      if (_isValidUserlocation(userlocation, teamId, eventId, teamRole)) {
        _filteredUserlocations.add(userlocation);
      }
    }
    return _filteredUserlocations;
  }

  bool _isValidUserlocation(
      UserLocation userlocation, String teamId, String eventId, ETeamRole teamRole) {
    if (userlocation.latestLocation == null) return false;
    if (userlocation.latestLocation!.timeStamp
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) return false;
    if (userlocation.teamId != teamId && userlocation.eventId != eventId) return false;
    if (userlocation.shareWithLeader == false && userlocation.shareWithMembers == false) {
      return false;
    }
    if (userlocation.shareWithLeader == true &&
        userlocation.shareWithMembers == false &&
        teamRole != ETeamRole.Leader) return false;
    return true;
  }

  Future<List<UserLocation>> _getMembersSavedUserlocations(
      GetUserLocationFilterData filterData) async {
    if (!_socket.isConnected) return [];
    if (filterData.toJson().isEmpty) return [];
    var response = await HandleUserLocationList(await _socket.sendAndWait(Message('Read',
            data: IDBOperationObject(
                table: DBTableType.userLocation.name,
                options: IDBReadOptions(where: filterData.toJson())))))
        .run();
    return response.data ?? [];
  }

  List<LatLng> getSquareCornersFromBounds(LatLngBounds bounds) {
    LatLng southwest = bounds.southwest;
    LatLng northeast = bounds.northeast;

    final double minLat = southwest.latitude;
    final double maxLat = northeast.latitude;
    final double minLng = southwest.longitude;
    final double maxLng = northeast.longitude;

    return [
      LatLng(minLat, minLng),
      LatLng(minLat, maxLng),
      LatLng(maxLat, maxLng),
      LatLng(maxLat, minLng),
      LatLng(minLat, minLng)
    ];
  }
}
