import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:lm_teams_app/data/models/image%20models/image_object.dart';

// ignore: must_be_immutable
class Event extends Equatable {
  Event({
    required this.id,
    required this.name,
    this.image,
    required this.location,
    required this.isOpenEvent,
    this.eventStartDate,
    this.eventEndDate,
  });
  final String id;
  String name;
  ImageObject? image;
  final String location;
  final bool isOpenEvent;
  final DateTime? eventStartDate;
  final DateTime? eventEndDate;

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        location,
        isOpenEvent,
        eventStartDate,
        eventEndDate,
      ];

  static final empty = Event(
      id: '-',
      name: '(no event)',
      image: null,
      location: '-',
      isOpenEvent: false,
      eventStartDate: DateTime.now(),
      eventEndDate: DateTime.now());

  bool get isOngoing {
    final currentDate = DateTime.now();

    if (eventStartDate != null && eventEndDate != null) {
      return currentDate.isAfter(eventStartDate!) && currentDate.isBefore(eventEndDate!);
    }
    return false;
  }

  Event.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        image = json['image'] != null ? ImageObject.fromJson(decodeJson(json['image'])) : null,
        location = json['location'],
        isOpenEvent = json['isOpenEvent'],
        eventStartDate = DateTime.parse(json['eventStartDate']),
        eventEndDate = DateTime.parse(json['eventEndDate']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'location': location,
        'isOpenEvent': isOpenEvent,
        'eventStartDate': eventStartDate!.toIso8601String(),
        'eventEndDate': eventEndDate!.toIso8601String()
      };

  @override
  String toString() =>
      'Event: id: $id, name: $name, image: $image, location: $location, isOpenEvent: $isOpenEvent, eventStartDate: $eventStartDate, eventEndDate: $eventEndDate';
}

Map<String, dynamic> decodeJson(dynamic value) {
  if (value is String) {
    return jsonDecode(value);
  }
  return value as Map<String, dynamic>;
}
