import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/user_inventory_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/confirmation_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/item_form_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/screens/empty_list_screen.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../../../logic/blocs/home_screen_bloc.dart';
import '../../../services/items_service.dart';
import '../../dialogs/item_picker_dialog.dart';

class UserInventoryPage extends StatefulWidget {
  const UserInventoryPage({
    Key? key,
  }) : super(key: key);

  @override
  State<UserInventoryPage> createState() => _UserInventoryPageState();
}

class _UserInventoryPageState extends State<UserInventoryPage> {
  final _controller = TextEditingController();

  final List<Map<String, dynamic>> _itemOptions = [
    {'value': 0, 'label': 'Edit Item'},
    {'value': 1, 'label': 'Delete Item'},
    {'value': 2, 'label': 'Reset Item'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserBloc>().state.user;
    final homeState = context.read<HomeScreenBloc>().state;

    return BlocProvider(
        create: (context) => UserInventoryCubit()..getUserItems(user.id),
        child: BlocBuilder<UserInventoryCubit, UserInventoryState>(builder: (context, state) {
          var isSearching = state.isSearching ?? false;
          var items = isSearching ? state.filteredItems : state.items;

          void _onSearchQueryChange(String text) {
            if (text.isNotEmpty) {
              BlocProvider.of<UserInventoryCubit>(context).searchStatusChanged(true);
              BlocProvider.of<UserInventoryCubit>(context).searchItem(text);
            } else {
              BlocProvider.of<UserInventoryCubit>(context).searchStatusChanged(false);
            }
          }

          void _clearSearchInput() {
            _controller.clear();
            BlocProvider.of<UserInventoryCubit>(context).searchStatusChanged(false);
          }

          return AppFrame(
              title: "My Inventory",
              floatingActionButton: BlocBuilder<ConnectivityBloc, ConnectivityState>(
                  builder: (connectivityContext, connectivityState) {
                return IconAndTextButton(
                    icon: Icons.library_add_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                    buttonName: "ITEM",
                    onPressed: connectivityState is ConnectedState
                        ? () => _addUserItem(context, homeState, state, user.id)
                        : null);
              }),
              content: Visibility(
                visible: state.items.isNotEmpty,
                replacement: const EmptyListScreen(
                    text: "No item found", assetName: "assets/logo/no_books.png"),
                child: Column(children: [
                  GenericSearchBar(
                      onchanged: _onSearchQueryChange,
                      icon: isSearching ? const Icon(Icons.close) : const Icon(Icons.search),
                      controller: _controller,
                      onpressed: () {
                        if (isSearching) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _clearSearchInput();
                        }
                      }),
                  DividerWithText(
                      title:
                          "I T E M S  [ ${isSearching ? state.filteredItems.length : items.length} ]"),
                  Expanded(
                      child: Scrollbar(
                          child: ListView.builder(
                              itemCount: items.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, int index) {
                                return InventoryItemListTile(
                                    item: items[index],
                                    trailing: Visibility(
                                        visible: true,
                                        child: PopupMenuButton(
                                            icon: Icon(Icons.more_vert, size: 24.0.spMin),
                                            itemBuilder: (context) {
                                              return _itemOptions.map((option) {
                                                return PopupMenuItem(
                                                  value: option['value'],
                                                  child: Text(option['label']),
                                                );
                                              }).toList();
                                            },
                                            onSelected: (value) =>
                                                _onActionSelected(context, value, index, items))));
                              })))
                ]),
              ));
        }));
  }
}

void _addUserItem(BuildContext context, HomeScreenState homeState,
    UserInventoryState userInventoryState, String userId) async {
  InventoryItem? item;
  final _itemService = ItemService();

  //get the item
  item = await showItemPickerDialog(
      context: context,
      items:
          await _itemService.getItemsForItemPicker(userId, homeState.team.id, homeState.event.id),
      pickedItemCodes: context.read<UserInventoryCubit>().state.itemCodes);

  //return if no created/overriden item
  if (item == null) return;

  //save user item
  item.userId = userId;
  showLoaderDialog(context, loadingText: 'Saving user item...');
  var isSuccess = await BlocProvider.of<UserInventoryCubit>(context).saveUserItem(item);

  Navigator.pop(context);
  showAppSnackbar(context, isSuccess ? 'User item added successfully' : 'Failed to add user item',
      isError: !isSuccess);
}

void _onActionSelected(
    BuildContext context, Object? value, int index, List<InventoryItem> items) async {
  final _socket = WebSocketService();

  if (value == null) return;
  if (!_socket.isConnected) {
    showAppSnackbar(context, 'Not connected to server', isError: true);
    return;
  }

  switch (value) {
    case 0:
      var item = await showItemFormDialog(context, item: items[index], isEditing: true);
      if (item != null) {
        if (item.isEqualTo(items[index])) {
          showAppSnackbar(context, 'No changes have been made', isError: true);
          return;
        }

        showLoaderDialog(context, loadingText: 'Updating personal item...');

        var isSuccess =
            await BlocProvider.of<UserInventoryCubit>(context).updateUserItem(items[index], item);

        Navigator.pop(context);

        showAppSnackbar(context,
            isSuccess ? 'Personal item updated successfully' : 'Failed to update personal item',
            isError: !isSuccess);
      }
      break;
    case 1:
      var proceedDelete = await showDeleteConfirmation(
          context, 'Delete Personal Item', 'Are you sure you want to delete this item?');
      if (!proceedDelete) return;

      var isDeleted =
          await BlocProvider.of<UserInventoryCubit>(context).deleteUserItem(items[index]);

      showAppSnackbar(context, isDeleted ? 'Item deleted successfully' : 'Failed to delete item',
          isError: !isDeleted);
      break;
    case 2:
      if (!_socket.isConnected) {
        showAppSnackbar(context, 'Not connected to server', isError: true);
        return;
      }
      if (!await items[index].hasOverrides) {
        showAppSnackbar(context, 'No overrides to reset', isError: true);
        return;
      }

      var proceedReset = await showDeleteConfirmation(
          context, 'Reset Personal Item', 'Are you sure you want to reset this item?');
      if (!proceedReset) return;

      var resetSuccess =
          await BlocProvider.of<UserInventoryCubit>(context).resetUserItem(items[index]);
      showAppSnackbar(context, resetSuccess ? 'Item reset successfully' : 'Failed to reset item',
          isError: !resetSuccess);
      break;
  }
}
