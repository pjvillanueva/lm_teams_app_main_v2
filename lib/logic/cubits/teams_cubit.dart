import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/services/team_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

class Parent {
  Parent({required this.self, required this.children});
  final Team self;
  List<Parent> children;
}

class TeamsState {
  TeamsState({required this.teams, required this.filteredTeams});

  List<Team> teams;
  List<Team> filteredTeams;

  TeamsState copyWith({List<Team>? teams, List<Team>? filteredTeams}) {
    return TeamsState(
      teams: teams ?? this.teams,
      filteredTeams: filteredTeams ?? this.filteredTeams,
    );
  }

  @override
  String toString() => "TeamsState";

  List<Parent> get parentObjects {
    final topParents = teams
        .where((top) => top.parentId == '*')
        .map((top) => Parent(self: top, children: []))
        .toList();
    return _createItemTree(topParents, teams);
  }

  List<Parent> getSearchedParentsObjects(String text) {
    var _teams = teams;
    var filteredTeams =
        _teams.where((team) => team.name.toLowerCase().contains(text.toLowerCase())).toList();
    var parentTeams = filteredTeams.map((team) => Parent(self: team, children: [])).toList();
    return _createItemTree(parentTeams, teams);
  }

  List<Parent> _createItemTree(List<Parent> topParents, List<Team> teams) {
    final List<Parent> nextParents = [];

    for (final parent in topParents) {
      final children = teams
          .where((team) => team.parentId == parent.self.id)
          .map((child) => Parent(self: child, children: []))
          .toList();

      if (children.isNotEmpty) {
        parent.children = children;
        nextParents.addAll(children);
      }
    }

    if (nextParents.isNotEmpty) {
      _createItemTree(nextParents, teams);
    }
    return topParents;
  }
}

class TeamsCubit extends Cubit<TeamsState> {
  TeamsCubit() : super(TeamsState(teams: [], filteredTeams: []));

  final _socketService = WebSocketService();
  final _teamService = TeamService();

  Future<void> getAccountTeams(String accountId) async {
    if (_socketService.isConnected && !isClosed) {
      var teams = await _teamService.getAccountTeams(accountId);
      if (teams.isNotEmpty) {
        emit(state.copyWith(teams: teams));
      }
    } else {
      print("Unable to get teams. No internet connection");
    }
  }

  Future<void> addTeam(Team team) async {
    if (!isClosed) {
      final teams = state.teams;
      teams.add(team);
      emit(state.copyWith(teams: teams));
    }
  }

  Future<void> deleteTeam(Team team) async {
    //remove in state
    emit(state.copyWith(
        teams: [...state.teams]..remove(team),
        filteredTeams: [...state.filteredTeams]..remove(team)));
    //remove in db
    _teamService.deleteTeam(team);
  }

  Future<void> searchStatusChanged(bool status) async {
    emit(state.copyWith(filteredTeams: !status ? [] : null));
  }

  searchTeam(String name) {
    var teams = state.teams;
    var filteredTeams = teams
        .where((element) => element.name.toLowerCase().startsWith(name.toLowerCase()))
        .toList();
    emit(state.copyWith(filteredTeams: filteredTeams));
  }
}
