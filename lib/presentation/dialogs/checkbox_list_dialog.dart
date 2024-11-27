import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import '../../data/models/image models/image_object.dart';

class CheckboxItemModel<T> {
  CheckboxItemModel({required this.payload, required this.label, this.image});
  final T payload;
  String label;
  ImageObject? image;
}

Future<List<T>?> showCheckboxListDialog<T>({
  required BuildContext context,
  required String title,
  required List<CheckboxItemModel<T>> allItems,
  required List<CheckboxItemModel<T>> selectedItems,
}) async {
  return await showDialog(
      context: context,
      builder: (context) {
        bool isSearching = false;
        final _controller = TextEditingController();
        List<CheckboxItem> items = itemToCheckboxItem(allItems, selectedItems);
        return StatefulBuilder(builder: (context, setState) {
          void searchItems(String query) {
            List<CheckboxItem> _items = [];
            if (query.isNotEmpty) {
              if (items.isNotEmpty) {
                _items = items.where((item) {
                  return item.label.toLowerCase().contains(query.toLowerCase());
                }).toList();
              }
              setState(() {
                items = _items;
              });
            } else {
              setState(() {
                items = itemToCheckboxItem(allItems, selectedItems);
              });
            }
          }

          return AppDialog(title: title, contents: [
            SizedBox(height: 20.0.spMin),
            SizedBox(
                width: double.maxFinite,
                child: Column(children: [
                  GenericSearchBar(
                      icon:
                          isSearching == true ? const Icon(Icons.close) : const Icon(Icons.search),
                      onchanged: (value) {
                        setState(() {
                          isSearching = value.isNotEmpty;
                        });
                        searchItems(value);
                      },
                      controller: _controller,
                      onpressed: () {
                        if (isSearching == true) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _controller.clear();
                          setState(() {
                            items = itemToCheckboxItem(allItems, selectedItems);
                            isSearching = false;
                          });
                        }
                      }),
                  Column(children: [
                    Container(
                        child: items != []
                            ? ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  CheckboxItem _item = items[index];
                                  return CheckboxListTile(
                                      title: Row(children: [
                                        _item.avatar,
                                        const SizedBox(width: 5),
                                        Flexible(
                                            child:
                                                Text(_item.label, overflow: TextOverflow.ellipsis))
                                      ]),
                                      activeColor: Theme.of(context).colorScheme.secondary,
                                      controlAffinity: ListTileControlAffinity.leading,
                                      value: _item.isChecked,
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _item.isChecked = value;
                                          });
                                        }
                                      });
                                })
                            : null),
                    Visibility(
                        visible: !isSearching,
                        child: CheckboxListTile(
                          title: const Text('Select all'),
                          activeColor: Theme.of(context).colorScheme.secondary,
                          value: isAllSelected(items),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                for (var item in items) {
                                  item.isChecked = value;
                                }
                              });
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ))
                  ]),
                  SizedBox(height: 15.0.spMin),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CANCEL", style: TextStyle(color: Colors.grey))),
                    TextButton(
                        onPressed: () {
                          List<T> _selectedItems = [];
                          for (var checkboxItem in items) {
                            if (checkboxItem.isChecked) {
                              _selectedItems.add(checkboxItem.item.payload);
                            }
                          }
                          Navigator.pop(context, _selectedItems);
                        },
                        child: Text("DONE",
                            style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
                  ])
                ]))
          ]);
        });
      });
}

bool isAllSelected(List<CheckboxItem> items) {
  for (var item in items) {
    if (!item.isChecked) {
      return false;
    }
  }
  return true;
}

class CheckboxItem {
  CheckboxItem(this.item, this.isChecked);
  final CheckboxItemModel item;
  bool isChecked;

  Widget get avatar {
    return Avatar(
        isCircle: true,
        image: item.image,
        size: Size(40.spMin, 40.spMin),
        placeholder: Text(item.label.characters.first.toUpperCase(),
            style: TextStyle(fontSize: 16.0.spMin)));
  }

  String get label => item.label;

  @override
  String toString() => "CheckboxItem: item: $item, isChecked: $isChecked";
}

List<CheckboxItem> itemToCheckboxItem(
    List<CheckboxItemModel> allItems, List<CheckboxItemModel> selectedItems) {
  List<CheckboxItem> items = [];

  for (var item in allItems) {
    bool selected = selectedItems.where((element) => element.payload == item.payload).isNotEmpty;
    items.add(CheckboxItem(item, selected));
  }

  return items;
}
