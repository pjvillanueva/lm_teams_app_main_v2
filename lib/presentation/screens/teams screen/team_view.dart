import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/blocs/account_bloc.dart';
import 'package:lm_teams_app/logic/cubits/statistics_tab_cubit.dart';
import 'package:lm_teams_app/logic/cubits/teams_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/confirmation_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/image_options.dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/rename_dialog.dart';
import 'package:lm_teams_app/presentation/screens/teams%20screen/team_inventory_tab_view.dart';
import 'package:lm_teams_app/presentation/screens/teams%20screen/team_members_tab_view.dart';
import 'package:lm_teams_app/presentation/screens/teams%20screen/team_statistics_tab_view.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/team_service.dart';
import 'package:lm_teams_app/services/uploader_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import '../../../data/models/member model/member.dart';
import '../../../logic/blocs/user_bloc.dart';

class TeamView extends StatefulWidget {
  const TeamView({Key? key, required this.team}) : super(key: key);
  final Team team;
  @override
  State<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<TeamView> {
  final int currentDateTimeRange = 2;
  final List<Map<String, dynamic>> _dropDownItems = [
    {'value': 1, 'label': 'Rename Team', 'enabled': true},
    {'value': 2, 'label': 'Delete Team', 'enabled': true}
  ];
  final _teamService = TeamService();
  final _uploaderService = UploaderService();
  final _utils = UtilsService();

  File? imageFile;

  @override
  Widget build(BuildContext context) {
    final AccountRole _accountMemberRole = context.read<AccountBloc>().state.role;
    final User _currentUser = context.read<UserBloc>().state.user;
    return BlocProvider(
        create: (context) => StatisticsTabCubit(),
        child: AppFrame(
            title: 'My Team',
            padding: 0,
            actions: [
              BlocBuilder<StatisticsTabCubit, StatisticsTabState>(builder: (context, state) {
                return Visibility(
                    visible: _isAdminOrLeader(_currentUser, _accountMemberRole, state.members),
                    child: PopupMenuButton(
                        icon: Icon(Icons.more_vert, size: 24.0.spMin, color: Colors.white),
                        itemBuilder: (context) {
                          return _dropDownItems
                              .map((item) => PopupMenuItem(
                                  value: item['value'],
                                  enabled: isOptionEnabled(_currentUser, _accountMemberRole,
                                      item['value'], state.members),
                                  child: Text(item['label'])))
                              .toList();
                        },
                        onSelected: (value) async {
                          if (value != null) {
                            switch (value) {
                              case 1:
                                //rename team
                                var newName = await showRenameDialog(
                                    context, 'Rename Team', widget.team.name);
                                if (newName == null || newName == widget.team.name) {
                                  showAppSnackbar(context, 'No changes made', isError: true);
                                  return;
                                }
                                var _updates = {'id': widget.team.id, 'name': newName};
                                _teamService.updateTeam(_updates);
                                setState(() {
                                  widget.team.name = newName;
                                });
                                break;
                              case 2:
                                // delete team
                                try {
                                  var proceedDelete = await showDeleteConfirmation(context,
                                      'Delete Team', 'Are you sure you want to delete this team?');
                                  if (proceedDelete) {
                                    await context.read<TeamsCubit>().deleteTeam(widget.team);
                                    showAppSnackbar(context, 'Team deleted');
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  print(e);
                                  showAppSnackbar(context, 'Failed to delete team', isError: true);
                                }
                                break;
                              default:
                            }
                          }
                        }));
              })
            ],
            content: SizedBox(
                height: MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top,
                child: Column(children: [
                  Container(
                      height: 100.spMin,
                      padding: EdgeInsets.all(10.0.spMin),
                      child: Row(children: [
                        Avatar(
                            placeholder: Icon(Icons.group, size: 30.0.spMin),
                            size: Size(80.spMin, 100.spMin),
                            image: widget.team.image,
                            imageFile: imageFile,
                            onTapPicture: () async {
                              File? _imageFile = imageFile ??
                                  (widget.team.image != null
                                      ? await _utils.urlToFile(widget.team.image!.url)
                                      : null);
                              File? newFile =
                                  await showImageOptionsDialog(context, imageFile: _imageFile);
                              if (newFile != null) {
                                showLoaderDialog(context);
                                var imageObj = await _uploaderService.uploadAndGetImageObj(newFile);

                                var _updates = {'id': widget.team.id, 'image': imageObj};

                                _teamService.updateTeam(_updates);

                                Navigator.pop(context);
                                setState(() {
                                  imageFile = newFile;
                                });
                              }
                            }),
                        SizedBox(width: 10.0.spMin),
                        Flexible(
                            flex: 1,
                            child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Column(children: [
                                  Text(widget.team.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 22.spMin)),
                                  Text('', style: TextStyle(fontSize: 16.spMin))
                                ])))
                      ])),
                  Flexible(
                      flex: 1,
                      child: DefaultTabController(
                          length: 3,
                          child: Column(children: [
                            TabBar(
                                tabAlignment: TabAlignment.start,
                                isScrollable: true,
                                indicator: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surface,
                                    shape: BoxShape.rectangle),
                                labelColor: Theme.of(context).colorScheme.onSurface,
                                indicatorWeight: 2.0,
                                padding: EdgeInsets.zero,
                                indicatorPadding: EdgeInsets.zero,
                                labelPadding: EdgeInsets.zero,
                                tabs: [
                                  SizedBox(width: 100.spMin, child: const Tab(text: 'Statistics')),
                                  SizedBox(width: 100.spMin, child: const Tab(text: 'Members')),
                                  SizedBox(width: 100.spMin, child: const Tab(text: 'Inventory')),
                                ]),
                            Expanded(
                                child: TabBarView(children: [
                              TeamStatisticsTabView(team: widget.team),
                              TeamMembersTabView(widget.team),
                              TeamInventoryTabView(team: widget.team)
                            ]))
                          ])))
                ]))));
  }
}

bool _isAdminOrLeader(User user, AccountRole role, List<Member> members) {
  if (role == AccountRole.admin || role == AccountRole.owner) return true;
  if (members.isEmpty) return false;

  var index = members.indexWhere((member) => member.user?.id == user.id);
  if (index != -1) {
    return members[index].isLeader;
  }
  return false;
}

bool isOptionEnabled(User user, AccountRole role, int value, List<Member> members) {
  if (value == 1) return true;
  return _isAdminOrLeader(user, role, members);
}
