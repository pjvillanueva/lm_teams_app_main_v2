// ignore_for_file: file_names
import 'package:lm_teams_app/data/models/event%20model/event_member.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/data/models/user_location.dart';
import 'package:lm_teams_app/services/response-handlers/abstract-response-handler.dart';
import '../../data/models/account.dart';
import '../../data/models/account_member_role.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/entry model/entry_model.dart';
import '../../data/models/event model/event.dart';
import '../../data/models/interaction model/interaction_model.dart';
import '../../data/models/inventory models/inventory_item.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/session.dart';
import '../../data/models/statistics model/statistics_object.dart';
import '../../data/models/team model/team_member.dart';
import '../../data/models/user model/team_invitee.dart';
import '../../data/models/user model/user.dart';
import '../web_socket_service.dart';

class AuthObject {
  AuthObject({
    required this.session,
    required this.singleUseToken,
  });
  final Session? session;
  final String? singleUseToken;

  factory AuthObject.fromJson(Map<String, dynamic> json) => AuthObject(
        session: Session.fromJson(json['session']),
        singleUseToken: json['singleUseToken'],
      );
}

class HandleSessionData extends ResponseHandler<Session> {
  HandleSessionData(this.response);

  final Response response;

  @override
  Future<Response<Session?>> run() async {
    if (response.success) {
      try {
        var _authObject = AuthObject.fromJson(response.data);
        return Response(data: _authObject.session, errorMessage: null);
      } catch (e) {
        return Response(data: null, errorMessage: e.toString());
      }
    }
    return Response(data: null, errorMessage: response.errorMessage);
  }
}

class HandleUserData extends ResponseHandler<User> {
  HandleUserData(this.response);

  final Response response;

  @override
  Future<Response<User?>> run() async {
    if (response.success) {
      try {
        return Response(data: User.fromJson(response.data), errorMessage: null);
      } catch (e) {
        return Response(data: null, errorMessage: e.toString());
      }
    }
    return Response(data: null, errorMessage: response.errorMessage);
  }
}

class HandleUserListData extends ResponseHandler<List<User>> {
  HandleUserListData(this.response);
  final Response response;

  @override
  Future<Response<List<User>?>> run() async {
    if (response.success) {
      try {
        return Response(
            data: List.from(response.data).map((e) => User.fromJson(e)).toList(),
            errorMessage: null);
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleAccountData extends ResponseHandler<Account> {
  HandleAccountData(this.response);
  final Response response;

  @override
  Future<Response<Account?>> run() async {
    if (response.success) {
      try {
        return Response(data: Account.fromJson(response.data), errorMessage: null);
      } catch (e) {
        return Response(data: null, errorMessage: e.toString());
      }
    }
    return Response(data: null, errorMessage: response.errorMessage);
  }
}

class HandleEntryListData extends ResponseHandler<List<Entry>> {
  HandleEntryListData(this.response);
  final Response response;

  @override
  Future<Response<List<Entry>?>> run() async {
    if (response.success) {
      try {
        return Response(
            data: List.from(response.data).map((e) => Entry.fromJson(e)).toList(),
            errorMessage: null);
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleItemList extends ResponseHandler<List<InventoryItem>> {
  HandleItemList(this.response);
  final Response response;

  @override
  Future<Response<List<InventoryItem>?>> run() async {
    if (response.success) {
      try {
        return Response(
            data: List.from(response.data).map((e) => InventoryItem.fromJson(e)).toList(),
            errorMessage: null);
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleContactList extends ResponseHandler<List<Contact>> {
  HandleContactList(this.response);
  final Response response;
  @override
  Future<Response<List<Contact>?>> run() async {
    if (response.success) {
      try {
        return Response(
            data: List.from(response.data).map((e) => Contact.fromJson(e)).toList(),
            errorMessage: null);
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleInteractionList extends ResponseHandler<List<Interaction>> {
  HandleInteractionList(this.response);
  final Response response;
  @override
  Future<Response<List<Interaction>?>> run() async {
    if (response.success) {
      try {
        return Response(
            data: List.from(response.data).map((e) => Interaction.fromJson(e)).toList());
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleReminderList extends ResponseHandler<List<Reminder>> {
  HandleReminderList(this.response);
  final Response response;
  @override
  Future<Response<List<Reminder>?>> run() async {
    if (response.success) {
      try {
        return Response(data: List.from(response.data).map((e) => Reminder.fromJson(e)).toList());
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleTeamList extends ResponseHandler<List<Team>> {
  HandleTeamList(this.response);
  final Response response;
  @override
  Future<Response<List<Team>?>> run() async {
    if (response.success) {
      try {
        return Response(data: List.from(response.data).map((e) => Team.fromJson(e)).toList());
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleEventList extends ResponseHandler<List<Event>> {
  HandleEventList(this.response);
  final Response response;
  @override
  Future<Response<List<Event>?>> run() async {
    if (response.success) {
      try {
        return Response(data: List.from(response.data).map((e) => Event.fromJson(e)).toList());
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleTeamMemberList extends ResponseHandler<List<TeamMember>> {
  HandleTeamMemberList(this.response);
  final Response response;
  @override
  Future<Response<List<TeamMember>?>> run() async {
    if (response.success) {
      try {
        return Response(data: List.from(response.data).map((e) => TeamMember.fromJson(e)).toList());
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleTeamInviteesList extends ResponseHandler<List<TeamInvitee>> {
  HandleTeamInviteesList(this.response);
  final Response response;
  @override
  Future<Response<List<TeamInvitee>?>> run() async {
    if (response.success) {
      try {
        return Response(
            data: List.from(response.data).map((e) => TeamInvitee.fromJson(e)).toList());
      } catch (e) {
        print("ERROR: $e");
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleStatisticsObjects extends ResponseHandler<List<StatisticsObject>> {
  HandleStatisticsObjects(this.response);
  final Response response;
  @override
  Future<Response<List<StatisticsObject>?>> run() async {
    if (response.success) {
      try {
        return Response(
            data: List.from(response.data).map((e) => StatisticsObject.fromJson(e)).toList());
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleUserLocation extends ResponseHandler<UserLocation> {
  HandleUserLocation(this.response);
  final Response response;
  @override
  Future<Response<UserLocation?>> run() async {
    if (response.success) {
      try {
        return Response(data: UserLocation.fromJson(response.data), errorMessage: null);
      } catch (e) {
        return Response(data: null, errorMessage: e.toString());
      }
    }
    return Response(data: null, errorMessage: response.errorMessage);
  }
}

class HandleUserLocationList extends ResponseHandler<List<UserLocation>> {
  HandleUserLocationList(this.response);
  final Response response;
  @override
  Future<Response<List<UserLocation>?>> run() async {
    if (response.success) {
      return Response(
          data: response.data != null
              ? List.from(response.data).map((e) {
                  return UserLocation.fromJson(e);
                }).toList()
              : []);
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleAccountMemberRole extends ResponseHandler<AccountMemberRole> {
  HandleAccountMemberRole(this.response);
  final Response response;
  @override
  Future<Response<AccountMemberRole?>> run() async {
    if (response.success) {
      try {
        return Response(data: AccountMemberRole.fromJson(response.data), errorMessage: null);
      } catch (e) {
        return Response(data: null, errorMessage: e.toString());
      }
    }
    return Response(data: null, errorMessage: response.errorMessage);
  }
}

class HandleAccountMemberRoleList extends ResponseHandler<List<AccountMemberRole>> {
  HandleAccountMemberRoleList(this.response);
  final Response response;

  @override
  Future<Response<List<AccountMemberRole>?>> run() async {
    if (response.success) {
      try {
        return Response(
          data: List.from(response.data).map((e) => AccountMemberRole.fromJson(e)).toList(),
        );
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}

class HandleEventMemberList extends ResponseHandler<List<EventMember>> {
  HandleEventMemberList(this.response);
  final Response response;
  @override
  Future<Response<List<EventMember>?>> run() async {
    if (response.success) {
      try {
        return Response(
            data: List.from(response.data).map((e) => EventMember.fromJson(e)).toList());
      } catch (e) {
        return Response(data: [], errorMessage: e.toString());
      }
    }
    return Response(data: [], errorMessage: response.errorMessage);
  }
}
