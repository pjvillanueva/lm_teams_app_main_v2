import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/models/entry%20model/entry_model.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import 'package:lm_teams_app/services/entry_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/entry model/entry_data_model.dart';
import '../../data/models/event model/event.dart';
import '../../data/models/location model/location_event.dart';
import '../../services/web_socket_service.dart';

class EntryHistoryObject {
  EntryHistoryObject({required this.date, required this.entries});
  final DateTime date;
  List<Entry> entries;

  sortEntries() {
    entries.sort((a, b) {
      var adate = a.time;
      var bdate = b.time;
      return bdate.compareTo(adate);
    });
  }

  @override
  String toString() => "EntryHistoryObject { date: $date, entries: $entries }";

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> entryJsonStrings = entries.map((entry) => entry.toJson()).toList();
    return {
      'entryHistoryObjectDate': date.toIso8601String(),
      'entryHistoryObjectEntries': entryJsonStrings,
    };
  }

  EntryHistoryObject.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json['entryHistoryObjectDate']),
        entries = List.from(json['entryHistoryObjectEntries']).map((e) {
          return Entry.fromJson(decodeJson(e));
        }).toList();
}

class EntryHistoryState {
  EntryHistoryState(
      {required this.historyObjects, required this.contactEntries, this.dateIndex = 0});
  final List<EntryHistoryObject> historyObjects;
  final List<Entry> contactEntries;
  int dateIndex = 0;

  EntryHistoryState copyWith({
    List<EntryHistoryObject>? historyObjects,
    List<Entry>? contactEntries,
    int? dateIndex,
  }) {
    return EntryHistoryState(
      historyObjects: historyObjects ?? this.historyObjects,
      contactEntries: contactEntries ?? this.contactEntries,
      dateIndex: dateIndex ?? this.dateIndex,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> historyJsonStrings =
        historyObjects.map((entry) => entry.toJson()).toList();
    return {'historyObjects': historyJsonStrings, 'contactEntries': contactEntries};
  }

  EntryHistoryState.fromJson(Map<String, dynamic> json)
      : historyObjects =
            List.from(json['historyObjects']).map((e) => EntryHistoryObject.fromJson(e)).toList(),
        contactEntries = List.from(json['contactEntries']).map((e) => Entry.fromJson(e)).toList();
}

class EntryHistoryCubit extends HydratedCubit<EntryHistoryState> {
  EntryHistoryCubit() : super(EntryHistoryState(historyObjects: [], contactEntries: []));

  EntryService entryService = EntryService();
  final _socket = WebSocketService();
  final _utils = UtilsService();

  getEntries(EntryFilter filter) async {
    if (_socket.isConnected) {
      var entries = await entryService.getEntries(filter)
        ..sort((a, b) => b.time.compareTo(a.time));
      _createEntryHistoryObject(entries);
      _fiilterContactEntries(entries);
    } else {
      //filter offline entries
      _filterSavedEntryHistoryObjects(filter);
    }
  }

  _fiilterContactEntries(List<Entry> entries) {
    var contactEntries = entries.where((element) => element.type == EntryType.contact).toList();
    emit(state.copyWith(contactEntries: contactEntries));
  }

  void _createEntryHistoryObject(List<Entry<dynamic>> entries) {
    Map<String, EntryHistoryObject> historyMap = {};

    for (var entry in entries) {
      final dateKey = entry.time.ymdOnly.toString();
      final entryId = entry.id;

      historyMap.putIfAbsent(
          dateKey, () => EntryHistoryObject(date: entry.time.ymdOnly, entries: []));
      final historyObject = historyMap[dateKey]!;

      if (!historyObject.entries.any((element) => element.id == entryId)) {
        historyObject.entries.add(entry);
        historyObject.sortEntries();
      }
    }

    historyMap.removeWhere((key, value) => value.entries.isEmpty);
    final sortedHistoryObjects = historyMap.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (!isClosed) {
      emit(state.copyWith(historyObjects: sortedHistoryObjects));
    }
  }

  Map<String, EntryHistoryObject> get historyObjectsMap {
    return Map<String, EntryHistoryObject>.fromEntries(
        state.historyObjects.map((object) => MapEntry(object.date.ymdOnly.toString(), object)));
  }

  void _filterSavedEntryHistoryObjects(EntryFilter filter) {
    final historyMap = Map<String, EntryHistoryObject>.fromEntries(
        state.historyObjects.map((object) => MapEntry(object.date.ymdOnly.toString(), object)));
    historyMap.removeWhere((key, value) =>
        value.date.isBefore(filter.dateRangeStart) || value.date.isAfter(filter.dateRangeEnd));

    if (!isClosed) {
      emit(state.copyWith(historyObjects: historyMap.values.toList()));
    }
  }

  void addEntry(EntryType type, dynamic data, String? teamID, String? eventID,
      {LocationEvent? locationEvent}) {
    //create the entry
    var entry = Entry(
        id: _utils.uid(),
        data: _getData(type, data, toServer: true),
        time: DateTime.now(),
        teamId: teamID == '-' ? null : teamID,
        eventId: eventID == '-' ? null : eventID,
        type: type,
        locationEvent: locationEvent);
    //add to db
    entryService.addEntry(entry);
    //change data for state
    entry.data = _getData(type, data);

    //update state
    final now = DateTime.now().ymdOnly;
    final historyMap = Map<String, EntryHistoryObject>.from(historyObjectsMap);
    final object = historyMap[now.toString()] ?? EntryHistoryObject(date: now, entries: []);
    object.entries.add(entry);
    object.sortEntries();
    historyMap[now.toString()] = object;
    final historyObjects = historyMap.values.toList()..sort((a, b) => b.date.compareTo(a.date));

    if (!isClosed) {
      emit(state.copyWith(historyObjects: historyObjects));
    }
  }

  void deleteEntry(String entryId, int historyObjectIndex) {
    //update db
    entryService.deleteEntry(entryId);
    //update ui
    final historyObjects = [...state.historyObjects];
    final object = historyObjects[historyObjectIndex];
    final entries = object.entries.where((e) => e.id != entryId).toList();
    if (entries.isEmpty) {
      historyObjects.removeAt(historyObjectIndex);
    } else {
      historyObjects[historyObjectIndex] = EntryHistoryObject(date: object.date, entries: entries);
    }
    emit(state.copyWith(historyObjects: historyObjects));
  }

  updateEntry(Entry entry, dynamic data, int historyObjectIndex) {
    //update db
    entry.data = _getData(entry.type, data, toServer: true);
    entryService.updateEntry(entry);
    //update ui
    if (historyObjectIndex == -1) return;
    var object = state.historyObjects[historyObjectIndex];
    var entries = List.of(object.entries);
    var entryIndex = entries.indexWhere((e) => e.id == entry.id);
    if (entryIndex != -1) {
      entry.data = _getData(entry.type, data);
      entries[entryIndex] = entry;
      final newObject = EntryHistoryObject(date: object.date, entries: entries);
      final historyObjects = [...state.historyObjects];
      historyObjects[historyObjectIndex] = newObject;
      emit(state.copyWith(historyObjects: historyObjects));
    }
  }

  Future<void> deleteContactEntry(String contactId) async {
    var entryIdAndIndex = _findContactEntryIdAndIndex(contactId);

    if (entryIdAndIndex['entryId'] != null &&
        entryIdAndIndex['index'] != null &&
        entryIdAndIndex['index'] != -1) {
      deleteEntry(entryIdAndIndex['entryId'], entryIdAndIndex['index']);
    }
  }

  Future<void> updateContactEntry(Contact contact) async {
    var entryIdAndIndex = _findContactEntryIdAndIndex(contact.id);
    var entry = state.contactEntries.firstWhere((entry) => entry.id == entryIdAndIndex['entryId']);

    if (entryIdAndIndex['entryId'] != null &&
        entryIdAndIndex['index'] != null &&
        entryIdAndIndex['index'] != -1) {
      updateEntry(entry, contact, entryIdAndIndex['index']);
    }
  }

  Map<String, dynamic> _findContactEntryIdAndIndex(String contactId) {
    String? entryId;
    int? index;
    for (var i = 0; i < state.historyObjects.length; i++) {
      for (var entry in state.historyObjects[i].entries) {
        if (entry.type == EntryType.contact) {
          var contact = entry.data as Contact;
          if (contact.id == contactId) {
            entryId = entry.id;
            index = i;
          }
        }
      }
    }
    return {'entryId': entryId, 'index': index};
  }

  incrementDateIndex() {
    if (state.dateIndex < state.historyObjects.length - 1) {
      emit(state.copyWith(dateIndex: state.dateIndex + 1));
    }
  }

  decrementDateIndex() {
    if (state.dateIndex > 0) {
      emit(state.copyWith(dateIndex: state.dateIndex - 1));
    }
  }

  dynamic _getData(EntryType type, dynamic data, {bool toServer = false}) {
    if (type == EntryType.contact) {
      return (toServer ? (data as Contact).id : data);
    } else if (type == EntryType.book) {
      var _data = data as BookEntryData;
      if (toServer) {
        return BookEntryData(itemID: _data.itemID, quantity: _data.quantity);
      }
      return _data;
    } else {
      return data;
    }
  }

  @override
  EntryHistoryState? fromJson(Map<String, dynamic> json) {
    return EntryHistoryState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(EntryHistoryState state) {
    return state.toJson();
  }
}
