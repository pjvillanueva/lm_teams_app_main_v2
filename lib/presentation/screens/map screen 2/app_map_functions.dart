import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/models/user_location.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/presentation/widgets/markers.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';

//get userlocation from latest states
UserLocation userLocationFromStates(BuildContext context) {
  final user = context.read<UserBloc>().state.user;
  final homeState = context.read<HomeScreenBloc>().state;
  final geoState = context.read<GeolocationBloc>().state;

  return UserLocation(
      id: user.id,
      user: user,
      teamId: homeState.team.id,
      eventId: homeState.event.id,
      latestLocation: geoState.latestLocation,
      locations: geoState.locations,
      shareWithLeader: true,
      shareWithMembers: true);
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
  if (userlocation.shareWithLeader == false && userlocation.shareWithMembers == false) return false;
  if (userlocation.shareWithLeader == true &&
      userlocation.shareWithMembers == false &&
      teamRole != ETeamRole.Leader) return false;
  return true;
}
