import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_model.dart';
import 'package:lm_teams_app/data/models/location%20model/location_event.dart';
import 'package:lm_teams_app/logic/cubits/entry_history_cubit.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';
import 'package:lm_teams_app/services/geolocation_service.dart';
import '../../../logic/blocs/geolocation_bloc.dart';
import '../../widgets/buttons.dart';
import '../../widgets/snackbar.dart';
import 'money_entry_dialog.dart';

showNoteEntryDialog(BuildContext context, EntryDialogMode mode,
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
            child: NoteEntryDialog(
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
class NoteEntryDialog extends StatefulWidget {
  NoteEntryDialog({
    Key? key,
    this.entry,
    required this.mode,
    required this.isNewEntry,
    this.historyObjectIndex,
    this.teamID,
    this.eventID,
    this.locationEvent,
  }) : super(key: key);

  Entry? entry;
  int? historyObjectIndex;
  String? teamID;
  String? eventID;
  LocationEvent? locationEvent;
  EntryDialogMode mode;
  bool isNewEntry;

  @override
  State<NoteEntryDialog> createState() => _NoteEntryDialogState();
}

class _NoteEntryDialogState extends State<NoteEntryDialog> {
  bool isLoading = false;
  EntryDialogMode mode = EntryDialogMode.add;
  final _noteController = TextEditingController();
  final _geolocationService = GeolocationService();

  @override
  initState() {
    mode = widget.mode;
    var data = widget.isNewEntry ? '' : widget.entry?.data ?? '';
    _noteController.text = widget.isNewEntry ? "" : data;
    super.initState();
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
                      title: mode == EntryDialogMode.edit ? 'Edit Note Entry' : 'Note Entry'),
                  SizedBox(height: 20.0.spMin),
                  TextFormField(
                      style: TextStyle(fontSize: 16.0.spMin),
                      controller: _noteController,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: "Type your note here"),
                      readOnly: mode == EntryDialogMode.view,
                      maxLines: 5),
                  SizedBox(height: 14.0.spMin),
                  Visibility(
                      visible: mode != EntryDialogMode.view,
                      child: Column(children: [
                        AddCurrentLocationButton(visible: widget.isNewEntry),
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
                                      setState(() => isLoading = true);
                                      if (_noteController.text.isEmpty) {
                                        Navigator.pop(context);
                                        showAppSnackbar(context, 'Note cannot be empty',
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

                                      if (mode == EntryDialogMode.add) {
                                        context.read<EntryHistoryCubit>().addEntry(EntryType.notes,
                                            _noteController.text, widget.teamID, widget.eventID,
                                            locationEvent: widget.locationEvent ?? _latestLocation);
                                      } else if (mode == EntryDialogMode.edit) {
                                        if (widget.entry != null) {
                                          context.read<EntryHistoryCubit>().updateEntry(
                                              widget.entry!.updated(_noteController.text),
                                              _noteController.text,
                                              widget.historyObjectIndex!);
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
                              child: Text('Close',
                                  style: TextStyle(
                                      fontSize: 16.0.spMin,
                                      color: Theme.of(context).colorScheme.onSurface)),
                              onPressed: () => Navigator.pop(context)),
                          SizedBox(width: 14.0.spMin),
                          AppElevatedButton(
                              child: const Text('Edit', style: TextStyle(color: Colors.white)),
                              onPressed: () => setState(() => mode = EntryDialogMode.edit))
                        ])
                      ]))
                ]))));
  }
}