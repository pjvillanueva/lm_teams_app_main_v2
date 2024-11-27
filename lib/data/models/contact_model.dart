import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';

class Contact extends Equatable {
  const Contact(
      {required this.id,
      required this.ownerId,
      required this.name,
      required this.houseNumber,
      required this.street,
      required this.address,
      required this.color,
      required this.phone,
      required this.sharedWith,
      this.email,
      this.notes,
      required this.locationEvent});

  final String id;
  final String ownerId;
  final String name;
  final String street;
  final String houseNumber;
  final String address;
  final String color;
  final List phone;
  final String? email;
  final String? notes;
  final List sharedWith;
  final LocationEvent? locationEvent;
  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        street,
        houseNumber,
        address,
        phone,
        email,
        notes,
        color,
        sharedWith,
        locationEvent
      ];

  Contact.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        ownerId = json['_ownerId'],
        name = json['name'],
        street = json['street'],
        houseNumber = json['houseNumber'],
        address = json['address'],
        color = json['color'],
        phone = _isJsonString(json['phone']) ? jsonDecode(json['phone']) : json['phone'],
        email = json['email'],
        notes = json['notes'],
        sharedWith =
            _isJsonString(json['sharedWith']) ? jsonDecode(json['sharedWith']) : json['sharedWith'],
        locationEvent = json['locationEvent'] != null
            ? LocationEvent.fromJson(jsonDecode(json['locationEvent']))
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        '_ownerId': ownerId,
        'name': name,
        'street': street,
        'houseNumber': houseNumber,
        'address': address,
        'color': color,
        'phone': phone,
        'email': email,
        'notes': notes,
        'sharedWith': sharedWith,
        'locationEvent': locationEvent
      };

  static const empty = Contact(
      id: 'id',
      ownerId: '',
      name: '',
      houseNumber: '',
      street: '',
      address: '',
      color: '',
      phone: [],
      sharedWith: [],
      locationEvent: null);

  String get initials {
    if (name.isNotEmpty) {
      return name.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join();
    } else {
      return '';
    }
  }

  int get avatarColor {
    return int.parse(color);
  }

  String get fullAddress {
    final parts = [
      if (houseNumber.isNotEmpty) houseNumber,
      if (street.isNotEmpty) street,
      if (address.isNotEmpty && street.isNotEmpty) ',',
      if (address.isNotEmpty) address
    ].where((p) => p.isNotEmpty);
    return parts.join(' ');
  }

  String get contactPin => kContactPinUrl + colorInBase64;

  String get colorInBase64 {
    Color color = Color(avatarColor);
    String hexColor = '#${color.value.toRadixString(16).substring(2)}';
    List<int> bytes = utf8.encode(hexColor);
    return base64.encode(bytes).replaceAll('=', '');
  }

  Widget get icon {
    return Image(
        image: NetworkImage(contactPin),
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, color: Color(avatarColor), size: 50);
        });
  }

  bool get hasLocationEvent {
    return locationEvent != null;
  }

  @override
  String toString() =>
      'Contact(id: $id, ownerId: $ownerId, name: $name, houseNumber: $houseNumber, street: $street, address: $address, color: $color, phone: $phone, email: $email, notes: $notes, sharedWith: $sharedWith. locationEvent: $locationEvent)';
}

bool _isJsonString(dynamic json) {
  return json.runtimeType == String;
}
