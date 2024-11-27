import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/data/models/invitation_data.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/data/models/team%20model/team_member.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/presentation/dialogs/item_form_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/services/items_service.dart';
import 'package:lm_teams_app/services/team_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import '../../data/constants/constants.dart';

class TeamFormState {
  TeamFormState({
    this.imageFile,
    required this.items,
    required this.selectedLeaders,
    required this.selectedMembers,
    required this.invitations,
  });

  File? imageFile;
  List<InventoryItem> items;
  List<User> selectedLeaders;
  List<User> selectedMembers;
  List<InvitationData> invitations;

  TeamFormState copyWith({
    File? imageFile,
    List<InventoryItem>? items,
    List<User>? selectedLeaders,
    List<User>? selectedMembers,
    List<InvitationData>? invitations,
  }) {
    return TeamFormState(
        imageFile: imageFile ?? this.imageFile,
        items: items ?? this.items,
        selectedLeaders: selectedLeaders ?? this.selectedLeaders,
        selectedMembers: selectedMembers ?? this.selectedMembers,
        invitations: invitations ?? this.invitations);
  }

  List<User> get selectedUsers {
    return selectedLeaders + selectedMembers;
  }

  List<String> get invitationIDs {
    List<String> invitationIDs = [];
    for (var i in invitations) {
      invitationIDs.add(i.id);
    }
    return invitationIDs;
  }

  List<String> get itemCodes {
    return items.map((item) => item.code).toList();
  }

  @override
  String toString() => "TeamFormState: [imageFile: $imageFile, items: $items]";
}

class TeamFormCubit extends Cubit<TeamFormState> {
  TeamFormCubit()
      : super(TeamFormState(items: [], selectedLeaders: [], selectedMembers: [], invitations: []));

  final _teamService = TeamService();
  final _utils = UtilsService();
  final _itemService = ItemService();

  //form actions
  addImageFile(File? imageFile) {
    emit(state.copyWith(imageFile: imageFile));
  }

  addLeaders(List<User> users) {
    emit(state.copyWith(selectedLeaders: users));
  }

  removeLeader(User user) {
    emit(state.copyWith(
        invitations: [...state.invitations]..removeWhere((inv) => inv.id == user.id),
        selectedLeaders: [...state.selectedLeaders]..remove(user)));
  }

  addMembers(List<User> users) {
    emit(state.copyWith(selectedMembers: users));
  }

  removeMember(User user) {
    emit(state.copyWith(
        invitations: [...state.invitations]..removeWhere((inv) => inv.id == user.id),
        selectedMembers: [...state.selectedMembers]..remove(user)));
  }

  addItem(InventoryItem item) {
    emit(state.copyWith(items: [...state.items]..add(item)));
  }

  removeItem(InventoryItem item) {
    emit(state.copyWith(items: [...state.items]..remove(item)));
  }

  addInvitation(InvitationData invitation) {
    emit(state.copyWith(invitations: [...state.invitations]..add(invitation)));
  }

  Future<Team?> saveTeam(
      BuildContext context, GlobalKey<FormState> formKey, String teamName, String parentID) async {
    if (!formKey.currentState!.validate()) {
      return null;
    }
    var user = context.read<UserBloc>().state.user;
    var imageObj = await uploadImage(context, state.imageFile);

    showLoaderDialog(context, loadingText: 'Saving team...');
    var team = Team(id: _utils.uid(), name: teamName, image: imageObj, parentId: parentID);
    var isSuccess = await _teamService.createTeam(team);

    if (isSuccess) {
      await sendInvitations(context, team, user);
      await saveTeamMembers(context, team);
      await saveTeamItems(team.id);
      return team;
    } else {
      return null;
    }
  }

  Future<void> sendInvitations(BuildContext context, Team team, User user) async {
    for (var invitation in state.invitations) {
      _teamService.sendInvitation(user, invitation, team);
    }
  }

  Future<void> saveTeamMembers(BuildContext context, Team team) async {
    var _user = context.read<UserBloc>().state.user;
    List<TeamMember> teamMembers = [];

    for (var user in state.selectedLeaders) {
      if (!state.invitationIDs.contains(user.id)) {
        var teamLeader = TeamMember(
            id: _utils.uid(),
            teamId: team.id,
            isLeader: true,
            userId: user.id,
            inviterId: _user.id);

        teamMembers.add(teamLeader);
      }
    }
    for (var user in state.selectedMembers) {
      if (!state.invitationIDs.contains(user.id)) {
        var teamMember = TeamMember(
            id: _utils.uid(),
            teamId: team.id,
            isLeader: false,
            userId: user.id,
            inviterId: _user.id);

        teamMembers.add(teamMember);
      }
    }

    _teamService.addTeamMembers(teamMembers);
  }

  Future<void> saveTeamItems(String teamID) async {
    for (var item in state.items) {
      item.teamId = teamID;
      _itemService.saveInventoryItem(DBTableType.teamItem, item);
    }
  }
}
