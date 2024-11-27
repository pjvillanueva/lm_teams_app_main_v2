import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/models/event%20model/event.dart';
import 'package:lm_teams_app/services/event_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

class EventsState {
  EventsState({required this.events, required this.filteredEvents});

  List<Event> events;
  List<Event> filteredEvents;

  EventsState copyWith({List<Event>? events, List<Event>? filteredEvents}) {
    return EventsState(
        events: events ?? this.events, filteredEvents: filteredEvents ?? this.filteredEvents);
  }
}

class EventsCubit extends Cubit<EventsState> {
  EventsCubit()
      : super(EventsState(
          events: [],
          filteredEvents: [],
        ));

  final _socketService = WebSocketService();
  final _eventService = EventService();

  getEvents(String? accountID) async {
    if (_socketService.isConnected && !isClosed) {
      if (accountID != null) {
        var events = await _eventService.getEvents(accountID);
        if (events.isNotEmpty) {
          emit(state.copyWith(events: events));
        }
      }
    } else {
      print("Unable to get events. No internet connection");
    }
  }

  addEvent(Event event) async {
    emit(state.copyWith(events: [...state.events]..add(event)));
  }

  deleteEvent(Event event) async {
    //remove in state
    emit(state.copyWith(
        events: [...state.events]..remove(event),
        filteredEvents: [...state.filteredEvents]..remove(event)));
    //remove in db
    _eventService.deleteEvent(event);
  }

  Future<void> searchStatusChanged(bool status) async {
    emit(state.copyWith(filteredEvents: !status ? [] : null));
  }

  searchEvent(String name) {
    var events = state.events;
    var filteredEvents = events
        .where((element) => element.name.toLowerCase().startsWith(name.toLowerCase()))
        .toList();
    emit(state.copyWith(filteredEvents: filteredEvents));
  }
}
