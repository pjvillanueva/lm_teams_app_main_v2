import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/event%20model/event.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';
import '../../../data/constants/constants.dart';
import '../../../data/models/inventory models/inventory_item.dart';
import '../../../logic/blocs/home_screen_bloc.dart';
import '../../../logic/blocs/user_bloc.dart';
import '../../../services/helpers/update_getter.dart';
import '../../../services/items_service.dart';
import '../../../services/web_socket_service.dart';
import '../../dialogs/confirmation_dialog.dart';
import '../../dialogs/item_form_dialog.dart';
import '../../dialogs/item_picker_dialog.dart';
import '../../dialogs/loading_dialog.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/texts.dart';

class EventInventoryTabView extends StatefulWidget {
  const EventInventoryTabView({required this.event, Key? key}) : super(key: key);

  final Event event;
  @override
  State<EventInventoryTabView> createState() => _EventInventoryTabViewState();
}

class _EventInventoryTabViewState extends State<EventInventoryTabView> {
  final _itemService = ItemService();
  final _socketService = WebSocketService();
  final List<Map<String, dynamic>> _dropDownItems = [
    {'value': 0, 'label': 'Edit Item'},
    {'value': 1, 'label': 'Delete Item'}
  ];
  List<InventoryItem> items = [];

  @override
  void initState() {
    getEventItems();
    super.initState();
  }

  getEventItems() async {
    var _items = await _itemService.getInventoryItems(IReadItemContext(eventId: widget.event.id));
    if (mounted) {
      setState(() {
        items = _items;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            user.id, widget.event.id, homeState.event.id),
                        pickedItemCodes: items.map((e) => e.code).toList(),
                      );

                      //return if no created/overriden item
                      if (item == null) return;

                      //save user item
                      item.eventId = widget.event.id;
                      showLoaderDialog(context, loadingText: 'Saving event item...');
                      var isSuccess =
                          await _itemService.saveInventoryItem(DBTableType.eventItem, item);

                      if (isSuccess) {
                        setState(() {
                          items.add(item);
                        });
                      }

                      Navigator.pop(context);
                      showAppSnackbar(context,
                          isSuccess ? 'Event item added successfully' : 'Failed to add event item',
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
                                                          DBTableType.eventItem.name, _updates);

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
                                                    '',
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
