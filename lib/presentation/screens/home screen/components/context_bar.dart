import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import '../../../dialogs/daterange_picker_dialog.dart';
import '../../../widgets/form_inputs.dart';

class ContextBar extends StatefulWidget implements PreferredSizeWidget {
  const ContextBar({Key? key, required this.height}) : super(key: key);

  final double height;

  @override
  State<ContextBar> createState() => _ContextBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _ContextBarState extends State<ContextBar> {
  var isSettingGroup = true;

  final List<Map<String, dynamic>> _dropDownItems = [
    {'value': '1', 'label': 'last 7 days'},
    {'value': '2', 'label': 'last 30 days'}
  ];

  @override
  PreferredSizeWidget build(BuildContext context) {
    return PreferredSize(
        preferredSize: Size(double.infinity, 110.0.spMin),
        child: BlocBuilder<HomeScreenBloc, HomeScreenState>(builder: (context, state) {
          var _teamsController = TextEditingController(text: state.team.id);
          var _eventsController = TextEditingController(text: state.event.id);
          final _dateRangeController = TextEditingController(text: state.dateRangeString);

          return Visibility(
              visible: isSettingGroup,
              child: Container(
                  height: 60.0.spMin,
                  padding: EdgeInsets.fromLTRB(15.0.spMin, 0, 0, 0),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(children: [
                    Flexible(
                        flex: 5,
                        child: UserGroupDropdownField(
                            items: state.mappedTeamList,
                            controller: _teamsController,
                            labelText: 'TEAM',
                            onChanged: (value) {
                              context.read<HomeScreenBloc>().add(SelectTeam(teamID: value));
                            })),
                    SizedBox(width: 10.0.spMin),
                    Flexible(
                        flex: 5,
                        child: UserGroupDropdownField(
                            items: state.mappedEventList,
                            controller: _eventsController,
                            labelText: 'EVENT',
                            onChanged: (value) {
                              context.read<HomeScreenBloc>().add(SelectEvent(eventID: value));
                            })),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            isSettingGroup = false;
                          });
                        },
                        icon: Icon(Icons.calendar_month, size: 24.0.spMin))
                  ])),
              replacement: Container(
                  height: 60.0.spMin,
                  padding: EdgeInsets.fromLTRB(15.0.spMin, 0, 0, 0),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(children: [
                    Flexible(
                        child: TextFormField(
                            readOnly: true,
                            controller: _dateRangeController,
                            style: TextStyle(fontSize: 14.0.spMin),
                            decoration: InputDecoration(
                                labelText: "DATE RANGE",
                                labelStyle: TextStyle(fontSize: 16.0.spMin),
                                hintText: "Start Date    End Date",
                                hintStyle: TextStyle(fontSize: 16.0.spMin)))),
                    SizedBox(
                        height: 48.0.spMin,
                        width: 48.0.spMin,
                        child: PopupMenuButton(
                            color: Theme.of(context).colorScheme.surface,
                            icon: Icon(Icons.arrow_drop_down, size: 24.0.spMin),
                            itemBuilder: (context) {
                              return _dropDownItems
                                  .map((item) => PopupMenuItem(
                                      value: item['value'], child: Text(item['label'])))
                                  .toList();
                            },
                            onSelected: (value) {
                              context.read<HomeScreenBloc>().add(SetDateRange(
                                  dateRangeStart: value == "1"
                                      ? DateTime.now()
                                          .lastMidnight
                                          .subtract(const Duration(days: 7))
                                      : DateTime.now()
                                          .lastMidnight
                                          .subtract(const Duration(days: 30)),
                                  dateRangeEnd: DateTime.now().beforeMidnight,
                                  config: value == "1"
                                      ? DateRangeConfiguration.last7days
                                      : DateRangeConfiguration.last30days));
                            })),
                    SizedBox(
                        width: 48.0.spMin,
                        height: 48.0.spMin,
                        child: IconButton(
                            icon: Icon(Icons.edit_calendar, size: 24.0.spMin),
                            onPressed: () async {
                              List<DateTime>? dateRange = await openDateRangePicker(
                                  context, state.dateRangeStart, state.dateRangeEnd);
                              if (dateRange != null) {
                                BlocProvider.of<HomeScreenBloc>(context).add(SetDateRange(
                                    dateRangeStart: dateRange[0],
                                    dateRangeEnd: dateRange[1].beforeMidnight,
                                    config: DateRangeConfiguration.customRange));
                              }
                            })),
                    SizedBox(
                        width: 48.0.spMin,
                        height: 48.0.spMin,
                        child: IconButton(
                            icon: Icon(Icons.more_horiz, size: 24.0.spMin),
                            onPressed: () {
                              setState(() {
                                isSettingGroup = true;
                              });
                            }))
                  ])));
        }));
  }
}
