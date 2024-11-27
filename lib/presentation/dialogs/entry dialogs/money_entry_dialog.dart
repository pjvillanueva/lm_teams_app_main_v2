import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_data_model.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_model.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import 'package:lm_teams_app/logic/cubits/entry_history_cubit.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';
import 'package:lm_teams_app/services/helpers/string_helpers.dart';
import '../../widgets/buttons.dart';

enum EntryDialogMode { add, edit, view }

showMoneyEntryDialog(BuildContext context, EntryDialogMode mode,
    {Entry? entry,
    int? historyObjectIndex,
    LocationEvent? locationEvent,
    String? teamID,
    String? eventID}) {
  bool isNewEntry = mode == EntryDialogMode.add;

  return showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
            value: context.read<EntryHistoryCubit>(),
            child: MoneyEntryDialog(
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
class MoneyEntryDialog extends StatefulWidget {
  MoneyEntryDialog(
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
  bool isNewEntry;

  @override
  State<MoneyEntryDialog> createState() => _MoneyEntryDialogState();
}

class _MoneyEntryDialogState extends State<MoneyEntryDialog> {
  bool isLoading = false;
  EntryDialogMode mode = EntryDialogMode.add;
  final _notesController = TextEditingController(text: '0');
  final _cardController = TextEditingController(text: '0');
  final _coinsController = TextEditingController(text: '0');
  final _totalController = TextEditingController(text: '0');
  final _geolocationService = GeolocationService();

  _updateTotal() {
    double notes = double.tryParse(_notesController.text) ?? 0;
    double card = double.tryParse(_cardController.text) ?? 0;
    double coins = double.tryParse(_coinsController.text) ?? 0;
    var total = notes + card + coins;
    setState(() => _totalController.text = total.toString());
  }

  @override
  initState() {
    super.initState();
    mode = widget.mode;
    var data = widget.isNewEntry
        ? const MoneyEntryData(notes: 0, card: 0, coins: 0)
        : widget.entry!.data as MoneyEntryData;
    _notesController.text = widget.isNewEntry ? "0" : data.notes.toString();
    _cardController.text = widget.isNewEntry ? "0" : data.card.toString();
    _coinsController.text = widget.isNewEntry ? "0" : data.coins.toString();
    _updateTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.all(20.0.spMin),
            child: Form(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  DialogTitle(
                      title: mode == EntryDialogMode.edit ? 'Edit Money Entry' : 'Money Entry'),
                  SizedBox(height: 20.0.spMin),
                  Row(children: [
                    const Icon(Icons.credit_card),
                    SizedBox(width: 5.spMin),
                    Text('Card', style: TextStyle(fontSize: 18.spMin)),
                    const Spacer(),
                    AppNumberInputField(
                        controller: _cardController,
                        onChanged: _updateTotal,
                        readOnly: mode == EntryDialogMode.view)
                  ]),
                  SizedBox(height: 15.spMin),
                  Row(children: [
                    const Icon(Icons.payments),
                    SizedBox(width: 5.spMin),
                    Text('Notes', style: TextStyle(fontSize: 18.spMin)),
                    const Spacer(),
                    AppNumberInputField(
                        controller: _notesController,
                        onChanged: _updateTotal,
                        readOnly: mode == EntryDialogMode.view)
                  ]),
                  SizedBox(height: 15.spMin),
                  Row(children: [
                    const Icon(Icons.toll),
                    SizedBox(width: 5.spMin),
                    Text('Coins', style: TextStyle(fontSize: 18.spMin)),
                    const Spacer(),
                    AppNumberInputField(
                        controller: _coinsController,
                        onChanged: _updateTotal,
                        readOnly: mode == EntryDialogMode.view)
                  ]),
                  Divider(thickness: 1.0.spMin),
                  Row(children: [
                    const Icon(Icons.paid),
                    SizedBox(width: 5.spMin),
                    Text('TOTAL', style: TextStyle(fontSize: 18.spMin)),
                    const Spacer(),
                    AppNumberInputField(controller: _totalController, readOnly: true)
                  ]),
                  SizedBox(height: 20.0.spMin),
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
                                      child: CircularProgressIndicator(strokeWidth: 4.0.spMin),
                                      height: 20.0.spMin,
                                      width: 20.0.spMin)
                                  : Text('Save',
                                      style: TextStyle(fontSize: 16.0.spMin, color: Colors.white)),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setState(() => isLoading = true);
                                      if (double.parse(_totalController.text) == 0) {
                                        Navigator.pop(context);
                                        showAppSnackbar(context, 'Amount must be greater than 0',
                                            isError: true);
                                        return;
                                      }

                                      LocationEvent? _latestLocation;
                                      if (widget.locationEvent != null) {
                                        _latestLocation = widget.locationEvent;
                                      } else {
                                        if (context.read<GeolocationBloc>().state.isEnabled) {
                                          _latestLocation =
                                              await _geolocationService.getCurrentLocation(context);
                                        }
                                      }

                                      var _entryData = MoneyEntryData(
                                          notes: _notesController.text.toDouble,
                                          card: _cardController.text.toDouble,
                                          coins: _coinsController.text.toDouble);

                                      if (mode == EntryDialogMode.add) {
                                        context.read<EntryHistoryCubit>().addEntry(EntryType.money,
                                            _entryData, widget.teamID, widget.eventID,
                                            locationEvent: _latestLocation);
                                      } else if (mode == EntryDialogMode.edit &&
                                          widget.entry != null) {
                                        if (widget.entry?.data != _entryData) {
                                          context.read<EntryHistoryCubit>().updateEntry(
                                              widget.entry!.updated(_entryData),
                                              _entryData,
                                              widget.historyObjectIndex!);
                                        } else {
                                          showAppSnackbar(context, 'No changes made',
                                              isError: true);
                                        }
                                      }
                                      Navigator.pop(context);
                                    })
                        ])
                      ]),
                      replacement: Column(children: [
                        SizedBox(height: 10.0.spMin),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Close",
                                  style: TextStyle(
                                      fontSize: 16.0.spMin,
                                      color: Theme.of(context).colorScheme.onSurface))),
                          SizedBox(width: 14.0.spMin),
                          AppElevatedButton(
                              onPressed: () => setState(() => mode = EntryDialogMode.edit),
                              child: Text(
                                'Edit',
                                style: TextStyle(fontSize: 16.0.spMin, color: Colors.white),
                              ))
                        ])
                      ]))
                ]))));
  }
}
