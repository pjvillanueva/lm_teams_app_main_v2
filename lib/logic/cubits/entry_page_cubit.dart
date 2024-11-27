import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:lm_teams_app/logic/cubits/entry_history_cubit.dart';
import '../../data/models/entry model/entry_data_model.dart';
import '../../data/models/entry model/entry_model.dart';

class PickedUserItem {
  PickedUserItem({required this.item, required this.quantity});
  final InventoryItem item;
  int quantity;
}

class EntryPageState extends Equatable {
  const EntryPageState({
    required this.isHistoryOpen,
    required this.pickedItems,
  });
  final bool isHistoryOpen;
  final List<PickedUserItem> pickedItems;

  EntryPageState copyWith({
    bool? isHistoryOpen,
    List<PickedUserItem>? pickedItems,
  }) {
    return EntryPageState(
      isHistoryOpen: isHistoryOpen ?? this.isHistoryOpen,
      pickedItems: pickedItems ?? this.pickedItems,
    );
  }

  @override
  List<Object?> get props => [isHistoryOpen, pickedItems];
}

class EntryPageCubit extends Cubit<EntryPageState> {
  EntryPageCubit() : super(const EntryPageState(isHistoryOpen: false, pickedItems: []));

  changeIsHistoryOpen(bool isHistoryOpen) {
    emit(state.copyWith(isHistoryOpen: isHistoryOpen));
  }

  addToPickedItems(InventoryItem item) {
    var pickedItems = state.pickedItems;
    var filteredItems = pickedItems.where((userItem) => userItem.item.id == item.id);

    if (filteredItems.isNotEmpty) {
      var filteredItem = pickedItems.firstWhere((userItem) => userItem.item.id == item.id);

      var index = pickedItems.indexWhere((element) => element == filteredItem);

      var updatedItem =
          PickedUserItem(item: filteredItem.item, quantity: filteredItem.quantity + 1);

      emit(state.copyWith(
          pickedItems: [...pickedItems]
            ..remove(state.pickedItems[index])
            ..insert(index, updatedItem)));
    } else {
      var pickedItem = PickedUserItem(item: item, quantity: 1);
      emit(state.copyWith(pickedItems: [...state.pickedItems]..add(pickedItem)));
    }
  }

  clearPickedItems() {
    emit(state.copyWith(pickedItems: []));
  }

  submitBookEntry(
      BuildContext context, LocationEvent? locationEvent, String? teamID, String? eventID) {
    for (var element in state.pickedItems) {
      var bookEntryData =
          BookEntryData(itemID: element.item.id, quantity: element.quantity, item: element.item);

      context
          .read<EntryHistoryCubit>()
          .addEntry(EntryType.book, bookEntryData, teamID, eventID, locationEvent: locationEvent);
    }
    clearPickedItems();
  }
}
