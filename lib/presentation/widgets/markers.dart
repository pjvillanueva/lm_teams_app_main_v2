// ignore_for_file: must_be_immutable
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/data/models/user_location.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/entry model/entry_data_model.dart';

class MemberMarker extends Marker {
  MemberMarker(
      {required MarkerId markerId,
      double alpha = 1.0,
      Offset anchor = const Offset(0.5, 1.0),
      bool consumeTapEvents = false,
      bool draggable = false,
      bool flat = false,
      BitmapDescriptor icon = BitmapDescriptor.defaultMarker,
      InfoWindow infoWindow = InfoWindow.noText,
      LatLng position = const LatLng(0.0, 0.0),
      double rotation = 0.0,
      bool visible = true,
      double zIndex = 0.0,
      void Function()? onTap,
      void Function(LatLng)? onDrag,
      void Function(LatLng)? onDragStart,
      void Function(LatLng)? onDragEnd,
      required this.user,
      required this.userLocation})
      : super(
            markerId: markerId,
            alpha: alpha,
            anchor: anchor,
            consumeTapEvents: consumeTapEvents,
            draggable: draggable,
            flat: flat,
            icon: icon,
            infoWindow: infoWindow,
            position: position,
            rotation: rotation,
            visible: visible,
            zIndex: zIndex,
            onTap: onTap,
            onDrag: onDrag,
            onDragStart: onDragStart,
            onDragEnd: onDragEnd);
  User user;
  UserLocation userLocation;

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson() as Map<String, dynamic>;
    json['user'] = user.toJson();
    json['userLocation'] = userLocation.toJson();
    return json;
  }

  static MemberMarker fromJson(Map<String, dynamic> json) {
    return MemberMarker(
        markerId: MarkerId(json['markerId']),
        alpha: json['alpha'],
        anchor: offsetFromJson(json['anchor']),
        consumeTapEvents: json['consumeTapEvents'],
        draggable: json['draggable'],
        flat: json['flat'],
        icon: bitmapDescriptorFromJson(json['icon']),
        infoWindow: infoWindowFromJson(json['infoWindow']),
        position: LatLng(json['position'][0], json['position'][1]),
        rotation: json['rotation'],
        visible: json['visible'],
        zIndex: json['zIndex'],
        user: User.fromJson(json['user']),
        userLocation: UserLocation.fromJson(json['userLocation']));
  }

  MemberMarker get newZindex {
    return MemberMarker(
        markerId: markerId,
        alpha: alpha,
        anchor: anchor,
        consumeTapEvents: consumeTapEvents,
        draggable: draggable,
        flat: flat,
        icon: icon,
        infoWindow: infoWindow,
        position: position,
        rotation: rotation,
        visible: visible,
        zIndex: 1.0,
        user: user,
        userLocation: userLocation);
  }
}

Offset offsetFromJson(dynamic json) {
  return Offset(json[0], json[1]);
}

InfoWindow infoWindowFromJson(Map<String, dynamic> json) {
  return InfoWindow(
      title: json['title'],
      snippet: json['snippet'],
      anchor: offsetFromJson(json['anchor']),
      onTap: json['onTap']);
}

BitmapDescriptor bitmapDescriptorFromJson(dynamic json) {
  Uint8List bytesList = Uint8List.fromList(json[1]);
  return BitmapDescriptor.fromBytes(bytesList);
}

class ContactMarker extends Marker {
  ContactMarker({
    required MarkerId markerId,
    double alpha = 1.0,
    Offset anchor = const Offset(0.5, 1.0),
    bool consumeTapEvents = false,
    bool draggable = false,
    bool flat = false,
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker,
    InfoWindow infoWindow = InfoWindow.noText,
    LatLng position = const LatLng(0.0, 0.0),
    double rotation = 0.0,
    bool visible = true,
    double zIndex = 0.0,
    void Function()? onTap,
    void Function(LatLng)? onDrag,
    void Function(LatLng)? onDragStart,
    void Function(LatLng)? onDragEnd,
    required this.contact,
  }) : super(
            markerId: markerId,
            alpha: alpha,
            anchor: anchor,
            consumeTapEvents: consumeTapEvents,
            draggable: draggable,
            flat: flat,
            icon: icon,
            infoWindow: infoWindow,
            position: position,
            rotation: rotation,
            visible: visible,
            zIndex: zIndex,
            onTap: onTap,
            onDrag: onDrag,
            onDragStart: onDragStart,
            onDragEnd: onDragEnd);
  Contact contact;

  ContactMarker get newZindex {
    return ContactMarker(
        markerId: markerId,
        alpha: alpha,
        anchor: anchor,
        consumeTapEvents: consumeTapEvents,
        draggable: draggable,
        flat: flat,
        icon: icon,
        infoWindow: infoWindow,
        position: position,
        rotation: rotation,
        visible: visible,
        zIndex: 1.0,
        onTap: onTap,
        onDrag: onDrag,
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
        contact: contact);
  }
}

class ItemMarker extends Marker {
  ItemMarker({
    required MarkerId markerId,
    double alpha = 1.0,
    Offset anchor = const Offset(0.5, 1.0),
    bool consumeTapEvents = false,
    bool draggable = false,
    bool flat = false,
    BitmapDescriptor icon = BitmapDescriptor.defaultMarker,
    InfoWindow infoWindow = InfoWindow.noText,
    LatLng position = const LatLng(0.0, 0.0),
    double rotation = 0.0,
    bool visible = true,
    double zIndex = 0.0,
    void Function()? onTap,
    void Function(LatLng)? onDrag,
    void Function(LatLng)? onDragStart,
    void Function(LatLng)? onDragEnd,
    required this.data,
  }) : super(
            markerId: markerId,
            alpha: alpha,
            anchor: anchor,
            consumeTapEvents: consumeTapEvents,
            draggable: draggable,
            flat: flat,
            icon: icon,
            infoWindow: infoWindow,
            position: position,
            rotation: rotation,
            visible: visible,
            zIndex: zIndex,
            onTap: onTap,
            onDrag: onDrag,
            onDragStart: onDragStart,
            onDragEnd: onDragEnd);
  BookEntryData data;

  ItemMarker get newZindex {
    return ItemMarker(
        markerId: markerId,
        alpha: alpha,
        anchor: anchor,
        consumeTapEvents: consumeTapEvents,
        draggable: draggable,
        flat: flat,
        icon: icon,
        infoWindow: infoWindow,
        position: position,
        rotation: rotation,
        visible: visible,
        zIndex: 1.0,
        onTap: onTap,
        onDrag: onDrag,
        onDragStart: onDragStart,
        onDragEnd: onDragEnd,
        data: data);
  }
}
