import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:lm_teams_app/data/models/image%20models/image_object.dart';
import '../inventory models/inventory_item.dart';

class BookEntryData extends Equatable {
  const BookEntryData({required this.itemID, required this.quantity, this.item});
  final String itemID;
  final int quantity;
  final InventoryItem? item;
  @override
  List<Object?> get props => [itemID, quantity, item];

  BookEntryData.fromJson(Map<String, dynamic> json)
      : itemID = json['itemID'],
        quantity = json['quantity'],
        item = json['item'] != null ? InventoryItem.fromJson(json['item']) : null;

  Map<String, dynamic> toJson() => {
        'itemID': itemID,
        'quantity': quantity,
        if (item != null) 'item': item,
      };
}

Map<String, dynamic> decodeImage(dynamic value) {
  if (value is String) {
    return jsonDecode(value);
  } else if (value is ImageObject) {
    return value.toJson();
  }
  return value as Map<String, dynamic>;
}

class MoneyEntryData extends Equatable {
  const MoneyEntryData({required this.notes, required this.card, required this.coins});
  final double notes;
  final double card;
  final double coins;
  @override
  List<Object?> get props => [notes, card, coins];

  MoneyEntryData.fromJson(Map<String, dynamic> json)
      : notes = double.parse(json['notes'].toString()),
        card = double.parse(json['card'].toString()),
        coins = double.parse(json['coins'].toString());

  Map<String, dynamic> toJson() => {'notes': notes, 'card': card, 'coins': coins};
}

class NoteEntryData extends Equatable {
  const NoteEntryData({required this.note});

  final String note;
  @override
  List<Object?> get props => [note];
}

class PrayerEntryData extends Equatable {
  const PrayerEntryData({required this.prayer});

  final String prayer;
  @override
  List<Object?> get props => [prayer];
}
