import 'dart:convert';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/data/models/user%20model/user_update.dart';
import 'package:lm_teams_app/services/user_service.dart';
import '../../data/constants/constants.dart';
import '../../data/models/account_member_role.dart';

class UsersState {
  UsersState(
      {required this.users,
      required this.accountMemberRoles,
      required this.filteredUsers,
      this.isLoading = false});
  List<User> users;
  Map<String, AccountMemberRole> accountMemberRoles;
  List<User> filteredUsers;
  bool? isLoading;

  UsersState copyWith({
    List<User>? users,
    Map<String, AccountMemberRole>? accountMemberRoles,
    List<User>? filteredUsers,
    bool? isLoading,
  }) {
    return UsersState(
        users: users ?? this.users,
        accountMemberRoles: accountMemberRoles ?? this.accountMemberRoles,
        filteredUsers: filteredUsers ?? this.filteredUsers,
        isLoading: isLoading ?? this.isLoading);
  }

  Map<String, dynamic> toJson() => {
        'users': users,
        'accountMemberRoles': accountMemberRoles,
        'filteredUsers': filteredUsers,
      };

  UsersState.fromJson(Map<String, dynamic> json)
      : users = List.from(json['users']).map((e) => User.fromJson(e)).toList(),
        accountMemberRoles = deserializeMap(json['accountMemberRoles']),
        filteredUsers = List.from(json['filteredUsers']).map((e) => User.fromJson(e)).toList();

  String serializeEnumMap(Map<String, AccountRole> map) {
    Map<String, String> serializedMap = {};
    map.forEach((key, value) {
      serializedMap[key] = value.name;
    });
    return jsonEncode(serializedMap);
  }

  String getaccountMemberRole(String userId) {
    switch (accountMemberRoles[userId]?.role) {
      case AccountRole.le:
        return 'LE';
      case AccountRole.admin:
        return 'Admin';
      case AccountRole.owner:
        return 'Owner';
      default:
        return 'Unknown Role';
    }
  }

  AccountRole? getAccountRole(String userId) {
    return accountMemberRoles[userId]?.role;
  }

  @override
  String toString() =>
      "Users { users: $users, accountMemberRole: $accountMemberRoles, filteredUsers: $filteredUsers,isLoading: $isLoading}";
}

Map<String, AccountMemberRole> deserializeMap(String jsonString) {
  Map<String, dynamic> jsonMap = json.decode(jsonString);
  Map<String, AccountMemberRole> roleMap = {};

  jsonMap.forEach((key, value) {
    roleMap[key] = AccountMemberRole.fromJson(jsonMap);
  });
  return roleMap;
}

T stringToEnum<T>(Iterable<T> values, String value) {
  return values.firstWhere((v) => v.toString().split(".").last == value);
}

class UsersCubit extends Cubit<UsersState> with HydratedMixin {
  UsersCubit() : super(UsersState(users: [], accountMemberRoles: {}, filteredUsers: []));
  UserService userService = UserService();

  Future<void> getUsers(String accountId) async {
    try {
      Map<String, AccountMemberRole> accountMemberRoles = {};
      if (!isClosed) {
        emit(state.copyWith(isLoading: true));
        //get account users
        var users = await userService.getUsers(accountId);
        emit(state.copyWith(users: users));

        //get user permissions
        var userIds = users?.map((u) => u.id).toList() ?? [];
        accountMemberRoles = await userService.getAccountMemberRoleMap(userIds);
        emit(state.copyWith(accountMemberRoles: accountMemberRoles));
      }
    } catch (e) {
      print('ERROR IN USERS CUBIT: $e');
    }
  }

  updateUser(UserUpdate update) async {
    var userIndex = state.users.indexWhere((u) => u.id == update.id);
    if (userIndex != -1) {
      var user = state.users[userIndex];
      if (update.firstName != null) user.firstName = update.firstName!;
      if (update.lastName != null) user.lastName = update.lastName!;
      if (update.email != null) user.email = update.email!;
      if (update.mobile != null) user.mobile = update.mobile!;
      if (update.image != null) user.image = update.image!;

      emit(state.copyWith(
          users: [...state.users]
            ..remove(state.users[userIndex])
            ..insert(userIndex, user)));
    }
  }

  void updateUserRole(String userId, AccountMemberRole update) {
    Map<String, AccountMemberRole> accountMemberRoles = {...state.accountMemberRoles};
    AccountMemberRole? accountMemberRole = accountMemberRoles[userId];

    if (accountMemberRole != null) {
      accountMemberRole.role = update.role;
      emit(state.copyWith(accountMemberRoles: accountMemberRoles));
    }
  }

  deleteUser(String userID) async {
    userService.deleteUser(userID);
  }

  clearUsers() {
    emit(state.copyWith(users: [], filteredUsers: []));
  }

  searchStatusChanged(bool status) async {
    emit(state.copyWith(filteredUsers: !status ? [] : null));
  }

  searchUser(String name) {
    var users = state.users;
    var filteredUsers = users
        .where((element) => element.name.toLowerCase().startsWith(name.toLowerCase()))
        .toList();
    emit(state.copyWith(filteredUsers: filteredUsers));
  }

  @override
  UsersState? fromJson(Map<String, dynamic> json) {
    return UsersState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(UsersState state) {
    return state.toJson();
  }
}
