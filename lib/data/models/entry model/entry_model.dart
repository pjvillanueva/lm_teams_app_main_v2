import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_data_model.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import '../../../presentation/widgets/markers.dart';
import '../../../services/geolocation_service.dart';
import '../../../services/utils_service.dart';

enum EntryType { book, money, prayer, contact, notes }

getEntryData(EntryType type, dynamic jsonData) {
  switch (type) {
    case EntryType.book:
      return BookEntryData.fromJson(decodeJsonEntryData(jsonData));
    case EntryType.contact:
      return Contact.fromJson(decodeJsonEntryData(jsonData));
    case EntryType.money:
      return MoneyEntryData.fromJson(decodeJsonEntryData(jsonData));
    case EntryType.notes:
      return jsonData;
    case EntryType.prayer:
      return jsonData;
  }
}

Map<String, dynamic> decodeJsonEntryData(dynamic value) {
  if (value is String) {
    return jsonDecode(value);
  } else if (value is MoneyEntryData) {
    return value.toJson();
  } else if (value is Contact) {
    return value.toJson();
  } else if (value is BookEntryData) {
    return value.toJson();
  } else {
    return value as Map<String, dynamic>;
  }
}

EntryType getEntryType(dynamic jsonType) {
  return EntryType.values.where((e) => e.name == jsonType).first;
}

// ignore: must_be_immutable
class Entry<T> extends Equatable {
  Entry({
    required this.id,
    required this.data,
    required this.time,
    required this.teamId,
    required this.eventId,
    required this.type,
    this.locationEvent,
    this.ownerId,
  });

  final String id;
  T? data;
  final DateTime time;
  final String? teamId;
  final String? eventId;
  final EntryType type;
  final LocationEvent? locationEvent;
  String? ownerId;

  @override
  List<Object?> get props => [id, data, time, type, locationEvent, ownerId];

  Entry.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        data = getEntryData(getEntryType(json['type']), json['data']),
        time = DateTime.parse(json['time']),
        teamId = json['team_id'],
        eventId = json['event_id'],
        type = getEntryType(json['type']),
        locationEvent = json['location_event'] != null
            ? LocationEvent.fromJson(jsonDecode(json['location_event']))
            : null,
        ownerId = json['_owner_id'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'time': time.toIso8601String(),
        'teamId': teamId,
        'eventId': eventId,
        'type': type.name,
        'locationEvent': locationEvent,
      };

  dynamic get castedData {
    switch (type) {
      case EntryType.book:
        return data as BookEntryData;
      case EntryType.contact:
        return data as Contact;
      case EntryType.money:
        return data as MoneyEntryData;
      case EntryType.notes:
        return data as NoteEntryData;
      case EntryType.prayer:
        return data as PrayerEntryData;
      default:
    }
  }

  Entry updated(dynamic updatedData, {LocationEvent? latestLocation}) {
    return Entry(
        id: id,
        data: updatedData,
        time: time,
        teamId: teamId,
        eventId: eventId,
        type: type,
        locationEvent: latestLocation ?? locationEvent);
  }

  Future<ItemMarker?> toItemMarker() async {
    if (type != EntryType.book) return null;
    if (locationEvent == null) return null;
    final _utils = UtilsService();
    final _geolocationService = GeolocationService();
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
    bool hasInternet = await _utils.hasInternet;
    BookEntryData data = castedData as BookEntryData;
    InventoryItem? item = data.item;

    if (hasInternet) {
      var pinUrl = _geolocationService.getItemPinUrl(item?.image?.url, item?.code);
      var imageAsBytes = await _utils.urlToBytes(pinUrl);
      icon = BitmapDescriptor.fromBytes(imageAsBytes);
    }

    return ItemMarker(
        markerId: MarkerId(id),
        icon: icon,
        position: LatLng(locationEvent!.latitude, locationEvent!.longitude),
        infoWindow: InfoWindow(
            title: '${item?.name} (${data.quantity})', snippet: locationEvent?.timeStamp.timeAgo),
        data: data);
  }

  Future<ContactMarker?> toContactMarker() async {
    if (type != EntryType.contact) return null;
    if (locationEvent == null) return null;
    final _utils = UtilsService();
    bool hasInternet = await _utils.hasInternet;
    Contact contact = castedData as Contact;
    Color color = Color(contact.avatarColor);
    BitmapDescriptor icon = BitmapDescriptor.defaultMarkerWithHue(_utils.colorToHue(color));

    if (hasInternet) {
      var pinAsBytes = await _utils.urlToBytes(contact.contactPin);
      icon = BitmapDescriptor.fromBytes(pinAsBytes);
    }

    return ContactMarker(
        markerId: MarkerId(id),
        icon: icon,
        position: LatLng(locationEvent!.latitude, locationEvent!.longitude),
        infoWindow: InfoWindow(title: contact.name),
        contact: contact);
  }

  @override
  String toString() =>
      "Entry Data :  id: $id, data: $data, time: $time, type: ${type.name}, locationEvent: $locationEvent, teamID: $teamId, eventId: $eventId, ownerId: $ownerId";
}
