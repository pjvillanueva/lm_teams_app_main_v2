import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/member%20model/member.dart';
import 'package:lm_teams_app/data/models/statistics%20model/statistics_filter.dart';
import 'package:lm_teams_app/data/models/statistics%20model/statistics_object.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/logic/cubits/statistics_tab_cubit.dart';
import 'package:lm_teams_app/presentation/widgets/tables.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';
import '../../widgets/filters/date_range_filter.dart';
import '../../widgets/filters/member_filter.dart';

class TeamStatisticsTabView extends StatefulWidget {
  const TeamStatisticsTabView({Key? key, required this.team}) : super(key: key);
  final Team team;

  @override
  State<TeamStatisticsTabView> createState() => _TeamStatisticsTabViewState();
}

class _TeamStatisticsTabViewState extends State<TeamStatisticsTabView> {
  @override
  initState() {
    context.read<StatisticsTabCubit>().initialEvent(true, StatisticsFilter(teamId: widget.team.id));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsTabCubit, StatisticsTabState>(builder: (context, state) {
      return Container(
          color: Theme.of(context).colorScheme.surface,
          padding: EdgeInsets.all(10.0.spMin),
          child: CustomScrollView(slivers: [
            SliverAppBar(
                title: SizedBox(
                    height: 56.spMin,
                    child: Row(children: [
                      Flexible(
                          child: MemberFilter<Member>(state.members, state.selectedMembers,
                              (selectedMembers) {
                        if (selectedMembers != null) {
                          BlocProvider.of<StatisticsTabCubit>(context).updateSelectedMembers(
                              selectedMembers, StatisticsFilter(teamId: widget.team.id));
                        }
                      })),
                      SizedBox(width: 10.spMin),
                      Flexible(child: DateRangeFilter((range) {
                        BlocProvider.of<StatisticsTabCubit>(context)
                            .updateDateTimeRange(range, StatisticsFilter(teamId: widget.team.id));
                      }))
                    ])),
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.surface),
            SliverList(
                delegate: SliverChildListDelegate([
              SizedBox(height: 10.0.spMin),
              Padding(
                  padding: EdgeInsets.all(20.0.spMin),
                  child: Visibility(
                      visible: state.selectedMembers.isNotEmpty,
                      child: Column(children: [
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          const TextAboveDivider(
                              leadingText: 'Sales', leadingFontWeight: FontWeight.bold),
                          ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: state.statisticsObjects.length,
                              itemBuilder: (context, index) {
                                StatisticsObject statisticsObject = state.statisticsObjects[index];

                                return TextAboveDivider(
                                    leadingText:
                                        state.getMember(statisticsObject.ownerId ?? '').name,
                                    trailingText: '\$' + statisticsObject.incomeTotal.toString(),
                                    leadingFontSize: 15.0.spMin,
                                    trailingFontSize: 15.0.spMin);
                              })
                        ]),
                        Column(children: [
                          const TextAboveDivider(
                              leadingText: 'Books & Inventory',
                              leadingFontWeight: FontWeight.bold,
                              dividerThickness: 0.0),
                          AppStatisticsTable(
                              tableData: state.tableData,
                              fixedColWidth: 50.0.spMin,
                              cellHeight: 30.0.spMin,
                              cellWidth: getCellWidth(state.selectedMembers.length),
                              borderColor: Colors.grey.shade300,
                              cellMargin: 10.0,
                              cellSpacing: 10.0)
                        ]),
                        SizedBox(height: 10.0.spMin),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          const TextAboveDivider(
                              leadingText: 'Prayers', leadingFontWeight: FontWeight.bold),
                          ListView.builder(
                              scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: state.statisticsObjects.length,
                              itemBuilder: (context, index) {
                                StatisticsObject statisticsObject = state.statisticsObjects[index];

                                return TextAboveDivider(
                                    leadingText:
                                        state.getMemberName(statisticsObject.ownerId ?? ''),
                                    trailingText: statisticsObject.prayers.toString(),
                                    leadingFontSize: 15.0.spMin,
                                    trailingFontSize: 15.0.spMin);
                              })
                        ])
                      ]),
                      replacement: Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.warning_rounded,
                            size: 100.spMin, color: Theme.of(context).colorScheme.onSurface),
                        Text(state.members.isNotEmpty ? 'No selected members' : 'No team members',
                            style: TextStyle(
                                fontSize: 16.0.spMin,
                                color: Theme.of(context).colorScheme.onSurface))
                      ]))))
            ]))
          ]));
    });
  }
}

double getCellWidth(int memberlength) {
  const availableWidth = 260;
  final calculatedWidth = availableWidth / memberlength;
  return calculatedWidth.clamp(30.0, availableWidth.toDouble());
}
