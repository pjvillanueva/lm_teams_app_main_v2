import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/presentation/dialogs/item_form_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';

Future<InventoryItem?> showItemPickerDialog(
    {required BuildContext context,
    required List<InventoryItem> items,
    bool returnUneditedItem = false,
    List<String> pickedItemCodes = const [],
    String? title,
    bool? hideCreateButton}) async {
  return await showDialog<InventoryItem?>(
      context: context,
      builder: (BuildContext context) {
        return ItemPickerDialog(
          title: title,
          items: items,
          returnUneditedItem: returnUneditedItem,
          pickedItemCodes: pickedItemCodes,
          hideCreateButton: hideCreateButton,
        );
      });
}

// ignore: must_be_immutable
class ItemPickerDialog extends StatefulWidget {
  ItemPickerDialog(
      {Key? key,
      required this.items,
      required this.returnUneditedItem,
      required this.pickedItemCodes,
      this.title,
      this.hideCreateButton})
      : super(key: key);

  List<InventoryItem> items;
  bool returnUneditedItem;
  List<String> pickedItemCodes;
  String? title;
  bool? hideCreateButton;

  @override
  State<ItemPickerDialog> createState() => _ItemPickerDialogState();
}

class _ItemPickerDialogState extends State<ItemPickerDialog> {
  bool isSearching = false;
  final _searchController = TextEditingController();
  List<InventoryItem> items = [];
  List<InventoryItem> filteredItems = [];

  @override
  void initState() {
    items = widget.items;
    filteredItems = items;
    super.initState();
  }

  void searchItems(String query) {
    if (query.isNotEmpty) {
      setState(() {
        isSearching = true;
        filteredItems =
            items.where((item) => item.name.toLowerCase().contains(query.toLowerCase())).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
            height: 400.spMin,
            color: Theme.of(context).colorScheme.background,
            padding: EdgeInsets.all(20.0.spMin),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogTitle(title: widget.title ?? 'New Item'),
                  SizedBox(height: 20.0.spMin),
                  GenericSearchBar(
                      controller: _searchController,
                      icon:
                          isSearching == true ? const Icon(Icons.close) : const Icon(Icons.search),
                      onchanged: (query) {
                        searchItems(query);
                      },
                      onpressed: () {
                        if (isSearching == true) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _searchController.clear();
                          setState(() {
                            isSearching = false;
                            filteredItems = items;
                          });
                        }
                      }),
                  SizedBox(height: 10.0.spMin),
                  Expanded(
                      child: Scrollbar(
                          child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredItems.length,
                              separatorBuilder: (context, index) => SizedBox(height: 10.spMin),
                              itemBuilder: (context, int index) {
                                var _item = filteredItems[index];
                                return Visibility(
                                  visible: !widget.pickedItemCodes.contains(_item.code),
                                  child: ListTile(
                                      title: Text(_item.name),
                                      tileColor: Theme.of(context).colorScheme.surface,
                                      leading: Avatar(
                                          placeholder: Text(_item.code,
                                              style: TextStyle(fontSize: 14.0.spMin)),
                                          size: Size(30.spMin, 40.spMin),
                                          image: _item.image),
                                      minLeadingWidth: 20.0.spMin,
                                      onTap: () async {
                                        if (!widget.returnUneditedItem) {
                                          var item = await showItemFormDialog(context, item: _item);
                                          Navigator.pop(context, item);
                                        } else {
                                          Navigator.pop(context, _item);
                                        }
                                      }),
                                );
                              }))),
                  Visibility(
                    visible: widget.hideCreateButton != true,
                    child: ListTile(
                        leading: Icon(Icons.add, size: 30.0.spMin),
                        minLeadingWidth: 20.0.spMin,
                        title: Text(
                            'Create ${_searchController.text == '' ? 'New Item' : '"${_searchController.text}"'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16.0.spMin)),
                        tileColor: Theme.of(context).colorScheme.surface,
                        onTap: () async {
                          var _item = await showItemFormDialog(context);
                          Navigator.pop(context, _item);
                        }),
                  )
                ])));
  }
}
