import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/services/helpers/update_getter.dart';
import 'package:lm_teams_app/services/items_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../../data/constants/constants.dart';

// ignore: must_be_immutable
class UserInventoryState extends Equatable {
  UserInventoryState({
    required this.items,
    required this.filteredItems,
    this.isSearching = false,
    this.isLoading = false,
  });
  final List<InventoryItem> items;
  final List<InventoryItem> filteredItems;
  bool? isSearching;
  bool? isLoading;

  UserInventoryState copyWith(
      {List<InventoryItem>? items,
      List<InventoryItem>? filteredItems,
      bool? isSearching,
      bool? isLoading}) {
    return UserInventoryState(
        items: items ?? this.items,
        filteredItems: filteredItems ?? this.filteredItems,
        isSearching: isSearching ?? this.isSearching,
        isLoading: isLoading ?? this.isLoading);
  }

  //get originIds
  List<String> get originIds {
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

  List<String> get itemCodes {
    return items.map((item) => item.code).toList();
  }

  Map<String, dynamic> toJson() => {
        'userItems': items,
        'filteredUserItems': filteredItems,
      };

  UserInventoryState.fromJson(Map<String, dynamic> json)
      : items = List.from(json['userItems']).map((e) => InventoryItem.fromJson(e)).toList(),
        filteredItems =
            List.from(json['filteredUserItems']).map((e) => InventoryItem.fromJson(e)).toList();

  @override
  List<Object?> get props => [items, filteredItems, isSearching, isLoading];

  @override
  String toString() =>
      "User Inventory State : items:  $items, filteredItems: $filteredItems, isSearching: $isSearching, isLoading: $isLoading";
}

class UserInventoryCubit extends HydratedCubit<UserInventoryState> {
  UserInventoryCubit()
      : super(UserInventoryState(
            items: const [], filteredItems: const [], isSearching: false, isLoading: false));
  final _itemService = ItemService();
  final _socketService = WebSocketService();

  //get user items from db and update state
  Future<void> getUserItems(String userID) async {
    if (_socketService.isConnected && !isClosed) {
      List<InventoryItem> _items =
          await _itemService.getInventoryItems(IReadItemContext(userId: userID));
      _items.sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(items: _items));
    }
  }

  //save user item to db and update state
  Future<bool> saveUserItem(InventoryItem item) async {
    if (!_socketService.isConnected) return false;
    var _isSuccess = await _itemService.saveInventoryItem(DBTableType.userItem, item);
    if (_isSuccess) {
      _addItem(item);
    }
    return _isSuccess;
  }

  //delete user item from db and update state
  Future<bool> deleteUserItem(InventoryItem item) async {
    if (!_socketService.isConnected) return false;
    var _isDeleted = await _itemService.deleteInventoryItem(DBTableType.userItem.name, id: item.id);
    if (_isDeleted) {
      _removeUserItem(item);
    }
    return _isDeleted;
  }

  //update user item in db and update state
  Future<bool> updateUserItem(InventoryItem item, InventoryItem updatedItem) async {
    if (!_socketService.isConnected) return false;
    Map<String, dynamic> _updates =
        GetItemUpdates(originalItem: item, updatedItem: updatedItem).run();

    var _isUpdated = await _itemService.updateInventoryItem(DBTableType.userItem.name, _updates);

    if (_isUpdated) {
      _updateUserItem(updatedItem);
    }
    return _isUpdated;
  }

  //reset user item
  Future<bool> resetUserItem(InventoryItem item) async {
    if (!_socketService.isConnected) return false;
    Map<String, dynamic> _updates = GetItemResetUpdates(itemToReset: item).run();

    var resettedItem = await _itemService.resetInventoryItem(DBItemType.userItem, _updates);
    if (resettedItem != null) {
      _updateUserItem(resettedItem);
      return true;
    } else {
      return false;
    }
  }

  // add item to items state
  void _addItem(InventoryItem item) async {
    emit(state.copyWith(
        items: [...state.items]
          ..add(item)
          ..sort((a, b) => a.name.compareTo(b.name))));

    if (state.isSearching ?? false) {
      emit(state.copyWith(
          filteredItems: [...state.filteredItems]
            ..add(item)
            ..sort((a, b) => a.name.compareTo(b.name))));
    }
  }

  //remove item from items state
  void _removeUserItem(InventoryItem item) {
    emit(state.copyWith(
        items: [...state.items]..remove(item),
        filteredItems: [...state.filteredItems]..remove(item)));
  }

  //update item in items state
  void _updateUserItem(InventoryItem item) {
    final index = state.items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      final updatedItems = [...state.items]
        ..removeAt(index)
        ..insert(index, item)
        ..sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(
        items: updatedItems,
        filteredItems: state.isSearching ?? false ? updatedItems : state.filteredItems,
      ));
    }
  }

  searchStatusChanged(bool status) async {
    if (!status) {
      emit(state.copyWith(filteredItems: null));
    }
    emit(state.copyWith(isSearching: status));
  }

  searchItem(String name) {
    var items = state.items;

    var filteredItems = items
        .where((element) => element.name.toLowerCase().startsWith(name.toLowerCase()))
        .toList();
    emit(state.copyWith(filteredItems: filteredItems));
  }

  @override
  UserInventoryState? fromJson(Map<String, dynamic> json) {
    return UserInventoryState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(UserInventoryState state) {
    return state.toJson();
  }
}
