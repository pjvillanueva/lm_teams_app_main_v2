import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';
import 'package:lm_teams_app/data/models/reminder_model.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/date_picker_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/interaction_dialog.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<Reminder?> showReminderDialog({
  required BuildContext context,
  required Contact contact,
  required List<User> canvassers,
  Reminder? reminder,
  String? selectedCanvasser,
}) {
  final _timeService = TimeService();
  final _formKey = GlobalKey<FormState>();
  final _validators = CustomValidators();
  final _utils = UtilsService();

  DateTime _reminderDateTime = _getInitialDate(reminder);
  final _currrentUser = context.read<UserBloc>().state.user;
  final _noteController = TextEditingController(text: reminder != null ? reminder.notes : '');
  final _repeatReminderController =
      TextEditingController(text: reminder != null ? reminder.repeat.name : 'none');
  final _reminderDateController =
      TextEditingController(text: _timeService.dateToString(_reminderDateTime));
  final _reminderTimeController =
      TextEditingController(text: _timeService.timeToString(_reminderDateTime));
  final _canvasserController = TextEditingController(text: selectedCanvasser ?? _currrentUser.id);

  String? _timeErrorText;

  final List<Map<String, dynamic>> _reminderRepeatItems = [
    {'value': ReminderRepeat.none.name, 'label': 'Don\'t Repeat'},
    {'value': ReminderRepeat.weekly.name, 'label': 'Weekly'},
    {'value': ReminderRepeat.fornightly.name, 'label': 'Fornightly'},
    {'value': ReminderRepeat.monthly.name, 'label': 'Monthly'},
    {'value': ReminderRepeat.yearly.name, 'label': 'Yearly'}
  ];

  String? _validateTime(String? value) {
    if (_reminderDateTime.isBefore(DateTime.now())) {
      return 'Time must be in the future';
    }
    return null;
  }

  return showDialog(
      context: context,
      builder: (contex) {
        return StatefulBuilder(builder: (context, setState) {
          return Form(
              key: _formKey,
              child: AppDialog(title: 'Followup Reminder', contents: [
                TextFormField(
                    maxLines: 2,
                    style: TextStyle(fontSize: 16.0.spMin),
                    decoration: InputDecoration(
                        label: Text('Reminder Notes', style: TextStyle(fontSize: 16.0.spMin)),
                        alignLabelWithHint: true),
                    controller: _noteController,
                    validator: _validators.emptyValidator),
                SelectFormField(
                    type: SelectFormFieldType.dropdown,
                    items: _reminderRepeatItems,
                    controller: _repeatReminderController,
                    style: TextStyle(fontSize: 16.0.spMin),
                    decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down, size: 24.0.spMin),
                        labelText: 'Repeat Reminder',
                        labelStyle: TextStyle(fontSize: 16.0.spMin),
                        hintText: '')),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                          readOnly: true,
                          controller: _reminderDateController,
                          style: TextStyle(fontSize: 16.0.spMin),
                          decoration: InputDecoration(
                              label: Text('Date', style: TextStyle(fontSize: 16.0.spMin)),
                              suffixIcon: GestureDetector(
                                  child: Icon(Icons.calendar_month_outlined, size: 24.0.spMin),
                                  onTap: () async {
                                    var _date = await openDatePicker(
                                        context,
                                        _timeService.stringToDate(_reminderDateController.text),
                                        false);

                                    if (_date != null) {
                                      setState(() {
                                        _reminderDateTime = _date;
                                        _reminderDateController.text =
                                            _timeService.dateToString(_date);
                                      });
                                    }
                                  })))),
                  SizedBox(width: 10.0.spMin),
                  Expanded(
                      child: TextFormField(
                          readOnly: true,
                          controller: _reminderTimeController,
                          validator: _validateTime,
                          autovalidateMode: AutovalidateMode.always,
                          style: TextStyle(fontSize: 16.0.spMin),
                          decoration: InputDecoration(
                              errorText: _timeErrorText,
                              label: Text('Time', style: TextStyle(fontSize: 16.0.spMin)),
                              suffixIcon: GestureDetector(
                                  child: Icon(Icons.alarm_outlined, size: 24.0.spMin),
                                  onTap: () async {
                                    var _pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime:
                                            stringToTimeOfDay(_reminderTimeController.text));
                                    var _pickedDate =
                                        _timeService.stringToDate(_reminderDateController.text);

                                    if (_pickedTime != null) {
                                      DateTime _pickedDateTime = DateTime(
                                          _pickedDate.year,
                                          _pickedDate.month,
                                          _pickedDate.day,
                                          _pickedTime.hour,
                                          _pickedTime.minute);

                                      setState(() {
                                        _reminderDateTime = _pickedDateTime;
                                        _reminderTimeController.text =
                                            _timeService.timeToString(_pickedDateTime);
                                      });
                                    }
                                  }))))
                ]),
                SelectFormField(
                    type: SelectFormFieldType.dropdown,
                    items: mappedUserList(canvassers),
                    controller: _canvasserController,
                    style: TextStyle(fontSize: 16.0.spMin),
                    decoration: InputDecoration(
                        border: const UnderlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down, size: 24.0.spMin),
                        labelText: 'Canvasser',
                        labelStyle: TextStyle(fontSize: 16.0.spMin),
                        hintText: '')),
                SizedBox(height: 10.0.spMin),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                      child: Text('CANCEL',
                          style: TextStyle(
                              fontSize: 16.0.spMin,
                              color: Theme.of(context).colorScheme.onSurface)),
                      onPressed: () => Navigator.pop(context)),
                  SizedBox(width: 10.0.spMin),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.secondary)),
                      child:
                          Text('SAVE', style: TextStyle(fontSize: 16.0.spMin, color: Colors.white)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Reminder _reminder = Reminder(
                              id: reminder != null ? reminder.id : _utils.uid(),
                              notificationId:
                                  reminder != null ? reminder.notificationId : _utils.notifID(),
                              contactId: contact.id,
                              notes: _noteController.text,
                              repeat: stringToEnum<ReminderRepeat>(
                                  ReminderRepeat.values, _repeatReminderController.text),
                              time: mergeTimeAndDate(
                                  _reminderTimeController.text, _reminderDateController.text),
                              canvasserId: _canvasserController.text);

                          Navigator.pop(context, _reminder);
                        }
                      })
                ])
              ]));
        });
      });
}

DateTime _getInitialDate(Reminder? reminder) {
  if (reminder != null) {
    return reminder.time;
  }

  final _now = DateTime.now();
  final _isPast9AM = _now.hour >= 9;

  return _isPast9AM
      ? _now.add(const Duration(minutes: 30))
      : DateTime(_now.year, _now.month, _now.day, 9, 0);
}
