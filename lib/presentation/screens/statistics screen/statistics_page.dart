import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/blocs/account_bloc.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/statistics_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import '../../../data/models/statistics model/statistics_filter.dart';
import '../../../data/models/statistics model/statistics_object.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key, required this.isFullScreen}) : super(key: key);
  final bool isFullScreen;
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final _timeService = TimeService();
  int statisticObjectIndex = 0;
  final List<Widget> icons = <Widget>[
    Icon(Icons.person_outlined, size: 20.spMin),
    Icon(Icons.groups_outlined, size: 20.spMin),
  ];

  final List<Map<String, dynamic>> _dropDownItems = [
    {'value': StatisticsDateRangeContext.day, 'label': 'Today'},
    {'value': StatisticsDateRangeContext.week, 'label': 'This week'},
    {'value': StatisticsDateRangeContext.month, 'label': 'This month'},
    {'value': StatisticsDateRangeContext.year, 'label': 'This year'}
  ];

  @override
  void initState() {
    var homeScreenState = context.read<HomeScreenBloc>().state;
    var account = context.read<AccountBloc>().state.account;
    var user = context.read<UserBloc>().state.user;
    var team = homeScreenState.team;
    var statisticCubit = context.read<StatisticsCubit>();

    SchedulerBinding.instance.addPostFrameCallback((_) => showLoaderDialog(context));

    statisticCubit.getStatisticsObjects(StatisticsFilter(
        accountId: account.id,
        userId: statisticCubit.state.isPersonal[0] ? user.id : null,
        teamId: statisticCubit.state.isPersonal[0] ? null : team.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = context.read<UserBloc>().state.user;
    var team = context.watch<HomeScreenBloc>().state.team;

    return MultiBlocListener(
        listeners: [
          BlocListener<HomeScreenBloc, HomeScreenState>(
              listenWhen: (previous, current) => previous.team != current.team,
              listener: (context, state) {
                var statisticCubit = context.read<StatisticsCubit>();
                if (state.team.id != '-') {
                  if (!statisticCubit.state.isPersonal[0]) {
                    statisticCubit.getStatisticsObjects(StatisticsFilter(
                        userId: null,
                        teamId: state.team.id,
                        dateRangeStart: state.dateRangeStart,
                        dateRangeEnd: state.dateRangeEnd));
                  }
                } else {
                  statisticCubit.changeIsPersonal(0);
                }
              }),
          BlocListener<StatisticsCubit, StatisticsState>(
              listenWhen: (previous, current) => previous.isLoading != current.isLoading,
              listener: (context, state) {
                if (state.isLoading) {
                  showLoaderDialog(context);
                } else {
                  Navigator.pop(context);
                }
              }),
          BlocListener<StatisticsCubit, StatisticsState>(
              listenWhen: (previous, current) =>
                  previous.dateRangeContext != current.dateRangeContext ||
                  previous.isPersonal != current.isPersonal,
              listener: (context, state) {
                setState(() {
                  statisticObjectIndex = 0;
                });
                context.read<StatisticsCubit>().getStatisticsObjects(StatisticsFilter(
                    userId: state.isPersonal[0] ? user.id : null,
                    teamId: state.isPersonal[0] ? null : team.id));
              })
        ],
        child: BlocBuilder<StatisticsCubit, StatisticsState>(builder: (context, state) {
          List<StatisticsObject> _statisticsObjects = state.objectList;
          StatisticsObject _statObject = _statisticsObjects[statisticObjectIndex];

          return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              body: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.all(10.0.spMin),
                      child: Column(children: [
                        Flex(direction: Axis.horizontal, children: [
                          Flexible(
                              flex: 1,
                              fit: FlexFit.tight,
                              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                ToggleButtons(
                                    constraints: BoxConstraints(
                                        maxHeight: 30.spMin,
                                        minHeight: 30.spMin,
                                        maxWidth: 50.spMin - 3,
                                        minWidth: 50.spMin - 3),
                                    onPressed: (int index) {
                                      if (index == 1) {
                                        if (team.id != '-') {
                                          context.read<StatisticsCubit>().changeIsPersonal(index);
                                        } else {
                                          showAppSnackbar(context, 'No team selected',
                                              isError: true);
                                        }
                                      } else {
                                        context.read<StatisticsCubit>().changeIsPersonal(index);
                                      }
                                    },
                                    borderRadius: BorderRadius.all(Radius.circular(8.0.spMin)),
                                    selectedColor: Theme.of(context).colorScheme.onSurface,
                                    fillColor: Theme.of(context).colorScheme.secondary,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    isSelected: state.isPersonal,
                                    children: icons)
                              ])),
                          Flexible(
                              flex: 2,
                              fit: FlexFit.tight,
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                StatisticsDateFilterButton(
                                    buttonText: _timeService.statisticsDateRangeFilter(
                                        _statObject.date, state.dateRangeContext),
                                    onPressedLeftArrow:
                                        statisticObjectIndex < _statisticsObjects.length - 1
                                            ? () {
                                                setState(() {
                                                  statisticObjectIndex++;
                                                });
                                              }
                                            : null,
                                    onPressedRightArrow: statisticObjectIndex > 0
                                        ? () {
                                            setState(() {
                                              statisticObjectIndex--;
                                            });
                                          }
                                        : null,
                                    initialValue: state.dateRangeContext,
                                    itemBuilder: (context) {
                                      return _dropDownItems
                                          .map((item) => PopupMenuItem(
                                              value: item['value'],
                                              enabled: true,
                                              child: Text(item['label'])))
                                          .toList();
                                    },
                                    onSelected: (value) {
                                      context.read<StatisticsCubit>().changeDateRangeFilter(value);
                                    })
                              ])),
                          Flexible(flex: 1, fit: FlexFit.tight, child: Container())
                        ]),
                        const DividerWithPillTitle(title: 'Income'),
                        customTableRow('Total', _statObject.incomeTotal.toString(), true),
                        const Divider(),
                        customTableRow('Notes', _statObject.notes.toString(), true),
                        const Divider(),
                        customTableRow('Coins', _statObject.coins.toString(), true),
                        const Divider(),
                        customTableRow('Card', _statObject.card.toString(), true),
                        const DividerWithPillTitle(title: 'Books'),
                        customTableRow('Total', _statObject.books.length.toString()),
                        const Divider(),
                        customTableRow('Books/other', _statObject.booksTotal.toString()),
                        const Divider(),
                        customTableRow('DropDowns', _statObject.dropdownsTotal.toString()),
                        const Divider(),
                        const DividerWithPillTitle(title: 'Others'),
                        customTableRow('Prayers', _statObject.prayers.toString()),
                        const Divider(),
                        customTableRow('Contacts', _statObject.contacts.toString()),
                        const Divider()
                      ]))));
        }));
  }

  customTableRow(String label, String value, [bool addCurrency = false]) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Expanded(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [Text(label, style: TextStyle(fontSize: 16.0.spMin))],
      )),
      SizedBox(width: 20.spMin),
      Expanded(
          child: Row(children: [
        Text(addCurrency ? '\$$value' : value, style: TextStyle(fontSize: 16.0.spMin))
      ]))
    ]);
  }
}
