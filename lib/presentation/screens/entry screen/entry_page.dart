// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/cubits/entry_history_cubit.dart';
import 'package:lm_teams_app/logic/cubits/entry_page_cubit.dart';
import 'package:lm_teams_app/services/entry_service.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import 'package:lm_teams_app/presentation/screens/entry%20screen/entry_buttons.dart';
import 'package:lm_teams_app/presentation/screens/entry%20screen/entry_history_page.dart';
import 'package:lm_teams_app/presentation/screens/entry%20screen/inventory_item_grid.dart';
import 'package:lm_teams_app/presentation/widgets/toggle_tab.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class EntryPage extends StatefulWidget {
  const EntryPage({Key? key}) : super(key: key);

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final utils = UtilsService();
  final _timeService = TimeService();
  int activeTab = 1;

  @override
  Widget build(BuildContext context) {
    final _homeBloc = context.read<HomeScreenBloc>().state;
    return MultiBlocProvider(
        providers: [BlocProvider(create: (context) => EntryPageCubit())],
        child: BlocConsumer<EntryPageCubit, EntryPageState>(listener: (context, state) {
          setState(() {
            activeTab = state.isHistoryOpen ? 0 : 1;
          });
        }, builder: (context, state) {
          activeTab = state.isHistoryOpen ? 0 : 1;
          return Scaffold(
              body: Padding(
                  padding: EdgeInsets.all(10.0.spMin),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Card(
                        color: Colors.transparent,
                        elevation: 8.0,
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(150.0.spMin)),
                        child: ToggleTabs(
                            activeBgColors: [
                              [Theme.of(context).colorScheme.secondary],
                              [Theme.of(context).colorScheme.secondary]
                            ],
                            activeFgColor: Theme.of(context).colorScheme.onSurface,
                            inactiveBgColor: Theme.of(context).colorScheme.surface,
                            inactiveFgColor: Theme.of(context).colorScheme.onSurface,
                            initialLabelIndex: activeTab,
                            animate: true,
                            animationDuration: 250,
                            radiusStyle: true,
                            minHeight: 40.0.spMin,
                            cornerRadius: 20.0,
                            customWidths: [250.0.spMin, 75.0.spMin],
                            totalSwitches: 2,
                            labels: [
                              BlocBuilder<EntryHistoryCubit, EntryHistoryState>(
                                  builder: (context, state) {
                                return Row(mainAxisSize: MainAxisSize.min, children: [
                                  SizedBox(
                                      width: 20.0.spMin,
                                      height: 40.0.spMin,
                                      child: IconButton(
                                          icon: leftArrowButtonIcon(context, activeTab,
                                              state.dateIndex < state.historyObjects.length - 1),
                                          onPressed:
                                              state.dateIndex < state.historyObjects.length - 1
                                                  ? () {
                                                      BlocProvider.of<EntryPageCubit>(context)
                                                          .changeIsHistoryOpen(true);
                                                      BlocProvider.of<EntryHistoryCubit>(context)
                                                          .incrementDateIndex();
                                                    }
                                                  : null)),
                                  Expanded(
                                      child: Text(
                                          _timeService.formatRelativeDate(
                                              state.historyObjects.isNotEmpty
                                                  ? state.historyObjects[state.dateIndex].date
                                                  : DateTime.now()),
                                          style: TextStyle(
                                              fontSize: 14.0.spMin,
                                              color: activeTab == 0
                                                  ? Colors.white
                                                  : Theme.of(context).colorScheme.onSurface),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis)),
                                  SizedBox(
                                      width: 20.0.spMin,
                                      height: 40.0.spMin,
                                      child: IconButton(
                                          alignment: Alignment.center,
                                          icon: rightArrowButtonIcon(
                                              context, activeTab, state.dateIndex > 0),
                                          padding: const EdgeInsets.all(0.0),
                                          onPressed: state.dateIndex > 0
                                              ? () {
                                                  BlocProvider.of<EntryPageCubit>(context)
                                                      .changeIsHistoryOpen(true);
                                                  BlocProvider.of<EntryHistoryCubit>(context)
                                                      .decrementDateIndex();
                                                }
                                              : null))
                                ]);
                              }),
                              Text("ENTRY",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0.spMin,
                                      color: activeTab == 1
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.onSurface))
                            ],
                            onToggle: (index) {
                              BlocProvider.of<EntryPageCubit>(context)
                                  .changeIsHistoryOpen(index == 0 ? true : false);
                            })),
                    SizedBox(height: 10.spMin, width: 10.spMin),
                    Expanded(
                        child: Visibility(
                            visible: state.isHistoryOpen,
                            child: EntryHistoryScreen(
                                filter: EntryFilter(
                                    dateRangeStart: _homeBloc.dateRangeStart,
                                    dateRangeEnd: _homeBloc.dateRangeEnd)),
                            replacement: InventoryItemsGrid()))
                  ])),
              backgroundColor: Theme.of(context).colorScheme.background,
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Visibility(
                  visible: !state.isHistoryOpen,
                  child: EntryButtons(isVisible: state.pickedItems.isEmpty)));
        }));
  }
}

Icon leftArrowButtonIcon(BuildContext context, int activeTab, bool isAble) {
  return Icon(
    Icons.arrow_left,
    size: isAble ? 24.0.spMin : 20.0.spMin,
    color: activeTab == 0 ? isAbleColor(isAble) : Theme.of(context).colorScheme.onSurface,
  );
}

Icon rightArrowButtonIcon(BuildContext context, int activeTab, bool isAble) {
  return Icon(Icons.arrow_right,
      size: isAble ? 24.0.spMin : 20.0.spMin,
      color: activeTab == 0 ? isAbleColor(isAble) : Theme.of(context).colorScheme.onSurface);
}

Color isAbleColor(bool isAble) {
  return isAble ? Colors.white : Colors.grey.shade300;
}

Color isAbleColorInactive(BuildContext context, bool isAble) {
  return isAble ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade500;
}
