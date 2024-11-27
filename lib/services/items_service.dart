import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/db_operation_object.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/data/models/inventory%20models/item_template.dart';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/services/auth_service.dart';
import 'package:lm_teams_app/services/response-handlers/response-handlers.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

class ICrudInventoryItemContext {
  ICrudInventoryItemContext({required this.tableName, required this.item});
  final String tableName;
  final InventoryItem item;

  Map<String, dynamic> toJson() {
    return {
      'table': tableName,
      "item": item.toJson(),
    };
  }
}

enum DBItemType { masterItem, userItem, teamItem, eventItem }

class IReadItemContext {
  IReadItemContext({this.userId, this.teamId, this.eventId});
  final String? userId;
  final String? teamId;
  final String? eventId;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'teamId': teamId,
      'eventId': eventId,
    };
  }
}

class ItemService {
  final _socket = WebSocketService();
  final _authService = AuthService();

  Future<List<InventoryItem>> getInventoryItems([IReadItemContext? context]) async {
    if (!_socket.isConnected) return [];
    var response =
        await HandleItemList(await _socket.sendAndWait(Message("ReadItems", data: context))).run();
    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  Future<InventoryItem?> getMasterItem(String originId) async {
    if (!_socket.isConnected) return null;
    var response = await _socket.sendAndWait(Message("Read",
        data: IDBOperationObject(
            table: DBTableType.masterItem.name,
            options: IDBReadOptions(where: {'id': originId}, firstOnly: true))));
    return response.data == null ? null : InventoryItem.fromJson(response.data);
  }

  Future<InventoryItem?> _getInventoryItem(String itemId, DBItemType table) async {
    try {
      Map<String, dynamic> inventoryItemMap = {};
      Map<String, dynamic> originItemMap = {};
      final props = ['name', 'image', 'cost', 'code', 'tags'];
      if (!_socket.isConnected) return null;

      //get the inventory item
      var response = await _socket.sendAndWait(Message("Read",
          data: IDBOperationObject(
              table: table.name, options: IDBReadOptions(where: {'id': itemId}, firstOnly: true))));
      inventoryItemMap = response.data;

      //get the origin item
      if (inventoryItemMap['originId'] == null) return null;
      var response2 = await _socket.sendAndWait(Message('Read',
          data: IDBOperationObject(
              table: DBItemType.masterItem.name,
              options:
                  IDBReadOptions(where: {'id': inventoryItemMap['originId']}, firstOnly: true))));
      originItemMap = response2.data;

      for (var prop in props) {
        if (inventoryItemMap[prop] == null) {
          inventoryItemMap[prop] = originItemMap[prop];
        }
      }
      return InventoryItem.fromJson(inventoryItemMap);
    } catch (e) {
      return null;
    }
  }

  Future<List<InventoryItem>> getMasterItems() async {
    if (!_socket.isConnected) return [];
    var session = await _authService.session;
    if (session == null) return [];
    var response = await HandleItemList(await _socket.sendAndWait(Message("Read",
            data: IDBOperationObject(
                table: DBTableType.masterItem.name,
                options: IDBReadOptions(where: {'_account_id': session.accountId})))))
        .run();
    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  Future<List<InventoryItem>> getItemsForItemPicker(String userId, String teamId, String eventId,
      {bool includeMasterItems = true}) async {
    List<InventoryItem> itemPickerList =
        await getInventoryItems(IReadItemContext(userId: userId, teamId: teamId, eventId: eventId));

    if (includeMasterItems) {
      List<String> originIds = [];

      for (var item in itemPickerList) {
        if (item.originId != null) {
          originIds.add(item.originId!);
        }
      }

      List<InventoryItem> masterItems = await getMasterItems();
      for (var item in masterItems) {
        if (!originIds.contains(item.id)) {
          itemPickerList.add(item);
        }
      }
    }

    return itemPickerList;
  }

  Future<bool> _saveItem(DBTableType tableType, Map<String, dynamic> item) async {
    var response = await _socket
        .sendAndWait(Message("Write", data: IDBOperationObject(table: tableType.name, data: item)));
    return response.success;
  }

  Future<bool> saveInventoryItem(DBTableType tableType, InventoryItem item) async {
    if (!_socket.isConnected) return false;
    final _utils = UtilsService();
    Map<String, dynamic>? overridenItem;
    InventoryItem? originItem;
    try {
      if (tableType == DBTableType.masterItem) {
        return await _saveItem(tableType, item.toJson());
      }

      //check if there is an origin id. if yes then get the origin item
      if (item.originId != null) {
        originItem = await _getOriginItem(item.originId!);
      } else {
        //if not, create new master item
        originItem = InventoryItem(
            id: _utils.uid(),
            image: item.image,
            name: item.name,
            code: item.code,
            cost: item.cost,
            tags: item.tags);
      }

      if (originItem == null) return false;

      overridenItem = await overrideOriginItem(item.toJson(), originItem.toJson());

      // save master item
      var result1 = await _saveItem(DBTableType.masterItem, originItem.toJson());

      //save overriden item
      var result2 = await _saveItem(tableType, overridenItem);
      return result1 && result2;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Map<String, dynamic>> overrideOriginItem(
      Map<String, dynamic> newItem, Map<String, dynamic> originItem) async {
    const List<String> propertiesToCompare = ['name', 'cost', 'code', 'tags', 'image'];

    for (var key in propertiesToCompare) {
      if (key == 'tags') {
        var isSame = _compareLists(newItem[key], originItem[key]);
        if (isSame) {
          newItem.remove(key);
        }
      } else if (newItem[key] == originItem[key]) {
        newItem.remove(key);
      } else {
        print(
            'Key name: $key, Keys Value: New: ${newItem[key]}, Old: ${originItem[key]}, Value type: New: ${newItem[key].runtimeType}, Old: ${originItem[key].runtimeType}');
      }
    }

    newItem['originId'] = originItem['id'];
    return deleteNullKeys(newItem);
  }

  Map<String, dynamic> deleteNullKeys(Map<String, dynamic> item) {
    return item..removeWhere((key, value) => value == null);
  }

  bool _compareLists(List? list1, List? list2) {
    if (list1 == null || list2 == null) {
      return list1 == list2;
    }
    if (list1.length != list2.length) {
      return false;
    }
    return list1.toSet().containsAll(list2.toSet()) && list2.toSet().containsAll(list1.toSet());
  }

  Future<InventoryItem?> _getOriginItem(String originId) async {
    if (_socket.isConnected) {
      var response = await _socket.sendAndWait(Message('Read',
          data: IDBOperationObject(
              table: DBTableType.masterItem.name,
              options: IDBReadOptions(where: {'id': originId}, firstOnly: true))));

      if (response.success) {
        return InventoryItem.fromJson(response.data);
      }
    }
    return null;
  }

  Future<bool> updateInventoryItem(String tableName, Map<String, dynamic> updates) async {
    if (!_socket.isConnected) {
      return false;
    }
    var response = await _socket
        .sendAndWait(Message("Write", data: IDBOperationObject(table: tableName, data: updates)));
    return response.success;
  }

  Future<InventoryItem?> resetInventoryItem(
      DBItemType tableName, Map<String, dynamic> updates) async {
    if (!_socket.isConnected) return null;
    //update inventory item
    var isSuccess = await updateInventoryItem(tableName.name, updates);
    if (!isSuccess) return null;
    //update state
    return await _getInventoryItem(updates['id'], tableName);
  }

  Future<bool> deleteInventoryItem(String tableName,
      {String? id, Map<String, dynamic>? params}) async {
    if (!_socket.isConnected) return false;
    //get the item to be deleted first
    var readResponse = await _socket.sendAndWait(Message('Read',
        data: IDBOperationObject(
            table: tableName, options: IDBReadOptions(id: id, firstOnly: true))));
    if (!readResponse.success) return false;
    //save it to the deleted item table
    var writeResponse = await _socket.sendAndWait(Message("Write",
        data: IDBOperationObject(table: DBTableType.deletedItem.name, data: readResponse.data)));
    if (!writeResponse.success) return false;
    //delete the item from the table
    var deleteResponse = params != null
        ? await _socket
            .sendAndWait(Message('DeleteWhere', data: {'table': tableName, 'params': params}))
        : await _socket.sendAndWait(Message("Delete", data: {'table': tableName, 'id': id}));
    return deleteResponse.success;
  }

  Future<bool> deleteMasterItem(String id) async {
    if (!_socket.isConnected) return false;
    try {
      var isSuccess = await deleteInventoryItem(DBItemType.masterItem.name, id: id);
      if (!isSuccess) return false;
      return await findAndDeleteChildItems(id);
    } catch (e) {
      return false;
    }
  }

  Future<bool> findAndDeleteChildItems(String originId) async {
    try {
      for (var type in DBItemType.values) {
        if (type == DBItemType.masterItem) continue;
        var response = await _socket.sendAndWait(Message('Read',
            data: IDBOperationObject(
                table: type.name, options: IDBReadOptions(where: {'origin_id': originId}))));
        if (response.data != null) {
          var items = List.from(response.data).map((e) => ItemTemplate.fromJson(e)).toList();
          for (var item in items) {
            await deleteInventoryItem(type.name, id: item.id);
          }
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateItemCode(String code) async {
    if (!_socket.isConnected) return false;
    var response = await _socket.sendAndWait(Message('Read',
        data: IDBOperationObject(
            table: DBTableType.masterItem.name,
            options: IDBReadOptions(where: {'code': code}, firstOnly: true))));
    return response.data == null;
  }

  List<String> getOriginIds(List<InventoryItem> items) {
    List<String> originIds = [];
    for (var item in items) {
      if (item.originId != null || item.originId!.isNotEmpty) {
        originIds.add(item.originId!);
      } else {
        originIds.add(item.id);
      }
    }
    return originIds;
  }
}
