import 'package:flutter/foundation.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';

abstract class UpdateGetter {
  Map<String, dynamic> run();
}

class GetItemUpdates extends UpdateGetter {
  GetItemUpdates({required this.originalItem, required this.updatedItem});
  final InventoryItem originalItem;
  final InventoryItem updatedItem;
  @override
  Map<String, dynamic> run() {
    const simpleProperties = ['name', 'image', 'cost', 'quantity', 'trackStock'];
    const listProperties = ['tags'];
    Map<String, dynamic> updates = {'id': originalItem.id};
    Map<String, dynamic> originMap = originalItem.toJson();
    Map<String, dynamic> updatedMap = updatedItem.toJson();

    for (var prop in simpleProperties) {
      if (originMap[prop] != updatedMap[prop]) {
        updates[prop] = updatedMap[prop];
      }
    }
    for (var prop in listProperties) {
      if (!listEquals(originMap[prop], updatedMap[prop])) {
        updates[prop] = updatedMap[prop];
      }
    }
    return updates;
  }
}

class GetItemResetUpdates extends UpdateGetter {
  GetItemResetUpdates({required this.itemToReset});
  final InventoryItem itemToReset;

  @override
  Map<String, dynamic> run() {
    Map<String, dynamic> updates = {'id': itemToReset.id};
    const resetProperties = ['name', 'image', 'cost', 'tags'];
    //do not reset if master item
    if (itemToReset.originId == null) return updates;

    //get updates
    for (var prop in resetProperties) {
      updates[prop] = null;
    }
    return updates;
  }
}
