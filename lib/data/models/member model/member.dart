import 'package:equatable/equatable.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';

class Member extends Equatable {
  const Member({
    required this.id,
    required this.isLeader,
    required this.userId,
    this.user,
  });

  final String id;
  final bool isLeader;
  final String userId;
  final User? user;

  Member.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        isLeader = json['isLeader'],
        userId = json['userId'],
        user = json['user'] != null ? User.fromJson(json['user']) : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'isLeader': isLeader,
        'userId': userId,
        'user': user,
      };

  static const empty = Member(id: '-', isLeader: false, userId: '-');

  String get firstName => user?.firstName ?? 'Unknown';
  String get name => user?.name ?? 'Unknown';
  String get initials => user?.initials;
  String get role => isLeader ? 'Leader' : 'Member';

  @override
  List<Object?> get props => [id, isLeader, userId, user];

  @override
  String toString() => "Member: id: $id, isLeader: $isLeader, userId: $userId, user: $user";
}
