import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/presentation/dialogs/item_form_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';
import 'package:lm_teams_app/services/helpers/update_getter.dart';
import 'package:lm_teams_app/services/items_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../../../logic/blocs/home_screen_bloc.dart';
import '../../dialogs/confirmation_dialog.dart';
import '../../dialogs/item_picker_dialog.dart';

class TeamInventoryTabView extends StatefulWidget {
  const TeamInventoryTabView({Key? key, required this.team}) : super(key: key);

  final Team team;
  @override
  State<TeamInventoryTabView> createState() => _TeamInventoryTabViewState();
}

class _TeamInventoryTabViewState extends State<TeamInventoryTabView> {
  final _socketService = WebSocketService();
  final _itemService = ItemService();
  final List<Map<String, dynamic>> _dropDownItems = [
    {'value': 0, 'label': 'Edit Item'},
    {'value': 1, 'label': 'Delete Item'}
  ];
  List<InventoryItem> items = [];

  @override
  void initState() {
    getTeamItems();
    super.initState();
  }

  getTeamItems() async {
    var _items = await _itemService.getInventoryItems(IReadItemContext(teamId: widget.team.id));
    if (mounted) {
      setState(() {
        items = _items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _itemService = ItemService();
    final user = context.read<UserBloc>().state.user;
    final homeState = context.read<HomeScreenBloc>().state;

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton:
            BlocBuilder<ConnectivityBloc, ConnectivityState>(builder: (context, connectivityState) {
          return IconAndTextButton(
              icon: Icons.library_add_outlined,
              buttonName: 'ITEM',
              onPressed: connectivityState is ConnectedState
                  ? () async {
                      //get the item
                      InventoryItem? item = await showItemPickerDialog(
                          context: context,
                          items: await _itemService.getItemsForItemPicker(
                              user.id, widget.team.id, homeState.event.id),
                          pickedItemCodes: items.map((e) => e.code).toList());

                      //return if no created/overriden item
                      if (item == null) return;

                      //save user item
                      item.teamId = widget.team.id;
                      showLoaderDialog(context, loadingText: 'Saving team item...');
                      var isSuccess =
                          await _itemService.saveInventoryItem(DBTableType.teamItem, item);

                      if (isSuccess) {
                        setState(() {
                          items.add(item);
                        });
                      }

                      Navigator.pop(context);
                      showAppSnackbar(context,
                          isSuccess ? 'Team item added successfully' : 'Failed to add team item',
                          isError: !isSuccess);
                    }
                  : null);
        }),
        body: Container(
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(20.0.spMin),
                    child: Column(mainAxisSize: MainAxisSize.max, children: [
                      const SubtitleInDivider(subtitle: 'INVENTORY'),
                      Visibility(
                          visible: items.isNotEmpty,
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            ListView.builder(
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return InventoryItemListTile(
                                      item: items[index],
                                      trailing: PopupMenuButton(
                                          icon: Icon(Icons.more_vert, size: 24.0.spMin),
                                          itemBuilder: (context) {
                                            return _dropDownItems
                                                .map((item) => PopupMenuItem(
                                                    value: item['value'],
                                                    child: Text(item['label'])))
                                                .toList();
                                          },
                                          onSelected: (value) async {
                                            if (value == null) return;
                                            if (!_socketService.isConnected) {
                                              showAppSnackbar(context, 'Not connected to server',
                                                  isError: true);
                                              return;
                                            }
                                            switch (value) {
                                              case 0:
                                                var _item = await showItemFormDialog(context,
                                                    item: items[index], isEditing: true);
                                                if (_item != null) {
                                                  if (_item == items[index]) {
                                                    showAppSnackbar(
                                                        context, 'No changes have been made',
                                                        isError: true);
                                                    return;
                                                  }
                                                  showLoaderDialog(context,
                                                      loadingText: 'Updating personal item...');

                                                  Map<String, dynamic> _updates = GetItemUpdates(
                                                          originalItem: items[index],
                                                          updatedItem: _item)
                                                      .run();

                                                  var isSuccess =
                                                      await _itemService.updateInventoryItem(
                                                          DBTableType.teamItem.name, _updates);

                                                  setState(() {
                                                    items[index] = _item;
                                                  });

                                                  Navigator.pop(context);

                                                  showAppSnackbar(
                                                      context,
                                                      isSuccess
                                                          ? 'Personal item updated successfully'
                                                          : 'Failed to update personal item',
                                                      isError: !isSuccess);
                                                }
                                                break;
                                              case 1:
                                                var proceedDelete = await showDeleteConfirmation(
                                                    context,
                                                    'Delete Personal Item',
                                                    'Are you sure you want to delete this item?');

                                                if (!proceedDelete) return;
                                                var isDeleted = await _itemService
                                                    .deleteInventoryItem(DBTableType.teamItem.name,
                                                        id: items[index].id);
                                                if (isDeleted) {
                                                  setState(() {
                                                    items.removeWhere(
                                                        (obj) => obj.id == items[index].id);
                                                  });
                                                }

                                                showAppSnackbar(
                                                    context,
                                                    isDeleted
                                                        ? 'Item deleted successfully'
                                                        : 'Failed to delete item',
                                                    isError: !isDeleted);
                                                break;
                                            }
                                          }));
                                })
                          ]))
                    ])))));
  }
}
