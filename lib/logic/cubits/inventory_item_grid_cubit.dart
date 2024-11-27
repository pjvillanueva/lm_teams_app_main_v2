import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/services/items_service.dart';

class InventoryItemGridState extends Equatable {
  const InventoryItemGridState({
    required this.items,
  });

  final List<InventoryItem> items;

  InventoryItemGridState copyWith({
    List<InventoryItem>? items,
  }) {
    return InventoryItemGridState(
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [items];

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> itemMaps = items.map((e) => e.toJson()).toList();
    return {
      'inventoryItems': itemMaps,
    };
  }

  InventoryItemGridState.fromJson(Map<String, dynamic> json)
      : items = List.from(json['inventoryItems']).map((e) => InventoryItem.fromJson(e)).toList();
}

class InventoryItemGridCubit extends HydratedCubit<InventoryItemGridState> {
  InventoryItemGridCubit() : super(const InventoryItemGridState(items: []));
  final _itemService = ItemService();

  getInventoryItems(IReadItemContext context) async {
    var _items = await _itemService.getInventoryItems(context);
    emit(state.copyWith(items: _items));
  }

  @override
  fromJson(Map<String, dynamic> json) {
    return InventoryItemGridState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(InventoryItemGridState state) {
    return state.toJson();
  }
}
