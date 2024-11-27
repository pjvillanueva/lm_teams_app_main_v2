import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';
import 'package:lm_teams_app/data/models/interaction%20model/interaction_data_model.dart';
import 'package:lm_teams_app/data/models/interaction%20model/interaction_model.dart';
import 'package:lm_teams_app/data/models/reminder_model.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/presentation/dialogs/date_picker_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/reminder_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:intl/intl.dart';

class InteractionDialogData {
  const InteractionDialogData({
    required this.interaction,
    required this.reminder,
  });
  final Interaction? interaction;
  final Reminder? reminder;
}

Future<InteractionDialogData?> showInteractionDialog(
    {required BuildContext context,
    required Contact contact,
    Interaction? interaction,
    required List<User> canvassers}) {
  return showDialog(
      context: context,
      builder: (_) {
        return InteractionDialog(
          contact: contact,
          interaction: interaction,
          canvassers: canvassers,
        );
      });
}

class InteractionDialog extends StatefulWidget {
  const InteractionDialog(
      {Key? key, required this.contact, required this.interaction, required this.canvassers})
      : super(key: key);

  final Contact contact;
  final Interaction? interaction;
  final List<User> canvassers;

  @override
  State<InteractionDialog> createState() => _InteractionDialogState();
}

class _InteractionDialogState extends State<InteractionDialog> {
  final _utils = UtilsService();
  final _timeService = TimeService();

  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _visitTypeItems = [
    {'value': InteractionType.Visit.name, 'label': 'Personal Visit'},
    {'value': InteractionType.BibleStudy.name, 'label': 'Bible Study'}
  ];
  final List<Map<String, dynamic>> _studyTypeItems = [
    {'value': BibleStudyType.none.name, 'label': 'None'},
    {'value': BibleStudyType.personal.name, 'label': 'Personal'},
    {'value': BibleStudyType.diy.name, 'label': 'DIY Guide'},
    {'value': BibleStudyType.dvd.name, 'label': 'DVD'}
  ];
  final List<Map<String, dynamic>> _studyGuideItems = [
    {'value': StudyGuideType.none.name, 'label': 'None'},
    {'value': StudyGuideType.amazing.name, 'label': 'Amazing Facts'},
    {'value': StudyGuideType.search.name, 'label': 'Search for Certainty'},
    {'value': StudyGuideType.other.name, 'label': 'Other'}
  ];

  Reminder? reminder;

  final _visitTypeController = TextEditingController();
  final _noteController = TextEditingController();
  final _studyTypeController = TextEditingController();
  final _studyGuideController = TextEditingController();
  final _visitDateController = TextEditingController();
  final _visitTimeController = TextEditingController();
  final _canvasserController = TextEditingController();

  bool isStudy = false;
  bool wasHome = true;

  @override
  void initState() {
    User user = context.read<UserBloc>().state.user;
    _visitTypeController.text = _getInitialValue(widget.interaction);
    _noteController.text = widget.interaction?.notes ?? '';
    _studyTypeController.text = _getStudyTypeInitialValue(widget.interaction);
    _studyGuideController.text = _getStudyGuideInitialValue(widget.interaction);
    _visitDateController.text = _getVisitDateInitialValue(widget.interaction);
    _visitTimeController.text = _getVisitTimeInitialValue(widget.interaction);
    _canvasserController.text = _getCanvasserInitialValue(widget.interaction, user.id);
    isStudy = _getStudyType(widget.interaction);
    wasHome = _getWasHome(widget.interaction);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                              title: '${isStudy ? 'Study' : 'Visit'} - ${widget.contact.name}'),
                          SizedBox(height: 20.0.spMin),
                          SelectFormField(
                              type: SelectFormFieldType.dropdown,
                              items: _visitTypeItems,
                              controller: _visitTypeController,
                              style: TextStyle(fontSize: 16.0.spMin),
                              onChanged: (value) {
                                setState(() {
                                  isStudy = value == 'BibleStudy' ? true : false;
                                });
                              },
                              decoration: InputDecoration(
                                  border: const UnderlineInputBorder(),
                                  suffixIcon: Icon(Icons.arrow_drop_down, size: 24.0.spMin),
                                  labelText: 'Visit Type',
                                  labelStyle: TextStyle(fontSize: 16.0.spMin),
                                  hintText: '')),
                          TextFormField(
                              maxLines: 2,
                              style: TextStyle(fontSize: 16.0.spMin),
                              decoration: InputDecoration(
                                  label: Text('Notes', style: TextStyle(fontSize: 16.0.spMin)),
                                  alignLabelWithHint: true),
                              controller: _noteController),
                          SizedBox(height: 20.0.spMin),
                          Visibility(
                              visible: !isStudy,
                              child:
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Flexible(
                                    child: Text('Was ${widget.contact.name} home?',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 14.0.spMin))),
                                FlutterSwitch(
                                    width: 65.spMin,
                                    height: 30.spMin,
                                    padding: 2.0.spMin,
                                    toggleSize: 30.0.spMin,
                                    value: wasHome,
                                    showOnOff: true,
                                    activeColor: Theme.of(context).colorScheme.secondary,
                                    activeText: 'Yes',
                                    inactiveText: 'No',
                                    valueFontSize: 10.0.spMin,
                                    onToggle: (value) {
                                      setState(() {
                                        wasHome = value;
                                      });
                                    })
                              ]),
                              replacement: Row(children: [
                                Expanded(
                                    child: SelectFormField(
                                        type: SelectFormFieldType.dropdown,
                                        items: _studyTypeItems,
                                        controller: _studyTypeController,
                                        style: TextStyle(fontSize: 16.0.spMin),
                                        decoration: InputDecoration(
                                            border: const UnderlineInputBorder(),
                                            suffixIcon:
                                                Icon(Icons.arrow_drop_down, size: 24.0.spMin),
                                            labelText: 'Study Type',
                                            labelStyle: TextStyle(fontSize: 16.0.spMin),
                                            hintText: ''))),
                                SizedBox(width: 10.0.spMin),
                                Expanded(
                                    child: SelectFormField(
                                        type: SelectFormFieldType.dropdown,
                                        items: _studyGuideItems,
                                        controller: _studyGuideController,
                                        style: TextStyle(fontSize: 16.0.spMin),
                                        decoration: InputDecoration(
                                            border: const UnderlineInputBorder(),
                                            suffixIcon:
                                                Icon(Icons.arrow_drop_down, size: 24.0.spMin),
                                            labelText: 'Study Guide',
                                            labelStyle: TextStyle(fontSize: 16.0.spMin),
                                            hintText: '')))
                              ])),
                          Row(children: [
                            Expanded(
                                child: TextFormField(
                                    readOnly: true,
                                    controller: _visitDateController,
                                    style: TextStyle(fontSize: 16.0.spMin),
                                    decoration: InputDecoration(
                                        label: Text('Visit Date',
                                            style: TextStyle(fontSize: 16.0.spMin)),
                                        suffixIcon: GestureDetector(
                                          child: Icon(Icons.calendar_month, size: 22.0.spMin),
                                          onTap: () async {
                                            var _datePicked = await openDatePicker(
                                                context,
                                                _timeService
                                                    .stringToDate(_visitDateController.text));

                                            if (_datePicked != null) {
                                              _visitDateController.text =
                                                  _timeService.dateToString(_datePicked);
                                            }
                                          },
                                        )))),
                            SizedBox(width: 10.0.spMin),
                            Expanded(
                                child: TextFormField(
                                    readOnly: true,
                                    controller: _visitTimeController,
                                    style: TextStyle(fontSize: 16.0.spMin),
                                    decoration: InputDecoration(
                                        label: Text('Visit Time',
                                            style: TextStyle(fontSize: 16.0.spMin)),
                                        suffixIcon: GestureDetector(
                                            child: Icon(Icons.schedule, size: 22.0.spMin),
                                            onTap: () async {
                                              var time = await showTimePicker(
                                                  context: context,
                                                  initialTime:
                                                      stringToTimeOfDay(_visitTimeController.text));

                                              if (time != null) {
                                                setState(() {
                                                  _visitTimeController.text =
                                                      timeOfDayToString(time);
                                                });
                                              }
                                            }))))
                          ]),
                          SelectFormField(
                              type: SelectFormFieldType.dropdown,
                              items: mappedUserList(widget.canvassers),
                              controller: _canvasserController,
                              style: TextStyle(fontSize: 16.0.spMin),
                              decoration: InputDecoration(
                                  border: const UnderlineInputBorder(),
                                  suffixIcon: Icon(Icons.arrow_drop_down, size: 24.0.spMin),
                                  labelText: 'Canvasser',
                                  labelStyle: TextStyle(fontSize: 16.0.spMin),
                                  hintText: '')),
                          SizedBox(height: 10.0.spMin),
                          Visibility(
                              visible: reminder == null,
                              child: TextButton(
                                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                    Icon(Icons.add,
                                        color: Theme.of(context).colorScheme.onSurface,
                                        size: 24.0.spMin),
                                    Text('Add Follow-up Reminder',
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.onSurface,
                                            fontSize: 16.0.spMin))
                                  ]),
                                  onPressed: () async {
                                    Reminder? _reminder = await showReminderDialog(
                                        context: context,
                                        contact: widget.contact,
                                        canvassers: widget.canvassers,
                                        selectedCanvasser: _canvasserController.text);

                                    if (_reminder != null) {
                                      setState(() {
                                        reminder = _reminder;
                                      });
                                    }
                                  }),
                              replacement: Column(children: [
                                const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [DialogTitle(title: 'Followup Reminder')]),
                                const SizedBox(height: 10),
                                Container(
                                    child: reminder != null
                                        ? ReminderListTile(
                                            reminder: reminder!,
                                            trailingIcon: Icons.close,
                                            onPressedLeading: () async {
                                              Reminder? _reminder = await showReminderDialog(
                                                  context: context,
                                                  contact: widget.contact,
                                                  canvassers: widget.canvassers,
                                                  reminder: reminder);

                                              if (_reminder != null) {
                                                setState(() {
                                                  reminder = _reminder;
                                                });
                                              }
                                            },
                                            onPressedTrailing: () {
                                              setState(() {
                                                reminder = null;
                                              });
                                            })
                                        : null),
                              ])),
                          SizedBox(height: 10.0.spMin),
                          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            TextButton(
                                child: Text('CANCEL',
                                    style: TextStyle(
                                        fontSize: 16.0.spMin,
                                        color: Theme.of(context).colorScheme.onSurface)),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            SizedBox(width: 10.0.spMin),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(
                                        Theme.of(context).colorScheme.secondary)),
                                child: Text('SAVE',
                                    style: TextStyle(fontSize: 16.0.spMin, color: Colors.white)),
                                onPressed: () {
                                  try {
                                    var _interaction = Interaction(
                                        id: widget.interaction?.id ?? _utils.uid(),
                                        contactId: widget.contact.id,
                                        ownerId: _canvasserController.text,
                                        type: stringToEnum<InteractionType>(
                                            InteractionType.values, _visitTypeController.text),
                                        notes: _noteController.text,
                                        data: _getInteractionData(
                                            type: getInteractionType(_visitTypeController.text),
                                            studyType: _studyTypeController.text,
                                            studyGuide: _studyGuideController.text,
                                            wasHome: wasHome),
                                        time: mergeTimeAndDate(
                                            _visitTimeController.text, _visitDateController.text));

                                    Navigator.pop(
                                        context,
                                        InteractionDialogData(
                                            interaction: _interaction, reminder: reminder));
                                  } catch (e) {
                                    print(e);
                                  }
                                })
                          ])
                        ])))));
  }
}

T stringToEnum<T>(Iterable<T> values, String value) {
  return values.firstWhere((v) => v.toString().split(".").last == value);
}

bool _getStudyType(Interaction? interaction) {
  if (interaction != null) {
    return interaction.type == InteractionType.BibleStudy ? true : false;
  }
  return false;
}

String _getInitialValue(Interaction? interaction) {
  String _default = 'Visit';
  if (interaction != null) {
    if (interaction.type == InteractionType.BibleStudy) {
      return 'BibleStudy';
    } else {
      return _default;
    }
  }
  return _default;
}

String _getStudyTypeInitialValue(Interaction? interaction) {
  String _default = 'none';
  if (interaction != null) {
    if (interaction.type == InteractionType.BibleStudy) {
      var data = interaction.data as BibleStudyData;
      if (data.studyType != null) {
        return data.studyType!.name;
      }
      return _default;
    }
    return _default;
  }
  return _default;
}

String _getStudyGuideInitialValue(Interaction? interaction) {
  String _default = 'none';
  if (interaction != null) {
    if (interaction.type == InteractionType.BibleStudy) {
      var data = interaction.data as BibleStudyData;
      if (data.studyGuide != null) {
        return data.studyGuide!.name;
      }
      return _default;
    }
    return _default;
  }
  return _default;
}

bool _getWasHome(Interaction? interaction) {
  bool _default = true;
  if (interaction != null) {
    if (interaction.type == InteractionType.Visit) {
      var data = interaction.data as VisitData;
      return data.wasHome;
    }
    return _default;
  }
  return _default;
}

String _getVisitDateInitialValue(Interaction? interaction) {
  final _timeService = TimeService();
  if (interaction != null) {
    return _timeService.dateToString(interaction.time);
  }
  return _timeService.dateToString(DateTime.now());
}

String _getVisitTimeInitialValue(Interaction? interaction) {
  final _timeService = TimeService();
  if (interaction != null) {
    return _timeService.timeToString(interaction.time);
  }
  return _timeService.timeToString(DateTime.now());
}

String _getCanvasserInitialValue(Interaction? interaction, String currentUserID) {
  if (interaction != null && interaction.ownerId != null) {
    return interaction.ownerId!;
  }
  return currentUserID;
}

String timeOfDayToString(TimeOfDay time) {
  final _timeService = TimeService();
  var datetime = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
  return _timeService.timeToString(datetime);
}

TimeOfDay stringToTimeOfDay(String timeString) {
  final DateFormat formatter = DateFormat.jm();
  var time = formatter.parse(timeString);
  return TimeOfDay.fromDateTime(time);
}

List<Map<String, dynamic>> mappedUserList(List<User> canvassers) {
  List<Map<String, dynamic>> list = [];
  for (var canvasser in canvassers) {
    list.add({'value': canvasser.id, 'label': canvasser.name});
  }
  return list;
}

_getInteractionData(
    {required InteractionType type,
    required String studyType,
    required String studyGuide,
    required bool wasHome}) {
  switch (type) {
    case InteractionType.BibleStudy:
      return BibleStudyData(
          studyType: stringToEnum<BibleStudyType>(BibleStudyType.values, studyType),
          studyGuide: stringToEnum<StudyGuideType>(StudyGuideType.values, studyGuide));
    case InteractionType.Visit:
      return VisitData(wasHome: wasHome);
  }
}

DateTime mergeTimeAndDate(String timeString, String dateString) {
  final _timeService = TimeService();
  var _time = stringToTimeOfDay(timeString);
  var _date = _timeService.stringToDate(dateString);
  return DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
}
