import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_model.dart';
import 'package:lm_teams_app/data/models/user_location.dart';
import 'package:lm_teams_app/presentation/widgets/markers.dart';

ETableChangeType? getChangeType(int type) {
  switch (type) {
    case 0:
      return ETableChangeType.Inserted;
    case 1:
      return ETableChangeType.Deleted;
    case 2:
      return ETableChangeType.Updated;
    default:
      return null;
  }
}

MapType getMapType(String index) {
  switch (index) {
    case '0':
      return MapType.normal;
    case '1':
      return MapType.satellite;
    case '2':
      return MapType.hybrid;
    case '3':
      return MapType.terrain;
    default:
      return MapType.normal;
  }
}

Future<List<ContactMarker>> contactEntriesToMarkers(List<Entry> contactEntries) async {
  List<ContactMarker> contactMarkers = [];
  try {
    for (var entry in contactEntries) {
      var marker = await entry.toContactMarker();
      if (marker != null) {
        contactMarkers.add(marker);
      }
    }
    return contactMarkers;
  } catch (e) {
    print('ERROR IN contactEntriesToMarkers: $e');
    return [];
  }
}

Future<List<ItemMarker>> bookEntriesToMarkers(List<Entry> bookEntries) async {
  List<ItemMarker> itemMarkers = [];
  try {
    for (var entry in bookEntries) {
      var itemMarker = await entry.toItemMarker();
      if (itemMarker != null) {
        itemMarkers.add(itemMarker);
      }
    }
    return itemMarkers;
  } catch (e) {
    print(e);
    return [];
  }
}
