import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/db_operation_object.dart';
import 'package:lm_teams_app/data/models/event%20model/event.dart';
import 'package:lm_teams_app/data/models/event%20model/event_member.dart';
import 'package:lm_teams_app/data/models/event%20model/event_team.dart';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/services/response-handlers/response-handlers.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

class EventService {
  final _socketService = WebSocketService();

  Future<bool> createEvent(Event event) async {
    if (!_socketService.isConnected) {
      return false;
    }
    var response = await _socketService.sendAndWait(
        Message('Write', data: IDBOperationObject(table: DBTableType.event.name, data: event)));
    return response.success;
  }

  createEventMembers(List<EventMember> members) async {
    for (var member in members) {
      _socketService.send(Message('Write',
          data: IDBOperationObject(table: DBTableType.eventMember.name, data: member)));
    }
  }

  createEventTeams(List<EventTeam> teams) async {
    for (var team in teams) {
      _socketService.send(Message('Write',
          data: IDBOperationObject(table: DBTableType.eventTeam.name, data: team)));
    }
  }

  void updateEvent(Map<String, dynamic> params) {
    _socketService.send(
        Message('Write', data: IDBOperationObject(table: DBTableType.event.name, data: params)));
  }

  void deleteEvent(Event event) async {
    _socketService.send(Message('Delete', data: {'table': DBTableType.event.name, 'id': event.id}));
    _socketService.send(Message('Write',
        data: IDBOperationObject(table: DBTableType.deletedEvent.name, data: event)));
  }

  Future<List<Event>> getEvents(String accountId) async {
    if (_socketService.isConnected) {
      var response = await HandleEventList(await _socketService.sendAndWait(Message('Read',
              data: IDBOperationObject(table: DBTableType.event.name, options: {
                'where': {'_account_id': accountId}
              }))))
          .run();

      return response.handle(success: (data) {
        return data ?? [];
      }, error: (errorMessage) {
        print(errorMessage);
        return [];
      });
    }
    return [];
  }

  Future<List<Event>?> getUserEvents(String userId) async {
    if (!_socketService.isConnected) return null;
    var response = await HandleEventList(
            await _socketService.sendAndWait(Message('ReadUserEvents', data: userId)))
        .run();
    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  Event? selectEventContext(List<Event> events, String selectedEventID) {
    if (events.isEmpty || selectedEventID == '-') {
      return Event.empty;
    }
    var index = events.indexWhere((event) => event.id == selectedEventID);
    return index != -1 ? events[index] : Event.empty;
  }

  Future<List<EventMember>> getEventMembers(String eventId) async {
    if (!_socketService.isConnected) return [];
    var response = await HandleEventMemberList(
            await _socketService.sendAndWait(Message('ReadEventMembers', data: eventId)))
        .run();
    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }
}
