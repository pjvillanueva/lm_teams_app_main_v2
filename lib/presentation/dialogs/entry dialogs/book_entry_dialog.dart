import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/entry_history_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import '../../../data/models/entry model/entry_data_model.dart';
import '../../../data/models/entry model/entry_model.dart';
import '../../../data/models/location model/location_event.dart';
import '../../../services/items_service.dart';
import '../../widgets/buttons.dart';
import '../item_picker_dialog.dart';
import 'money_entry_dialog.dart';

showBookEntryDialog(BuildContext context, EntryDialogMode mode,
    {Entry? entry,
    int? historyObjectIndex,
    LocationEvent? locationEvent,
    String? teamID,
    String? eventID}) {
  bool isLoading = false;

  return showDialog(
      context: context,
      builder: (_) {
        var data = entry?.data as BookEntryData;
        final _itemService = ItemService();
        final _quantityController = TextEditingController(text: data.quantity.toString());
        final _user = context.read<UserBloc>().state.user;
        final _screenWidth = MediaQuery.of(context).size.width;

        return StatefulBuilder(builder: (statefulContext, setState) {
          return AppDialog(
              title: mode == EntryDialogMode.edit ? 'Edit Book Entry' : 'Book Entry',
              contents: [
                SizedBox(height: 20.0.spMin),
                Visibility(
                    visible: mode != EntryDialogMode.view,
                    child: Column(children: [
                      ListTile(
                          title: Text(data.item?.name ?? ''),
                          leading: Avatar(
                              size: Size(_screenWidth / 9.spMin, 100.spMin),
                              image: data.item?.image,
                              placeholder: Text(data.item?.code ?? '',
                                  style: TextStyle(fontSize: 20.spMin))),
                          trailing: IconButton(
                              icon: Icon(Icons.edit,
                                  size: 24.0.spMin, color: Theme.of(context).colorScheme.onSurface),
                              onPressed: () async {
                                var item = await showItemPickerDialog(
                                    title: 'Select replacement item',
                                    context: context,
                                    hideCreateButton: true,
                                    items: await _itemService.getItemsForItemPicker(
                                        _user.id, teamID ?? '', eventID ?? '',
                                        includeMasterItems: false),
                                    returnUneditedItem: true,
                                    pickedItemCodes: [data.item?.code ?? '']);

                                if (item != null) {
                                  setState(() {
                                    data = BookEntryData(
                                        itemID: item.id,
                                        item: item,
                                        quantity: int.parse(_quantityController.text));
                                  });
                                }
                              })),
                      SizedBox(height: 10.0.spMin),
                      Row(children: [
                        SizedBox(width: 15.0.spMin),
                        Text('Quantity', style: TextStyle(fontSize: 16.0.spMin)),
                        const Spacer(),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          IconButton(
                              icon: const Icon(Icons.arrow_left),
                              onPressed: () {
                                //decrease quantity
                                var quantity = int.parse(_quantityController.text);
                                if (quantity != 1) {
                                  setState(() {
                                    _quantityController.text = (quantity - 1).toString();
                                  });
                                }
                              }),
                          SizedBox(width: 10.spMin),
                          Text(_quantityController.text, style: TextStyle(fontSize: 20.0.spMin)),
                          SizedBox(width: 10.spMin),
                          IconButton(
                              icon: const Icon(Icons.arrow_right),
                              onPressed: () {
                                //increase quantity
                                var quantity = int.parse(_quantityController.text);
                                if (quantity != 100) {
                                  setState(() {
                                    _quantityController.text = (quantity + 1).toString();
                                  });
                                }
                              })
                        ])
                      ]),
                      SizedBox(height: 20.0.spMin),
                      const AddCurrentLocationButton(visible: false),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel",
                                style: TextStyle(
                                    fontSize: 16.0.spMin,
                                    color: Theme.of(context).colorScheme.onSurface))),
                        SizedBox(width: 14.0.spMin),
                        AppElevatedButton(
                            child: isLoading
                                ? SizedBox(
                                    child: CircularProgressIndicator(strokeWidth: 4.0.spMin),
                                    height: 20.0.spMin,
                                    width: 20.0.spMin)
                                : Text("Save",
                                    style: TextStyle(fontSize: 16.0.spMin, color: Colors.white)),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    try {
                                      setState(() => isLoading = true);
                                      LocationEvent? _latestLocation;

                                      var _updateData = BookEntryData(
                                          itemID: data.itemID,
                                          quantity: int.parse(_quantityController.text),
                                          item: data.item);

                                      if (entry != null) {
                                        context.read<EntryHistoryCubit>().updateEntry(
                                            entry.updated(_updateData,
                                                latestLocation: _latestLocation),
                                            _updateData,
                                            historyObjectIndex!);
                                      }
                                      Navigator.pop(context);
                                    } catch (e) {
                                      print('Book Entry Dialog Error: $e');
                                    }
                                  })
                      ])
                    ]),
                    replacement: Column(children: [
                      ListTile(
                          title: Text(data.item?.name ?? ''),
                          leading: Avatar(
                              size: Size(_screenWidth / 9.spMin, 80.spMin),
                              image: data.item?.image,
                              placeholder: Text(data.item?.code ?? '',
                                  style: TextStyle(fontSize: 20.spMin))),
                          subtitle: Text('Quantity: ${data.quantity}')),
                      SizedBox(height: 10.0.spMin),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        OutlinedButton(
                            child: Text('Close',
                                style: TextStyle(
                                    fontSize: 16.0.spMin,
                                    color: Theme.of(context).colorScheme.onSurface)),
                            onPressed: () => Navigator.pop(context)),
                        SizedBox(width: 14.0.spMin),
                        AppElevatedButton(
                            child: const Text('Edit', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              setState(() => mode = EntryDialogMode.edit);
                            })
                      ])
                    ]))
              ]);
        });
      });
}
