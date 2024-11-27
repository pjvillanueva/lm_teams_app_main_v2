import 'dart:convert';
import 'package:lm_teams_app/data/models/entry%20model/entry_data_model.dart';
import 'package:lm_teams_app/data/models/image%20models/image_object.dart';

class ItemTemplate {
  ItemTemplate(
      {this.id,
      this.originId,
      this.image,
      this.name,
      this.code,
      this.cost,
      this.tags,
      this.userId,
      this.teamId,
      this.eventId,
      this.trackStock,
      this.quantity});

  String? id;
  String? originId;
  ImageObject? image;
  String? name;
  String? code;
  String? cost;
  List? tags;
  String? userId;
  String? teamId;
  String? eventId;
  bool? trackStock;
  int? quantity;

  ItemTemplate.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        originId = json["originId"],
        image = json['image'] != null ? ImageObject.fromJson(decodeImage(json['image'])) : null,
        name = json["name"],
        cost = json["cost"],
        code = json["code"],
        tags = decodeList(json["tags"]),
        eventId = json['eventId'],
        teamId = json['teamId'],
        userId = json['userId'],
        trackStock = json['trackStock'],
        quantity = json['quantity'];

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cost != null) 'cost': cost,
      if (code != null) 'code': code,
      if (tags != null) 'tags': tags,
      if (originId != null) 'originId': originId,
      if (image != null) 'image': image,
      if (eventId != null) 'eventId': eventId,
      if (teamId != null) 'teamId': teamId,
      if (userId != null) 'userId': userId,
      if (trackStock != null) 'trackStock': trackStock,
      if (quantity != null) 'quantity': quantity,
    };
  }

  @override
  String toString() {
    return "Item Template ${id != null ? 'id: $id, ' : ''}"
        "${name != null ? 'name : $name, ' : ''}"
        "${cost != null ? 'cost : $cost, ' : ''}"
        "${code != null ? 'code : $code, ' : ''}"
        "${tags != null ? 'tags : $tags, ' : ''}"
        "${originId != null ? 'originId : $originId, ' : ''}"
        "${image != null ? 'image : $image, ' : ''}"
        "${eventId != null ? 'eventId : $eventId, ' : ''}"
        "${teamId != null ? 'teamId : $teamId, ' : ''}"
        "${userId != null ? 'userId : $userId, ' : ''}"
        "${trackStock != null ? 'trackStock : $trackStock, ' : ''}"
        "${quantity != null ? 'quantity : $quantity, ' : ''}";
  }
}

List? decodeList(dynamic value) {
  if (value is String) {
    return jsonDecode(value);
  }
  return value;
}
