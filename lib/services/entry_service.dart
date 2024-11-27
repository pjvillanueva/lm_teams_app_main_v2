import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/db_operation_object.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_model.dart';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/services/response-handlers/response-handlers.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

class EntryFilter {
  EntryFilter({required this.dateRangeStart, required this.dateRangeEnd});

  DateTime dateRangeStart;
  DateTime dateRangeEnd;

  Map<String, dynamic> toJson() => {
        'dateRangeStart': dateRangeStart.toIso8601String(),
        'dateRangeEnd': dateRangeEnd.toIso8601String()
      };
}

class EntryService {
  final _socket = WebSocketService();

  void addEntry(Entry entry) {
    _socket.send(
        Message("Write", data: IDBOperationObject(table: DBTableType.entry.name, data: entry)));
  }

  Future<List<Entry>> getEntries(EntryFilter filter) async {
    if (!_socket.isConnected) return [];
    var response =
        await HandleEntryListData(await _socket.sendAndWait(Message('ReadEntries', data: {
      'dateRangeStart': filter.dateRangeStart.toIso8601String(),
      'dateRangeEnd': exactDateRangeEnd(filter.dateRangeEnd)
    })))
            .run();

    return response.handle(
        success: (data) => data ?? [],
        error: (errorMessage) {
          print(errorMessage);
          return [];
        });
  }

  Future<List<Entry>> getEntriesWithinRange(LatLngBounds bounds, List<String>? userIds,
      String? teamId, List<String> entryIds, List<String> types) async {
    if (!_socket.isConnected) return [];

    var response = await HandleEntryListData(
            await _socket.sendAndWait(Message('ReadEntriesWithinRange', data: {
      'bounds': bounds.toJson(),
      'userIds': userIds,
      'teamId': teamId,
      'entryIds': entryIds,
      'types': types
    })))
        .run();
    return response.handle(success: (data) => data ?? [], error: ((errorMessage) => []));
  }

  String exactDateRangeEnd(DateTime dateRangeEnd) {
    if (dateRangeEnd.isToday) {
      final _now = DateTime.now();
      final _exactDateRangeEnd = DateTime(dateRangeEnd.year, dateRangeEnd.month, dateRangeEnd.day,
          _now.hour, _now.minute, _now.second, _now.millisecond);
      return _exactDateRangeEnd.toIso8601String();
    }
    return dateRangeEnd.beforeMidnight.toIso8601String();
  }

  deleteEntry(String entryID) {
    _socket.send(Message('Delete', data: {'table': DBTableType.entry.name, 'id': entryID}));
  }

  updateEntry(Entry entry) {
    _socket.send(
        Message('Write', data: IDBOperationObject(table: DBTableType.entry.name, data: entry)));
  }

  deleteContactEntry(String entryId) {
    _socket.send(Message('DeleteContactEntry', data: entryId));
  }
}
