// ignore_for_file: hash_and_equals
import 'package:equatable/equatable.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import '../../logic/cubits/users_cubit.dart';

// ignore: must_be_immutable
class AccountMemberRole extends Equatable {
  AccountMemberRole({required this.id, required this.role, required this.ownerId});
  final String id;
  AccountRole role;
  final String ownerId;

  @override
  List<Object?> get props => [id, role, ownerId];

  static AccountMemberRole empty = AccountMemberRole(id: '-', role: AccountRole.le, ownerId: '-');

  AccountMemberRole.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        role = stringToEnum<AccountRole>(AccountRole.values, json['roleId']),
        ownerId = json['_ownerId'];

  Map<String, dynamic> toJson() => {'id': id, 'roleId': role.name, '_ownerId': ownerId};

  @override
  String toString() => "AccountMemberRole( id: $id, roleId: ${role.name}, _ownerId: $ownerId)";
}
