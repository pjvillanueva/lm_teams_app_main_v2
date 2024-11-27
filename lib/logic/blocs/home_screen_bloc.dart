// ignore_for_file: unnecessary_string_interpolations
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lm_teams_app/data/models/event%20model/event.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/services/event_service.dart';
import 'package:lm_teams_app/services/team_service.dart';

enum DateRangeConfiguration { last7days, last30days, customRange }

enum ETeamRole { Leader, Member }

class HomeScreenState extends Equatable {
  const HomeScreenState({
    required this.team,
    required this.event,
    required this.teams,
    required this.events,
    required this.dateRangeStart,
    required this.dateRangeEnd,
    required this.dateRangeConfiguration,
  });
  final Team team;
  final Event event;
  final List<Team> teams;
  final List<Event> events;
  final DateTime dateRangeStart;
  final DateTime dateRangeEnd;
  final DateRangeConfiguration dateRangeConfiguration;

  @override
  List<Object?> get props => [team, teams, event, events, dateRangeStart, dateRangeEnd];

  @override
  String toString() =>
      "HomeScreenState: team: $team,,dateRangeStart: $dateRangeStart, dateRangeEnd: $dateRangeEnd";

  HomeScreenState copyWith(
      {Team? team,
      List<Team>? teams,
      Event? event,
      List<Event>? events,
      DateTime? dateRangeStart,
      DateTime? dateRangeEnd,
      DateRangeConfiguration? dateRangeConfiguration}) {
    return HomeScreenState(
        team: team ?? this.team,
        teams: teams ?? this.teams,
        event: event ?? this.event,
        events: events ?? this.events,
        dateRangeStart: dateRangeStart ?? this.dateRangeStart,
        dateRangeEnd: dateRangeEnd ?? this.dateRangeEnd,
        dateRangeConfiguration: dateRangeConfiguration ?? this.dateRangeConfiguration);
  }

  Map<String, dynamic> toJson() => {
        'team': team,
        'teams': teams,
        'event': event,
        'events': events,
        'dateRangeStart': dateRangeStart.toIso8601String(),
        'dateRangeEnd': dateRangeEnd.toIso8601String(),
        'dateRangeConfiguration': dateRangeConfiguration.name,
      };

  HomeScreenState.fromJson(Map<String, dynamic> json)
      : team = Team.fromJson(json['team']),
        teams = List.from(json['teams']).map((s) => Team.fromJson(s)).toList(),
        event = Event.fromJson(json['event']),
        events = List.from(json['events']).map((e) => Event.fromJson(e)).toList(),
        dateRangeStart = DateTime.parse(json['dateRangeStart']),
        dateRangeEnd = DateTime.parse(json['dateRangeEnd']),
        dateRangeConfiguration = getConfiguration(json["dateRangeConfiguration"]);

  List<Map<String, dynamic>> get mappedTeamList {
    List<Map<String, dynamic>> list = [
      {'value': Team.empty.id, 'label': Team.empty.name}
    ];
    if (teams.isNotEmpty) {
      for (var team in teams) {
        list.add({'value': '${team.id}', 'label': '${team.name}'});
      }
    }
    return list;
  }

  List<Map<String, dynamic>> get mappedEventList {
    List<Map<String, dynamic>> list = [
      {'value': Event.empty.id, 'label': Event.empty.name}
    ];
    if (events.isNotEmpty) {
      for (var event in events) {
        list.add({'value': '${event.id}', 'label': '${event.name}'});
      }
    }
    return list;
  }

  String get dateRangeString {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String formattedStartDate = formatter.format(dateRangeStart);
    final String formattedEndDate = formatter.format(dateRangeEnd);
    return "$formattedStartDate - $formattedEndDate";
  }
}

DateRangeConfiguration getConfiguration(String text) {
  switch (text) {
    case "last7days":
      return DateRangeConfiguration.last7days;
    case "last30days":
      return DateRangeConfiguration.last30days;
    case "customRange":
      return DateRangeConfiguration.customRange;
    default:
      return DateRangeConfiguration.last7days;
  }
}

//events
abstract class HomeScreenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetTeams extends HomeScreenEvent {
  GetTeams({required this.userID});
  final String userID;

  @override
  List<Object?> get props => [userID];
}

class GetEvents extends HomeScreenEvent {
  GetEvents({required this.userID});
  final String userID;

  @override
  List<Object?> get props => [userID];
}

class SetDateRange extends HomeScreenEvent {
  SetDateRange({required this.dateRangeStart, required this.dateRangeEnd, required this.config});
  final DateTime dateRangeStart;
  final DateTime dateRangeEnd;
  final DateRangeConfiguration config;
  @override
  List<Object?> get props => [dateRangeStart, dateRangeEnd, config];
}

class InitialEvent extends HomeScreenEvent {
  InitialEvent({required this.userID, required this.context});

  final String userID;
  final BuildContext context;

  @override
  List<Object?> get props => [userID];
}

class AddTeam extends HomeScreenEvent {
  AddTeam({required this.team});
  final Team team;

  @override
  List<Object?> get props => [team];
}

class AddEvent extends HomeScreenEvent {
  AddEvent({required this.event});
  final Event event;

  @override
  List<Object?> get props => [event];
}

class SelectTeam extends HomeScreenEvent {
  SelectTeam({required this.teamID});
  final String teamID;
  @override
  List<Object?> get props => [teamID];
}

class SelectEvent extends HomeScreenEvent {
  SelectEvent({required this.eventID});
  final String eventID;
  @override
  List<Object?> get props => [eventID];
}

class FetchUserTeamsAndEvents extends HomeScreenEvent {
  FetchUserTeamsAndEvents({required this.userID});
  final String userID;
  @override
  List<Object?> get props => [userID];
}

//bloc
class HomeScreenBloc extends HydratedBloc<HomeScreenEvent, HomeScreenState> {
  HomeScreenBloc()
      : super(HomeScreenState(
            team: Team.empty,
            teams: const [],
            event: Event.empty,
            events: const [],
            dateRangeStart: DateTime.now().subtract(const Duration(days: 7)),
            dateRangeEnd: DateTime.now(),
            dateRangeConfiguration: DateRangeConfiguration.last7days)) {
    on<HomeScreenEvent>(_onEvent);
  }

  final _teamService = TeamService();
  final _eventService = EventService();

  _onEvent(HomeScreenEvent event, Emitter<HomeScreenState> emit) async {
    if (event is InitialEvent) {
      var config = state.dateRangeConfiguration;
      late DateTime dateRangeStart = state.dateRangeStart;
      late DateTime dateRangeEnd = DateTime.now();

      switch (config) {
        case DateRangeConfiguration.last30days:
          dateRangeStart = DateTime.now().subtract(const Duration(days: 30));
          break;
        default:
          dateRangeStart = DateTime.now().subtract(const Duration(days: 7));
      }

      var teams = await _teamService.getUserTeams(event.userID);
      var events = await _eventService.getUserEvents(event.userID);

      emit(state.copyWith(
          dateRangeStart: dateRangeStart,
          dateRangeEnd: dateRangeEnd,
          teams: teams,
          events: events));

      //update selected team and event
      emit(state.copyWith(
          team: _teamService.selectTeamContext(state.teams, state.team.id),
          event: _eventService.selectEventContext(state.events, state.event.id)));
    } else if (event is SetDateRange) {
      emit(state.copyWith(
          dateRangeStart: event.dateRangeStart,
          dateRangeEnd: event.dateRangeEnd,
          dateRangeConfiguration: event.config));
    } else if (event is SelectTeam) {
      if (event.teamID != '-') {
        for (var team in state.teams) {
          if (team.id == event.teamID) {
            emit(state.copyWith(team: team));
          }
        }
      } else {
        emit(state.copyWith(team: Team.empty));
      }
    } else if (event is SelectEvent) {
      if (event.eventID != '-') {
        for (var _event in state.events) {
          if (_event.id == event.eventID) {
            emit(state.copyWith(event: _event));
          }
        }
      } else {
        emit(state.copyWith(event: Event.empty));
      }
    } else if (event is FetchUserTeamsAndEvents) {
      var teams = await _teamService.getUserTeams(event.userID);
      var events = await _eventService.getUserEvents(event.userID);

      emit(state.copyWith(teams: teams, events: events));
    } else if (event is AddTeam) {
      emit(state.copyWith(teams: [...state.teams]..add(event.team)));
    } else if (event is AddEvent) {
      emit(state.copyWith(events: [...state.events]..add(event.event)));
    }
  }

  @override
  Map<String, dynamic> toJson(HomeScreenState state) {
    return state.toJson();
  }

  @override
  HomeScreenState fromJson(Map<String, dynamic> json) {
    return HomeScreenState.fromJson(json);
  }
}
