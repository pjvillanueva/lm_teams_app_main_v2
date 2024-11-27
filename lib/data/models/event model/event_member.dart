import 'package:lm_teams_app/data/models/user%20model/user.dart';
import '../member model/member.dart';

class EventMember extends Member {
  const EventMember({
    required String id,
    required bool isLeader,
    required String userId,
    User? user,
    required this.eventId,
  }) : super(id: id, isLeader: isLeader, userId: userId, user: user);

  final String eventId;

  EventMember.fromJson(Map<String, dynamic> json)
      : eventId = json['eventId'],
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'id': id, 'eventId': eventId, 'isLeader': isLeader, 'userId': userId};

  @override
  List<Object?> get props => [id, eventId, isLeader, userId, user];

  @override
  String toString() =>
      'EventMember: id: $id, eventId: $eventId, isLeader: $isLeader, userId: $userId, user: $user';
}
