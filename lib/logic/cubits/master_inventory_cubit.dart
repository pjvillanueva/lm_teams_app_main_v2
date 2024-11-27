import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/services/helpers/update_getter.dart';
import 'package:lm_teams_app/services/items_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

// ignore: must_be_immutable
class MasterInventoryState extends Equatable {
  MasterInventoryState(
      {required this.items,
      required this.filteredItems,
      this.isLoading = false,
      this.isSearching = false});
  final List<InventoryItem> items;
  final List<InventoryItem> filteredItems;
  bool? isSearching;
  bool? isLoading;

  MasterInventoryState copyWith(
      {List<InventoryItem>? items,
      List<InventoryItem>? filteredItems,
      bool? isSearching,
      bool? isLoading}) {
    return MasterInventoryState(
        items: items ?? this.items,
        filteredItems: filteredItems ?? this.filteredItems,
        isSearching: isSearching ?? this.isSearching,
        isLoading: isLoading ?? this.isLoading);
  }

  Map<String, dynamic> toJson() => {'masterItems': items, 'filteredMasterItems': filteredItems};

  MasterInventoryState.fromJson(Map<String, dynamic> json)
      : items = List.from(json['masterItems']).map((e) => InventoryItem.fromJson(e)).toList(),
        filteredItems =
            List.from(json['filteredMasterItems']).map((e) => InventoryItem.fromJson(e)).toList(),
        isLoading = json['isLoadingMasterInventory'];

  @override
  List<Object?> get props => [items, filteredItems, isSearching, isLoading];

  @override
  String toString() => "MasterInventory {items : $items}";
}

class MasterInventoryCubit extends HydratedCubit<MasterInventoryState> {
  MasterInventoryCubit() : super(MasterInventoryState(items: const [], filteredItems: const []));
  final _itemService = ItemService();
  final _socketService = WebSocketService();

  //get master items from db and update state
  Future<void> getMasterItems() async {
    if (_socketService.isConnected && !isClosed) {
      final items = await _itemService.getMasterItems();
      items.sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(items: items));
    }
  }

  //save master item in db and update state
  Future<bool> saveMasterItem(InventoryItem item) async {
    if (!_socketService.isConnected) return false;
    var _isSuccess = await _itemService.saveInventoryItem(DBTableType.masterItem, item);
    if (_isSuccess) {
      _addItem(item);
    }
    return _isSuccess;
  }

  //delete master item from db and update state
  Future<bool> deleteMasterItem(InventoryItem item) async {
    if (!_socketService.isConnected) return false;
    var _isDeleted = await _itemService.deleteMasterItem(item.id);
    if (_isDeleted) {
      _removeMasterItem(item);
    }
    return _isDeleted;
  }

//update master item in db and update state
  Future<bool> updateMasterItem(InventoryItem item, InventoryItem updatedItem) async {
    if (!_socketService.isConnected) return false;
    Map<String, dynamic> _updates =
        GetItemUpdates(originalItem: item, updatedItem: updatedItem).run();
    var _isUpdated = await _itemService.updateInventoryItem(DBTableType.masterItem.name, _updates);
    if (_isUpdated) {
      _updateMasterItem(updatedItem);
    }
    return _isUpdated;
  }

// add item to items state
  void _addItem(InventoryItem item) async {
    emit(state.copyWith(
        items: [...state.items]
          ..add(item)
          ..sort((a, b) => a.name.compareTo(b.name))));
  }

  //remove item from items state
  void _removeMasterItem(InventoryItem item) {
    emit(state.copyWith(
        items: [...state.items]..remove(item),
        filteredItems: [...state.filteredItems]..remove(item)));
  }

  //update item in items state
  void _updateMasterItem(InventoryItem item) {
    final index = state.items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      final updatedItems = [...state.items]
        ..removeAt(index)
        ..insert(index, item)
        ..sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(items: updatedItems));
    }
    if (state.isSearching ?? false) {
      _updateFilteredItems(item);
    }
  }

//update item in search result while searching
  void _updateFilteredItems(InventoryItem item) {
    final filteredIndex = state.filteredItems.indexWhere((element) => element.id == item.id);
    if (filteredIndex != -1) {
      final updatedFilteredItems = [...state.filteredItems]
        ..removeAt(filteredIndex)
        ..insert(filteredIndex, item)
        ..sort((a, b) => a.name.compareTo(b.name));
      emit(state.copyWith(filteredItems: updatedFilteredItems));
    }
  }

  //toggle search status
  searchStatusChanged(bool status) async {
    if (!status) {
      emit(state.copyWith(filteredItems: null));
    }
    emit(state.copyWith(isSearching: status));
  }

  //filter items based on search text
  searchItem(String name) {
    var items = state.items;
    var filteredItems = items
        .where((element) => element.name.toLowerCase().startsWith(name.toLowerCase()))
        .toList();
    emit(state.copyWith(filteredItems: filteredItems));
  }

  @override
  fromJson(Map<String, dynamic> json) {
    return MasterInventoryState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(state) {
    return state.toJson();
  }
}
