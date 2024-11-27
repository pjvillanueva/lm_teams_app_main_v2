import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:lm_teams_app/data/models/image%20models/image_object.dart';

// ignore: must_be_immutable
class Team extends Equatable {
  Team({required this.id, required this.name, this.image, required this.parentId});

  final String id;
  String name;
  ImageObject? image;
  String parentId;

  @override
  List<Object?> get props => [id, name, image, parentId];

  static final empty = Team(
    id: "-",
    name: "(no team)",
    image: null,
    parentId: "-",
  );

  bool get isTopLevelTeam {
    return parentId == '*';
  }

  Team.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        image = json['image'] != null ? ImageObject.fromJson(decodeJson(json['image'])) : null,
        parentId = json['parentId'];

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'image': image, 'parentId': parentId};

  @override
  String toString() => "Team: id: $id, name: $name, image: $image, parentId: $parentId";
}

Map<String, dynamic> decodeJson(dynamic value) {
  if (value is String) {
    return jsonDecode(value);
  }
  return value as Map<String, dynamic>;
}
