import 'package:equatable/equatable.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';

class EventTeam extends Equatable {
  const EventTeam({required this.id, required this.eventId, required this.teamId, this.team});

  final String id;
  final String eventId;
  final String teamId;
  final Team? team;

  EventTeam.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        eventId = json['eventId'],
        teamId = json['teamId'],
        team = json['team'] != null ? Team.fromJson(json['team']) : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'teamId': teamId,
      };

  @override
  List<Object?> get props => [id, eventId, teamId, team];

  @override
  String toString() => 'EventTeam: id: $id, eventId: $eventId, teamId: $teamId, team: $team';
}
