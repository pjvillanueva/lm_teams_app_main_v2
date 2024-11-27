import 'package:lm_teams_app/data/models/user%20model/user.dart';
import '../member model/member.dart';

class TeamMember extends Member {
  const TeamMember({
    required String id,
    required bool isLeader,
    required String userId,
    User? user,
    required this.teamId,
    required this.inviterId,
    this.inviter,
  }) : super(id: id, isLeader: isLeader, userId: userId, user: user);

  final String teamId;
  final String inviterId;
  final User? inviter;

  TeamMember.fromJson(Map<String, dynamic> json)
      : teamId = json['teamId'],
        inviterId = json['inviterId'],
        inviter = json['inviter'] != null ? User.fromJson(json['inviter']) : null,
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      {'id': id, 'teamId': teamId, 'isLeader': isLeader, 'userId': userId, 'inviterId': inviterId};

  static const empty =
      TeamMember(id: '-', isLeader: false, userId: '-', teamId: '-', inviterId: '');

  @override
  List<Object?> get props => [id, isLeader, userId, teamId, inviterId, user, inviter];

  @override
  String toString() =>
      'TeamMember: id: $id, isLeader: $isLeader, userId: $userId, teamId: $teamId, inviterId: $inviterId, user: $user, inviter: $inviter';
}
