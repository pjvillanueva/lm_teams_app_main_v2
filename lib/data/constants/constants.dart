// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/data/models/user_location.dart';
import 'package:lm_teams_app/presentation/widgets/markers.dart';

//account roles
enum AccountRole { owner, admin, le }

//db table types
enum DBTableType {
  account,
  user,
  session,
  entry,
  team,
  event,
  accountMember,
  accountMemberRole,
  eventMember,
  userLocation,
  masterItem,
  userItem,
  eventItem,
  teamItem,
  contact,
  interaction,
  reminder,
  teamInvitee,
  teamMember,
  eventTeam,
  deletedTeam,
  deletedEvent,
  deletedItem,
}

//permissions
const OWNER = 'Owner';
const ADMIN = 'Admin';
const LE = 'LE';

//location
const kDefaultMapCoords = LatLng(-25.547405, 133.160520);

final kDefaultUserMarker = MemberMarker(
    markerId: const MarkerId('123456789'),
    icon: BitmapDescriptor.defaultMarker,
    position: kDefaultMapCoords,
    userLocation: UserLocation.empty,
    user: User.empty);

//platforms
enum PlatformType { Unknown, Web, Android, Fuchsia, IOS, Linux, MacOS, Windows }

//my real testing device screen size 320.0 x 533.34

//frame for map pins
const kUserPinFrameUrl =
    'https://tuilder.imgix.net/beehive/20221130/user_pin_marker.png?w=200&h=200&blend-x=28&blend-y=12&fm=png&blend64=';
const kActiveMemberPinFrameUrl =
    'https://tuilder.imgix.net/beehive/20221202/TSJTXxlD-active_member_pin.png?w=200&h=200&blend-x=28&blend-y=12&fm=png&blend64=';
const kInactiveMemberPinFrameUrl =
    'https://tuilder.imgix.net/beehive/20221202/eXUNTUef-inactive_member_pin.png?w=200&h=200&blend-x=28&blend-y=12&fm=png&blend64=';

const kItemPinFrameUrl =
    'https://tuilder.imgix.net/beehive/20230809/item_pin_marker.png?fm=png&w=180&blend-y=16&blend-x=30.5&blend64=';
//pin image config
const kColoredBlend = '?mask=ellipse&crop=faces&h=140&w=140&fit=facearea&facepad=2.1&fm=png';
const kNotColoredBlend =
    '?mask=ellipse&crop=faces&h=140&w=140&fit=facearea&facepad=2.1&monochrome=C7C0C0&fm=png';
const kItemImageBlend = "?fm=png'&fit=clamp&w=120&h=160";

//contact pin marker
const kContactPinUrl =
    'https://tuilder.imgix.net/beehive/20231223/contact_marker.png?fm=png&w=180&h=180&blend-mode=darken&mask=https://tuilder.imgix.net/beehive/20231223/contact_marker.png&blend64=';

//grey background img
const kGreyBackgroundImg = 'https://tuilder.imgix.net/beehive/20230829/item_image.jpg';

const _endpoint = 'wss://backend.leteams.app/ws';
const _devEndpoint = 'ws://192.168.100.6:4267/ws';

String get ENDPOINT {
  if (kReleaseMode) {
    return _endpoint;
  } else {
    // return _devEndpoint;
    return _endpoint;
  }
}

String termsOfServiceUrl = 'https://auth.tda.website/leteams.app/tos';
String privacyPolicyUrl = 'https://auth.tda.website/leteams.app/pp';

DateTimeRange get kMemberStatisticsDefaultDateRange {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day - now.weekday + 1);
  final end = start.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
  return DateTimeRange(start: start, end: end);
}
