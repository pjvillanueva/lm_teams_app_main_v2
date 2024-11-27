import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lm_teams_app/data/models/interaction%20model/interaction_data_model.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';

enum InteractionType { BibleStudy, Visit }

InteractionType getInteractionType(dynamic jsonType) {
  return InteractionType.values.where((e) => e.name == jsonType).first;
}

getInteractionData(InteractionType type, dynamic jsonData) {
  switch (type) {
    case InteractionType.BibleStudy:
      return BibleStudyData.fromJson(_decodeIfJson(jsonData));
    case InteractionType.Visit:
      return VisitData.fromJson(_decodeIfJson(jsonData));
    default:
  }
}

dynamic _decodeIfJson(dynamic object) {
  if (object.runtimeType == String) {
    return jsonDecode(object);
  }
  return object;
}

class Interaction<T> extends Equatable {
  const Interaction({
    required this.id,
    required this.contactId,
    this.ownerId,
    required this.type,
    required this.notes,
    required this.data,
    required this.time,
  });
  final String id;
  final String contactId;
  final String? ownerId;
  final InteractionType type;
  final String notes;
  final T? data;
  final DateTime time;

  @override
  List<Object?> get props => [id, contactId, ownerId, type, notes, data, time];

  Interaction.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        contactId = json['contactId'],
        ownerId = json['_ownerId'],
        type = getInteractionType(json['type']),
        notes = json['notes'],
        data = getInteractionData(getInteractionType(json['type']), json['data']),
        time = DateTime.parse(json['time']).toLocal();

  Map<String, dynamic> toJson() => {
        'id': id,
        'contactId': contactId,
        '_ownerId': ownerId,
        'type': type.name,
        'notes': notes,
        'data': data,
        'time': time.toIso8601String()
      };

  get simpleDate {
    final DateFormat formatter = DateFormat('MMMM dd, hh:mm aaa');
    return formatter.format(time);
  }

  String visitedBy(List<User> users) {
    var name = 'Unknown';
    for (var user in users) {
      if (user.id == ownerId) {
        name = user.firstName;
      }
    }
    return 'visited by ' + name;
  }

  Widget get typeView {
    switch (type) {
      case InteractionType.Visit:
        var _data = data as VisitData;
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_data.wasHome ? Icons.home : Icons.disabled_by_default,
              color: _data.wasHome ? Colors.green : Colors.red, size: 24.0.spMin),
          const SizedBox(width: 10),
          Text(_data.wasHome ? 'Home' : 'Not Home', style: TextStyle(fontSize: 14.0.spMin))
        ]);

      case InteractionType.BibleStudy:
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.star, color: Colors.yellowAccent, size: 24.0.spMin),
          SizedBox(width: 10.0.spMin),
          Text('Bible Study', style: TextStyle(fontSize: 14.0.spMin))
        ]);
    }
  }

  @override
  String toString() =>
      'Interaction (id: $id, contactId: $contactId, ownerId: $ownerId, type: $type, notes: $notes, data: $data, time: $time)';
}
