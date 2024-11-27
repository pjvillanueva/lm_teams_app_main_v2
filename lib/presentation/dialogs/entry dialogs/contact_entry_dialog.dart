import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_model.dart';
import 'package:lm_teams_app/data/models/interaction%20model/interaction_data_model.dart';
import 'package:lm_teams_app/data/models/interaction%20model/interaction_model.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';
import 'package:lm_teams_app/services/contact_service.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/geolocation_bloc.dart';
import '../../../logic/cubits/contacts_cubit.dart';
import '../../../logic/cubits/entry_history_cubit.dart';
import '../../widgets/buttons.dart';
import 'money_entry_dialog.dart';

showContactEntryDialog(BuildContext context, EntryDialogMode mode,
    {Entry? entry,
    int? historyObjectIndex,
    LocationEvent? locationEvent,
    String? teamID,
    String? eventID}) {
  bool isNewEntry = mode == EntryDialogMode.add;

  return showDialog(
      context: context,
      builder: (_) {
        return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<EntryHistoryCubit>()),
              BlocProvider.value(value: context.read<ContactsCubit>())
            ],
            child: ContactEntryDialog(
                mode: mode,
                isNewEntry: isNewEntry,
                historyObjectIndex: historyObjectIndex,
                teamID: teamID,
                eventID: eventID,
                locationEvent: locationEvent,
                entry: entry));
      });
}

// ignore: must_be_immutable
class ContactEntryDialog extends StatefulWidget {
  ContactEntryDialog(
      {Key? key,
      required this.mode,
      required this.isNewEntry,
      this.historyObjectIndex,
      this.teamID,
      this.eventID,
      this.locationEvent,
      this.entry})
      : super(key: key);

  Entry? entry;
  int? historyObjectIndex;
  String? teamID;
  String? eventID;
  LocationEvent? locationEvent;
  final EntryDialogMode mode;
  final bool isNewEntry;

  @override
  State<ContactEntryDialog> createState() => _ContactEntryDialogState();
}

class _ContactEntryDialogState extends State<ContactEntryDialog> {
  bool isLoading = false;
  EntryDialogMode mode = EntryDialogMode.add;
  final _formKey = GlobalKey<FormState>();
  final _validators = CustomValidators();
  final _contactNameController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _addressController = TextEditingController();
  var _phoneNumbers = [];
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  final _geolocationService = GeolocationService();
  final _utils = UtilsService();
  final _contactService = ContactService();
  late Contact data;

  @override
  initState() {
    super.initState();
    mode = widget.mode;
    data = widget.isNewEntry ? Contact.empty : widget.entry!.data as Contact;
    _contactNameController.text = widget.isNewEntry ? '' : data.name;
    _houseNumberController.text = widget.isNewEntry ? '' : data.houseNumber;
    _streetNameController.text = widget.isNewEntry ? '' : data.street;
    _emailController.text = (widget.isNewEntry ? '' : data.email) ?? '';
    _notesController.text = widget.isNewEntry ? '' : data.notes ?? '';
    _phoneNumbers = widget.isNewEntry ? [''] : _initializePhoneNumbers(widget.entry?.data?.phone);
    _getAddress();
  }

  void _getAddress() async {
    try {
      if (widget.isNewEntry) {
        if (widget.locationEvent != null) {
          _addressController.text = await _utils.addressFromLocationEvent(widget.locationEvent);
        } else {
          if (context.read<GeolocationBloc>().state.isEnabled) {
            LocationEvent? latestLocation = await _geolocationService.getCurrentLocation(context);
            if (latestLocation != null) {
              _addressController.text = await _utils.addressFromLocationEvent(latestLocation);
            }
          } else {
            _addressController.text = '';
          }
        }
      } else {
        _addressController.text = data.address;
      }
    } catch (e) {
      _addressController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final _user = context.read<UserBloc>().state.user;

    return BlocListener<GeolocationBloc, GeolocationState>(
      listenWhen: (previous, current) => previous.isEnabled != current.isEnabled,
      listener: (context, state) {
        if (state.isEnabled) {
          _getAddress();
        }
      },
      child: Dialog(
          child: SingleChildScrollView(
              child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: EdgeInsets.all(20.0.spMin),
                  child: Form(
                      key: _formKey,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DialogTitle(
                                title: mode == EntryDialogMode.edit ? 'Edit Contact' : 'Contact'),
                            SizedBox(height: 20.0.spMin),
                            AppOutlinedTextFormField(
                                labelText: 'Name',
                                hintText: 'John Smith',
                                readOnly: mode == EntryDialogMode.view,
                                controller: _contactNameController,
                                validator: _validators.emptyValidator),
                            SizedBox(height: 10.0.spMin),
                            Row(children: [
                              Expanded(
                                  flex: 2,
                                  child: AppOutlinedTextFormField(
                                      controller: _houseNumberController,
                                      labelText: '#',
                                      hintText: 'Type your answer here...',
                                      readOnly: mode == EntryDialogMode.view)),
                              SizedBox(width: 10.0.spMin),
                              Expanded(
                                  flex: 4,
                                  child: AppOutlinedTextFormField(
                                      controller: _streetNameController,
                                      labelText: "Street",
                                      hintText: "Type your answer here...",
                                      readOnly: mode == EntryDialogMode.view))
                            ]),
                            SizedBox(height: 10.0.spMin),
                            AppOutlinedTextFormField(
                                controller: _addressController,
                                labelText: "Address",
                                hintText: "Type your answer here...",
                                readOnly: mode == EntryDialogMode.view),
                            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                              SizedBox(width: 3.0.spMin),
                              Text('PHONE NUMBER(S)', style: TextStyle(fontSize: 12.spMin)),
                              const Spacer(),
                              Visibility(
                                  visible: _phoneNumbers.length < 3 && mode != EntryDialogMode.view,
                                  child: IconButton(
                                      icon: Icon(Icons.add, size: 16.0.spMin),
                                      onPressed: () {
                                        if (_phoneNumbers.length < 3) {
                                          setState(() {
                                            _phoneNumbers.add('');
                                          });
                                        }
                                      }),
                                  replacement: const IconButton(onPressed: null, icon: Text('')))
                            ]),
                            Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _phoneNumbers.asMap().entries.map((phoneNumber) {
                                  var index = phoneNumber.key;
                                  return Column(children: [
                                    AppOutlinedPhoneNumberInput(
                                        initialPhoneNumber: _phoneNumbers[index],
                                        isEnabled: mode != EntryDialogMode.view,
                                        labelText: 'Phone ${index + 1}',
                                        suffixIcon: IconButton(
                                            icon: Icon(Icons.delete_outlined, size: 24.0.spMin),
                                            onPressed: () => setState(() {
                                                  _phoneNumbers.removeAt(index);
                                                })),
                                        updateController: (value) => _phoneNumbers[index] = value),
                                    SizedBox(height: 10.0.spMin)
                                  ]);
                                }).toList()),
                            AppOutlinedTextFormField(
                                controller: _emailController,
                                labelText: "Email",
                                hintText: "Type your answer here...",
                                readOnly: mode == EntryDialogMode.view),
                            SizedBox(height: 10.0.spMin),
                            AppOutlinedTextFormField(
                                controller: _notesController,
                                labelText: "Notes",
                                hintText: "Type your answer here...",
                                maxLines: 3,
                                readOnly: mode == EntryDialogMode.view),
                            SizedBox(height: 10.0.spMin),
                            Visibility(
                                visible: mode != EntryDialogMode.view,
                                child: Column(children: [
                                  AddCurrentLocationButton(visible: widget.isNewEntry),
                                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel',
                                            style: TextStyle(
                                                fontSize: 16.0.spMin,
                                                color: Theme.of(context).colorScheme.onSurface))),
                                    SizedBox(width: 14.0.spMin),
                                    AppElevatedButton(
                                        child: isLoading
                                            ? SizedBox(
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 4.0.spMin),
                                                height: 20.0.spMin,
                                                width: 20.0.spMin)
                                            : Text('Save',
                                                style: TextStyle(
                                                    fontSize: 16.0.spMin, color: Colors.white)),
                                        onPressed: isLoading
                                            ? null
                                            : () async {
                                                if (_formKey.currentState!.validate()) {
                                                  setState(() => isLoading = true);

                                                  LocationEvent? _latestLocation;
                                                  if (widget.locationEvent != null) {
                                                    _latestLocation = widget.locationEvent;
                                                  } else {
                                                    if (context
                                                        .read<GeolocationBloc>()
                                                        .state
                                                        .isEnabled) {
                                                      _latestLocation = await _geolocationService
                                                          .getCurrentLocation(context);
                                                    }
                                                  }

                                                  var _contact = Contact(
                                                      id: mode == EntryDialogMode.edit
                                                          ? widget.entry?.data.id
                                                          : _utils.uid(),
                                                      ownerId: _user.id,
                                                      name: _contactNameController.text,
                                                      houseNumber: _houseNumberController.text,
                                                      street: _streetNameController.text,
                                                      address: _addressController.text,
                                                      color: mode == EntryDialogMode.edit
                                                          ? data.color
                                                          : _utils.randomColor.value.toString(),
                                                      email: _emailController.text,
                                                      notes: _notesController.text,
                                                      phone: _phoneNumbers
                                                          .where((phoneNumber) =>
                                                              phoneNumber.isNotEmpty)
                                                          .toList(),
                                                      sharedWith: const [],
                                                      locationEvent:
                                                          widget.locationEvent ?? _latestLocation);

                                                  if (mode == EntryDialogMode.add) {
                                                    //create new contact
                                                    _contactService.addContact(_contact);
                                                    //create new interaction
                                                    _contactService.addInteraction(Interaction(
                                                        id: _utils.uid(),
                                                        contactId: _contact.id,
                                                        type: InteractionType.Visit,
                                                        notes: _contact.notes ?? '',
                                                        data: const VisitData(wasHome: true),
                                                        time: DateTime.now()));

                                                    // create new entry
                                                    context.read<EntryHistoryCubit>().addEntry(
                                                        EntryType.contact,
                                                        _contact,
                                                        widget.teamID,
                                                        widget.eventID,
                                                        locationEvent: widget.locationEvent ??
                                                            _latestLocation);

                                                    // add contact to contact screen
                                                    context
                                                        .read<ContactsCubit>()
                                                        .addContact(_contact);
                                                    Navigator.pop(context);
                                                    showAppSnackbar(context, 'Contact saved');
                                                  } else if (mode == EntryDialogMode.edit &&
                                                      widget.entry != null) {
                                                    if (widget.entry?.data == _contact) {
                                                      Navigator.pop(context);
                                                      showAppSnackbar(context, 'No changes made',
                                                          isError: true);
                                                      return;
                                                    }
                                                    context.read<EntryHistoryCubit>().updateEntry(
                                                        widget.entry!.updated(_contact),
                                                        _contact,
                                                        widget.historyObjectIndex!);

                                                    context
                                                        .read<ContactsCubit>()
                                                        .updateContact(_contact);

                                                    Navigator.pop(context);
                                                    showAppSnackbar(context, 'Entry saved');
                                                  }
                                                }
                                              })
                                  ])
                                ]),
                                replacement: Column(children: [
                                  SizedBox(height: 10.0.spMin),
                                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                    OutlinedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Close',
                                            style: TextStyle(
                                                fontSize: 16.0.spMin,
                                                color: Theme.of(context).colorScheme.onSurface))),
                                    SizedBox(width: 14.0.spMin),
                                    AppElevatedButton(
                                        child: const Text('Edit',
                                            style: TextStyle(color: Colors.white)),
                                        onPressed: () => setState(() {
                                              mode = EntryDialogMode.edit;
                                            }))
                                  ])
                                ]))
                          ]))))),
    );
  }
}

//initialize phone numbers
List _initializePhoneNumbers(List? phoneNumbers) {
  if (phoneNumbers != null && phoneNumbers.isNotEmpty) {
    return phoneNumbers.map((e) => e).toList();
  }
  return [];
}
