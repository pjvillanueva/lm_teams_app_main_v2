import 'dart:convert';
import 'package:lm_teams_app/data/models/image%20models/image_object.dart';

class DispensedBook {
  DispensedBook({
    required this.itemId,
    required this.name,
    required this.code,
    required this.quantity,
    required this.image,
    required this.tags,
  });
  final String itemId;
  final String name;
  final String code;
  int quantity;
  final ImageObject? image;
  final List tags;

  @override
  String toString() =>
      'DispensedBook: itemId: $itemId, name: $name, code: $code, quantity: $quantity, image: $image, tags: $tags';

  Map<String, dynamic> toJson() => {
        'itemID': itemId,
        'name': name,
        'code': code,
        'quantity': quantity,
        'image': image,
        'tags': tags,
      };

  DispensedBook.fromJson(Map<String, dynamic> json)
      : itemId = json['itemID'],
        name = json['name'],
        code = json['code'],
        quantity = json['quantity'],
        image = json['image'] != null ? ImageObject.fromJson(_decodeIfJson(json['image'])) : null,
        tags = _decodeIfJson(json['tags']);

  static var empty =
      DispensedBook(itemId: '', name: '', code: '', quantity: 0, image: null, tags: []);
}

dynamic _decodeIfJson(dynamic object) {
  if (object.runtimeType == String) {
    return jsonDecode(object);
  }
  return object;
}
