import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/invitation_data.dart';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/data/models/team%20model/team_member.dart';
import 'package:lm_teams_app/data/models/user%20model/team_invitee.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/services/deep_link_service.dart';
import 'package:lm_teams_app/services/response-handlers/response-handlers.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../data/models/db_operation_object.dart';

class IGetTeamsFilter {
  IGetTeamsFilter({this.accountID, this.userID});
  final String? accountID;
  final String? userID;

  Map<String, dynamic> toJson() => {'accountID': accountID, 'userID': userID};
}

class TeamService {
  final _socketService = WebSocketService();

  Future<bool> createTeam(Team team) async {
    if (!_socketService.isConnected) {
      return false;
    }
    var response = await _socketService.sendAndWait(
        Message("Write", data: IDBOperationObject(table: DBTableType.team.name, data: team)));
    return response.success;
  }

  void updateTeam(Map<String, dynamic> params) {
    _socketService.send(
        Message('Write', data: IDBOperationObject(table: DBTableType.team.name, data: params)));
  }

  void deleteTeam(Team team) async {
    //delete team
    _socketService.send(Message('Delete', data: {'table': DBTableType.team.name, 'id': team.id}));
    //save to deleted teams
    _socketService.send(Message('Write',
        data: IDBOperationObject(table: DBTableType.deletedTeam.name, data: team)));
    //get child teams
    var response = await HandleTeamList(await _socketService.sendAndWait(Message('Read',
            data: IDBOperationObject(table: DBTableType.team.name, options: {
              'where': {'parent_id': team.id}
            }))))
        .run();
    //update child teams
    var teams = response.data ?? [];
    for (var team in teams) {
      updateTeam({'id': team.id, 'parent_id': '*'});
    }
  }

  addTeamMembers(List<TeamMember> members) async {
    for (var member in members) {
      _socketService.send(Message('Write',
          data: IDBOperationObject(table: DBTableType.teamMember.name, data: member)));
    }
  }

  Future<List<Team>> getAccountTeams(String accountId) async {
    if (!_socketService.isConnected) return [];
    var response = await HandleTeamList(await _socketService.sendAndWait(Message('Read',
            data: IDBOperationObject(table: DBTableType.team.name, options: {
              'where': {'_account_id': accountId}
            }))))
        .run();
    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  Future<List<Team>?> getUserTeams(String userId) async {
    if (!_socketService.isConnected) return null;
    var response = await HandleTeamList(
            await _socketService.sendAndWait(Message('ReadUserTeams', data: userId)))
        .run();

    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  Future<TeamInvitee> sendInvitation(
      User currentUser, InvitationData invitationData, Team team) async {
    var invitee = await invitationDataToTeamInvitee(currentUser, invitationData, team);
    _socketService.send(Message('SendInvitation',
        data: IDBOperationObject(table: DBTableType.teamInvitee.name, data: invitee)));
    return invitee;
  }

  void deleteInvitation(String inviteeID) {
    _socketService
        .send(Message('Delete', data: {'table': DBTableType.teamInvitee.name, 'id': inviteeID}));
  }

  Future<TeamInvitee> invitationDataToTeamInvitee(
      User currentUser, InvitationData invitationData, Team team) async {
    var invitee = TeamInvitee(
        id: invitationData.id,
        teamId: team.id,
        teamName: team.name,
        inviterId: currentUser.id,
        inviterName: currentUser.name,
        invitationMessage: invitationData.message,
        invitationLink: '',
        deliveryOptions: invitationData.deliveryOptions,
        firstName: invitationData.firstName,
        lastName: invitationData.lastName,
        email: invitationData.email,
        phoneNumber: invitationData.phoneNumber,
        isLeader: invitationData.asLeader);

    var lp = BranchLinkProperties(
      channel: 'google',
      feature: 'invitation',
    );

    var buo = BranchUniversalObject(
        canonicalIdentifier: 'flutter/branch',
        title: 'LE Teams App Invitation',
        expirationDateInMilliSec:
            DateTime.now().add(const Duration(days: 365)).millisecondsSinceEpoch,
        contentMetadata: BranchContentMetaData()..addCustomMetadata('invitee_id', invitee.id));
    invitee.invitationLink = await DeepLinkService().generateLink(buo, lp) ?? "";

    return invitee;
  }

  Future<TeamInvitee?> getTeamInvitee(String inviteeID) async {
    if (!_socketService.isConnected) return null;
    var response =
        await _socketService.sendAndWait(Message('GetInvitee', data: {'inviteeId': inviteeID}));
    if (response.success) {
      try {
        return TeamInvitee.fromJson(response.data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<Team?> getTeam(String teamID) async {
    if (_socketService.isConnected) {
      var response = await _socketService.sendAndWait(Message('GetTeam', data: teamID));
      response.handle(success: (data) {
        return data;
      }, error: (errorMessage) {
        print(errorMessage);
        return null;
      });
    }
    return null;
  }

  Future<List<TeamMember>> getTeamMembers(String teamID) async {
    if (!_socketService.isConnected) return [];
    var response = await HandleTeamMemberList(
            await _socketService.sendAndWait(Message('ReadTeamMembers', data: teamID)))
        .run();
    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  Future<List<TeamInvitee>> getTeamInvitees(String teamID) async {
    if (!_socketService.isConnected) return [];
    var response = await HandleTeamInviteesList(await _socketService.sendAndWait(Message('Read',
            data: IDBOperationObject(
                table: DBTableType.teamInvitee.name,
                options: IDBReadOptions(where: {'team_id': teamID})))))
        .run();
    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  Team? selectTeamContext(List<Team> teams, String selectedTeamID) {
    if (teams.isEmpty || selectedTeamID == '-') {
      return Team.empty;
    }
    var index = teams.indexWhere((team) => team.id == selectedTeamID);
    return index != -1 ? teams[index] : Team.empty;
  }

  removeTeamMember(String memberID) {
    _socketService.send(
      Message('RemoveTeamMember', data: memberID),
    );
  }

  removeTeamItem(String teamItemID) {
    _socketService.send(Message('RemoveTeamItem', data: teamItemID));
  }

  validateInvitedUserEmail(String email) async {
    if (!_socketService.isConnected) {
      return false;
    }
    var response = await _socketService.sendAndWait(Message('Read',
        data: IDBOperationObject(
            table: DBTableType.user.name,
            options: IDBReadOptions(where: {'email': email}, firstOnly: true))));
    return response.data == null;
  }

  Future<ETeamRole> getMyTeamRole(String userId, String teamId) async {
    if (!_socketService.isConnected) return ETeamRole.Member;
    if (teamId == '-') return ETeamRole.Member;
    var response = await _socketService.sendAndWait(Message('Read',
        data: IDBOperationObject(
            table: DBTableType.teamMember.name,
            options: IDBReadOptions(
                where: {'userId': userId, 'teamId': teamId},
                firstOnly: true,
                select: ['isLeader']))));
    var isLeader = response.data['isLeader'] ?? false;
    return isLeader ? ETeamRole.Leader : ETeamRole.Member;
  }
}
