import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/logic/cubits/master_inventory_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/confirmation_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/item_form_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/screens/empty_list_screen.dart';
import 'package:lm_teams_app/presentation/screens/master%20inventory%20screen/master_item_view.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import '../../../services/web_socket_service.dart';
import '../../widgets/list_tiles.dart';

class MasterInventoryPage extends StatefulWidget {
  const MasterInventoryPage({Key? key}) : super(key: key);

  @override
  State<MasterInventoryPage> createState() => _MasterInventoryPageState();
}

class _MasterInventoryPageState extends State<MasterInventoryPage> {
  final _controller = TextEditingController();

  final List<Map<String, dynamic>> _itemOptions = [
    {'value': 0, 'label': 'Edit Item'},
    {'value': 1, 'label': 'Delete Item'}
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MasterInventoryCubit()..getMasterItems(),
        child: BlocBuilder<MasterInventoryCubit, MasterInventoryState>(builder: (context, state) {
          var isSearching = state.isSearching ?? false;
          var items = isSearching ? state.filteredItems : state.items;

          void _onSearchQueryChange(String text) {
            if (text.isNotEmpty) {
              BlocProvider.of<MasterInventoryCubit>(context).searchStatusChanged(true);
              BlocProvider.of<MasterInventoryCubit>(context).searchItem(text);
            } else {
              BlocProvider.of<MasterInventoryCubit>(context).searchStatusChanged(false);
            }
          }

          void _clearSearchInput() {
            _controller.clear();
            BlocProvider.of<MasterInventoryCubit>(context).searchStatusChanged(false);
          }

          return AppFrame(
              title: "Master Inventory",
              floatingActionButton: BlocBuilder<ConnectivityBloc, ConnectivityState>(
                  builder: (context, connectivityState) {
                return IconAndTextButton(
                    icon: Icons.library_add_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                    buttonName: "MASTER ITEM",
                    onPressed:
                        connectivityState is ConnectedState ? () => _addMasterItem(context) : null);
              }),
              content: Visibility(
                visible: state.items.isNotEmpty,
                replacement: const EmptyListScreen(
                    text: 'No master item found', assetName: 'assets/logo/no_books.png'),
                child: Column(children: [
                  GenericSearchBar(
                      onchanged: _onSearchQueryChange,
                      controller: _controller,
                      icon: isSearching ? const Icon(Icons.close) : const Icon(Icons.search),
                      onpressed: () {
                        if (isSearching) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _clearSearchInput();
                        }
                      }),
                  DividerWithText(
                      title:
                          "M A S T E R   I T E M S  [ ${isSearching ? state.filteredItems.length : state.items.length} ]"),
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
                                                    child: Text(option['label']));
                                              }).toList();
                                            },
                                            onSelected: (value) =>
                                                _onActionSelected(context, value, index, items))),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MasterItemView(item: items[index])));
                                    });
                              })))
                ]),
              ));
        }));
  }
}

void _addMasterItem(BuildContext context) async {
  var item = await showItemFormDialog(context, isMasterItem: true);
  if (item != null) {
    showLoaderDialog(context, loadingText: 'Saving master item...');
    var isSuccess = await BlocProvider.of<MasterInventoryCubit>(context).saveMasterItem(item);
    Navigator.pop(context);
    if (isSuccess) {
      showAppSnackbar(context, 'Master item added successfully');
    } else {
      showAppSnackbar(context, 'Failed to add master item', isError: true);
    }
  }
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
      var item = await showItemFormDialog(context,
          item: items[index], isMasterItem: true, isEditing: true);

      if (item != null) {
        if (item == items[index]) {
          showAppSnackbar(context, 'No changes have been made', isError: true);
          return;
        }
        showLoaderDialog(context, loadingText: 'Updating master item...');
        var isSuccess = await BlocProvider.of<MasterInventoryCubit>(context)
            .updateMasterItem(items[index], item);

        Navigator.pop(context);

        showAppSnackbar(context,
            isSuccess ? 'Master item updated successfully' : 'Failed to update master item',
            isError: !isSuccess);
      }
      break;
    case 1:
      var proceedDelete = await showDeleteConfirmation(
          context, 'Delete Master Item', 'Are you sure you want to delete this item?');

      if (proceedDelete) {
        var isDeleted =
            await BlocProvider.of<MasterInventoryCubit>(context).deleteMasterItem(items[index]);

        showAppSnackbar(context,
            isDeleted ? 'Master item deleted successfully' : 'Failed to delete master item',
            isError: !isDeleted);
      }
      break;
  }
}
