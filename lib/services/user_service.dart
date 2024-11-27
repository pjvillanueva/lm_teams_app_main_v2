import 'dart:async';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/account.dart';
import 'package:lm_teams_app/data/models/db_operation_object.dart';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/data/models/servermessage_model.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/services/response-handlers/response-handlers.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../data/models/account_member_role.dart';
import '../data/models/user model/user_update.dart';

class UserService {
  final _socket = WebSocketService();

  Future<Account> getAccount(String accountId) async {
    if (!_socket.isConnected) {
      return Account.empty;
    }

    var response = await HandleAccountData(await _socket.sendAndWait(Message('Read',
            data: IDBOperationObject(
                table: DBTableType.account.name, options: IDBReadOptions(id: accountId)))))
        .run();
    return response.handle(success: (data) {
      return data ?? Account.empty;
    }, error: (errorString) {
      print(errorString);
      return Account.empty;
    });
  }

  Future<AccountMemberRole> getAccountMemberRole(String userId) async {
    if (!_socket.isConnected) {
      return AccountMemberRole.empty;
    }

    var response = await HandleAccountMemberRole(await _socket.sendAndWait(Message('Read',
            data: IDBOperationObject(
                table: DBTableType.accountMemberRole.name,
                options: IDBReadOptions(where: {'_ownerId': userId}, firstOnly: true)))))
        .run();

    if (response.success) {
      return response.data ?? AccountMemberRole.empty;
    } else {
      return AccountMemberRole.empty;
    }
  }

  Future<Map<String, AccountMemberRole>> getAccountMemberRoleMap(List<String> userIds) async {
    try {
      var response = await HandleAccountMemberRoleList(await _socket.sendAndWait(Message('Read',
              data: IDBOperationObject(
                  table: DBTableType.accountMemberRole.name,
                  options: IDBReadOptions(where: {'_ownerId': userIds})))))
          .run();

      List<AccountMemberRole> accountMemberRoles =
          response.handle(success: (data) => data ?? [], error: (e) => []);

      return {for (var e in accountMemberRoles) e.ownerId: e};
    } catch (e) {
      return {};
    }
  }

  Future<User> getUser() async {
    if (!_socket.isConnected) {
      return User.empty;
    }
    var response = await HandleUserData(await _socket.sendAndWait(Message('ReadUser'))).run();
    return response.handle(success: (data) {
      return data ?? User.empty;
    }, error: (errorString) {
      print(errorString);
      return User.empty;
    });
  }

  Future<List<User>?> getUsers(String accountId) async {
    if (!_socket.isConnected) return null;
    var response = await HandleUserListData(await _socket
            .sendAndWait(Message('Read', data: IDBOperationObject(table: DBTableType.user.name))))
        .run();
    return response.handle(success: (users) {
      return users ?? [];
    }, error: (e) {
      return [];
    });
  }

  Future<ServerMessage> addUser(User user) async {
    if (_socket.isConnected) {
      var response = await _socket.sendAndWait(Message("AddUser", data: user));
      response.handle(success: (data) {
        return data;
      }, error: (errorMessage) {
        print(errorMessage);
        return ServerMessage(success: false, message: errorMessage);
      });
    }
    return ServerMessage(success: false, message: "Socket not connected");
  }

  Future<Response<dynamic>?> updateUser(UserUpdate update) async {
    if (!_socket.isConnected) return null;
    return await _socket.sendAndWait(
        Message("Write", data: IDBOperationObject(table: DBTableType.user.name, data: update)));
  }

  void deleteUser(String userID) {
    print(userID);
    // _socket.send(Message("DeleteUser", data: userID));
  }

  void updateUserAccountRole(AccountMemberRole update) {
    _socket.send(Message("Write",
        data: IDBOperationObject(
            table: DBTableType.accountMemberRole.name,
            data: {'id': update.id, 'role_id': update.role.name})));
  }
}
