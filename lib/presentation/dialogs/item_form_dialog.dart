//dialog with form for adding new item
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/logic/utility/defaults.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/image_options.dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/services/helpers/string_helpers.dart';
import 'package:lm_teams_app/services/items_service.dart';
import 'package:lm_teams_app/services/uploader_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import '../../data/models/image models/image_object.dart';
import 'item_tag_dialog.dart';

Future<InventoryItem?> showItemFormDialog(BuildContext context,
    {InventoryItem? item, bool isMasterItem = false, bool isEditing = false}) async {
  InventoryItem? _item = item;
  bool trackStock = false;
  bool _editMore = item == null;
  File? imageFile;
  final _validators = CustomValidators();
  final _utils = UtilsService();
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController(text: item?.name);
  final _itemCodeController = TextEditingController(text: item?.code);
  final _itemCostController = TextEditingController(text: item?.cost);
  final _itemQuantityController = TextEditingController(text: '0');
  List<String> _pickedTags = [...?_item?.tags];
  String? itemCodeErrorText;
  String? itemTagsErrorText;
  List<String> _unpickedTags = List.from(listOfTags.where((tag) => !_pickedTags.contains(tag)));
  final _itemService = ItemService();

  return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          var _connectivityState = context.read<ConnectivityBloc>().state;
          return AppDialog(title: _item == null ? 'New Item' : 'Edit Item', contents: [
            Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Visibility(
                      visible: _editMore,
                      child: Avatar(
                          image: _item?.image,
                          imageFile: imageFile,
                          borderWidth: 3.0,
                          placeholder:
                              Text(_item?.code ?? '', style: TextStyle(fontSize: 10.0.spMin)),
                          size: Size(120.spMin, 150.spMin),
                          onTapButton: () async {
                            File? _imageFile = imageFile ??
                                (_item?.image != null
                                    ? await _utils.urlToFile(_item!.image!.url)
                                    : null);

                            File? _newImageFile =
                                await showImageOptionsDialog(context, imageFile: _imageFile);
                            if (_newImageFile != null) {
                              setState(() {
                                imageFile = _newImageFile;
                              });
                            }
                          }),
                      replacement: Container(
                          color: Theme.of(context).colorScheme.surface,
                          height: 150.spMin,
                          padding: EdgeInsets.all(20.spMin),
                          child: Row(children: [
                            Flexible(
                                flex: 0,
                                child: Avatar(
                                    size: Size(50.spMin, 70.spMin),
                                    image: _item?.image,
                                    placeholder: Text(_item?.code ?? 'UN'))),
                            Flexible(
                                flex: 10,
                                child: ListTile(
                                    title: Text(_item?.name ?? ''),
                                    subtitle: Text(_item?.code ?? ''),
                                    trailing: IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          setState(() {
                                            _editMore = true;
                                          });
                                        })))
                          ]))),
                  SizedBox(height: 12.0.spMin, width: 500.spMin),
                  Divider(height: 1.0.spMin, thickness: 1.0.spMin),
                  SizedBox(height: 12.0.spMin),
                  Visibility(
                      visible: _editMore,
                      child: Column(children: [
                        AppOutlinedTextFormField(
                            labelText: 'Item Name',
                            hintText: "Type item name here",
                            controller: _itemNameController,
                            validator: _validators.emptyValidator),
                        SizedBox(height: 12.0.spMin),
                        AppOutlinedTextFormField(
                            labelText: 'Item Code',
                            hintText: "Type item code here",
                            controller: _itemCodeController,
                            textCapitalization: TextCapitalization.characters,
                            enable: _item == null,
                            errorText: itemCodeErrorText,
                            maxLength: 3,
                            validator: _validators.emptyValidator)
                      ])),
                  SizedBox(height: 12.0.spMin),
                  AppOutlinedTextFormField(
                      labelText: 'Cost Price',
                      hintText: "Type cost price here",
                      maxLength: 7,
                      keyboardType: TextInputType.number,
                      controller: _itemCostController,
                      validator: _validators.emptyValidator),
                  SizedBox(height: 12.0.spMin),
                  // Visibility(
                  //     visible: !isMasterItem && _editMore,
                  //     child: Column(children: [
                  //       SwitchButtonFormField(
                  //           labelText: "Track Stock",
                  //           trackStock: trackStock,
                  //           onChanged: (value) {
                  //             setState(() {
                  //               trackStock = value;
                  //             });
                  //           }),
                  //       SizedBox(height: 12.0.spMin)
                  //     ])),
                  // Visibility(
                  //     visible: trackStock,
                  //     child: Column(children: [
                  //       GenericNumberInput(
                  //           controller: _itemQuantityController,
                  //           labelText: "Quantity",
                  //           isDouble: false),
                  //       SizedBox(height: 12.0.spMin)
                  //     ])),
                  Visibility(
                      visible: _editMore,
                      child: Column(children: [
                        TagsInputField(
                            allTags: _unpickedTags,
                            pickedTags: _pickedTags,
                            errorText: itemTagsErrorText,
                            onTap: () async {
                              if (_unpickedTags.isNotEmpty) {
                                var selectedTag = await showItemTagDialog(context, _unpickedTags);

                                if (selectedTag != null) {
                                  setState(() {
                                    _pickedTags.add(selectedTag);
                                    _unpickedTags.remove(selectedTag);
                                  });
                                }
                              }
                            })
                      ])),
                  SizedBox(height: 12.0.spMin),
                  FullWidthButton(
                      title: 'SAVE ITEM',
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: _connectivityState is ConnectedState
                          ? () async {
                              //validate item details
                              showLoaderDialog(context, loadingText: 'Validating item details...');
                              if (!_formKey.currentState!.validate()) {
                                Navigator.pop(context);
                                return;
                              }
                              if (_pickedTags.isEmpty) {
                                setState(() {
                                  itemTagsErrorText = 'Please select at least one tag';
                                });
                                Navigator.pop(context);
                                return;
                              }
                              if (item == null &&
                                  !await _itemService.validateItemCode(_itemCodeController.text)) {
                                setState(() {
                                  itemCodeErrorText = 'Item code already exists';
                                });
                                Navigator.pop(context);
                                return;
                              }
                              //Upload image
                              var _imageObject = await uploadImage(context, imageFile);

                              _item = InventoryItem(
                                  id: isEditing && item != null ? item.id : _utils.uid(),
                                  originId: isMasterItem || item == null
                                      ? null
                                      : item.originId ?? item.id,
                                  name: _itemNameController.text.cleanUp,
                                  code: _itemCodeController.text.cleanUp.toUpperCase(),
                                  cost: _itemCostController.text.cleanUp,
                                  tags: _pickedTags,
                                  image: _imageObject ?? _item?.image,
                                  trackStock: isMasterItem ? null : trackStock,
                                  quantity: isMasterItem
                                      ? null
                                      : int.parse(_itemQuantityController.text));
                              //Pop loading dialog and Pop the form returning item
                              Navigator.pop(context);
                              Navigator.pop(context, _item);
                            }
                          : null),
                  SizedBox(height: 12.0.spMin),
                  FullWidthButton(
                      title: "CANCEL",
                      color: Colors.grey.shade600,
                      onPressed: () => Navigator.pop(context))
                ]))
          ]);
        });
      });
}

Future<ImageObject?> uploadImage(BuildContext context, File? imageFile) async {
  final _uploaderService = UploaderService();
  ImageObject? _imageObject;
  if (imageFile != null) {
    showLoaderDialog(context, loadingText: 'Uploading image...');
    _imageObject = await _uploaderService.uploadAndGetImageObj(imageFile);
    Navigator.pop(context);
  }
  return _imageObject;
}
