import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_data_model.dart';
import 'package:lm_teams_app/data/models/image%20models/image_object.dart';
import '../../../services/items_service.dart';

// ignore: must_be_immutable
class InventoryItem extends Equatable {
  InventoryItem({
    required this.id,
    required this.image,
    required this.name,
    required this.code,
    required this.cost,
    required this.tags,
    this.originId,
    this.eventId,
    this.teamId,
    this.userId,
    this.trackStock,
    this.quantity,
  });

  final String id;
  String? originId;
  ImageObject? image;
  String name;
  final String code;
  String cost;
  List tags;
  String? userId;
  String? teamId;
  String? eventId;
  bool? trackStock;
  int? quantity;

  @override
  List<Object?> get props =>
      [id, originId, image, name, code, cost, tags, userId, teamId, eventId, trackStock];

  InventoryItem.fromJson(Map<String, dynamic> json)
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

//filter null
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
      'code': code,
      'tags': tags,
      if (originId != null) 'originId': originId,
      if (image != null) 'image': image,
      if (eventId != null) 'eventId': eventId,
      if (teamId != null) 'teamId': teamId,
      if (userId != null) 'userId': userId,
      if (trackStock != null) 'trackStock': trackStock,
      if (quantity != null) 'quantity': quantity,
    };
  }

  Future<bool> get hasOverrides async {
    final _itemService = ItemService();
    //no overrides if master item
    if (originId == null) return false;
    //get master item
    InventoryItem? masterItem = await _itemService.getMasterItem(originId!);
    if (masterItem == null) return false;
    return masterItem.name != name ||
        masterItem.cost != cost ||
        !listEquals(masterItem.tags, tags) ||
        masterItem.image != image;
  }

  bool isEqualTo(InventoryItem item) {
    return item.id == id &&
        item.name == name &&
        item.cost == cost &&
        listEquals(item.tags, tags) &&
        item.image == image;
  }

  static var empty = InventoryItem(
      id: "",
      originId: "",
      image: null,
      name: "",
      code: "",
      cost: "",
      tags: const [],
      eventId: "",
      teamId: "",
      userId: "",
      trackStock: false,
      quantity: 0);

  @override
  String toString() {
    return "Inventory Item: id: $id, image: $image, name: $name, code: $code, cost: $cost, tags: $tags, eventId: $eventId, teamId: $teamId, userId: $userId, trackStock: $trackStock, quantity: $quantity";
  }
}

List decodeList(dynamic value) {
  if (value is String) {
    return jsonDecode(value);
  }
  return value;
}
