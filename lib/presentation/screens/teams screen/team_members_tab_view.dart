import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/team%20model/team_member.dart';
import 'package:lm_teams_app/data/models/user%20model/team_invitee.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/presentation/dialogs/invitation_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';
import 'package:lm_teams_app/services/team_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import '../../../data/models/team model/team.dart';

// ignore: must_be_immutable
class TeamMembersTabView extends StatefulWidget {
  const TeamMembersTabView(
    this.team, {
    Key? key,
  }) : super(key: key);

  final Team team;
  @override
  State<TeamMembersTabView> createState() => _TeamMembersTabViewState();
}

class _TeamMembersTabViewState extends State<TeamMembersTabView> {
  final _teamService = TeamService();
  final _utils = UtilsService();
  final List<Map<String, dynamic>> _memberDropDownItems = [
    {'value': 1, 'label': 'Remove Member'}
  ];
  final List<Map<String, dynamic>> _inviteeDropDownItems = [
    {'value': 1, 'label': 'Cancel Invitation'},
    {'value': 2, 'label': 'Copy Invitation Link'}
  ];

  List<TeamMember> teamMembers = [];
  List<TeamInvitee> teamInvitees = [];
  bool isAdminOrLeader = true;

  @override
  void initState() {
    getTeamMembersAndInvitees(widget.team.id);
    super.initState();
  }

  getTeamMembersAndInvitees(String teamId) async {
    final List<TeamMember> _teamMembers = await _teamService.getTeamMembers(teamId);
    final List<TeamInvitee> _teamInvitees = await _teamService.getTeamInvitees(teamId);

    if (mounted) {
      setState(() {
        teamMembers = _teamMembers;
        teamInvitees = _teamInvitees;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _currentUser = context.read<UserBloc>().state.user;
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton: IconAndTextButton(
            icon: Icons.person_add,
            buttonName: 'INVITE MEMBER',
            onPressed: () async {
              var invitation =
                  await showInvitationDialog(context, enableRoleField: isAdminOrLeader);
              if (invitation != null) {
                var _invitee = await _teamService.sendInvitation(
                    context.read<UserBloc>().state.user, invitation, widget.team);
                setState(() {
                  teamInvitees.add(_invitee);
                });
              }
            }),
        body: Container(
            color: Theme.of(context).colorScheme.surface,
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(20.0.spMin),
                    child: Column(mainAxisSize: MainAxisSize.max, children: [
                      Visibility(
                          visible: teamInvitees.isNotEmpty,
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const SubtitleInDivider(subtitle: 'INVITED'),
                            ListView.builder(
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: teamInvitees.length,
                                itemBuilder: (context, index) {
                                  TeamInvitee invitee = teamInvitees[index];
                                  return Card(
                                      color: Theme.of(context).colorScheme.surface,
                                      child: ListTile(
                                          title: Text(invitee.name),
                                          subtitle: Text(
                                              'Invited by ${invitee.inviterId == _currentUser.id ? 'you' : invitee.inviterName}'),
                                          trailing: PopupMenuButton(
                                              icon: Icon(Icons.more_vert, size: 24.0.spMin),
                                              itemBuilder: (context) {
                                                return _inviteeDropDownItems
                                                    .map((item) => PopupMenuItem(
                                                        value: item['value'],
                                                        child: Text(item['label'])))
                                                    .toList();
                                              },
                                              onSelected: (value) async {
                                                if (value != null) {
                                                  switch (value) {
                                                    case 1:
                                                      //delete invitation
                                                      _teamService.deleteInvitation(invitee.id);
                                                      setState(() {
                                                        teamInvitees.removeAt(index);
                                                      });
                                                      break;
                                                    case 2:
                                                      //copy invitation link
                                                      var copied = await _utils
                                                          .copyToClipboard(invitee.invitationLink);
                                                      if (copied) {
                                                        showAppSnackbar(context, 'Link copied');
                                                      }
                                                  }
                                                }
                                              })));
                                })
                          ])),
                      Visibility(
                          visible: teamMembers.isNotEmpty,
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const SubtitleInDivider(subtitle: 'MEMBERS'),
                            ListView.builder(
                                scrollDirection: Axis.vertical,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: teamMembers.length,
                                itemBuilder: (context, index) {
                                  TeamMember teamMember = teamMembers[index];
                                  return Card(
                                      color: Theme.of(context).colorScheme.surface,
                                      child: ListTile(
                                          leading: Avatar(
                                              isCircle: true,
                                              size: Size(40.0.spMin, 40.0.spMin),
                                              image: teamMember.user?.image,
                                              placeholder: Text(teamMember.user?.initials,
                                                  style: TextStyle(fontSize: 16.0.spMin))),
                                          trailing: Visibility(
                                              visible: isAdminOrLeader,
                                              child: PopupMenuButton(
                                                  icon: Icon(Icons.more_vert, size: 24.0.spMin),
                                                  itemBuilder: (context) {
                                                    return _memberDropDownItems
                                                        .map((item) => PopupMenuItem(
                                                            value: item['value'],
                                                            child: Text(item['label'])))
                                                        .toList();
                                                  },
                                                  onSelected: (value) {
                                                    if (value != null) {
                                                      switch (value) {
                                                        //remove team member
                                                        case 1:
                                                          _teamService
                                                              .removeTeamMember(teamMember.id);
                                                          setState(() {
                                                            teamMembers.removeWhere(
                                                                (obj) => obj.id == teamMember.id);
                                                          });
                                                          break;
                                                      }
                                                    }
                                                  })),
                                          title: Text(teamMember.name),
                                          subtitle: Text(teamMember.role)));
                                })
                          ]))
                    ])))));
  }
}
