import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/event%20model/event.dart';
import 'package:lm_teams_app/data/models/event%20model/event_member.dart';
import 'package:lm_teams_app/data/models/event%20model/event_team.dart';
import 'package:lm_teams_app/data/models/inventory%20models/inventory_item.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/presentation/dialogs/item_form_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/services/time_helpers.dart';
import 'package:lm_teams_app/services/event_service.dart';
import 'package:lm_teams_app/services/items_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:intl/intl.dart';

class EventFormState {
  EventFormState({
    this.imageFile,
    required this.items,
    required this.selectedLeaders,
    required this.selectedMembers,
    required this.selectedTeams,
    required this.events,
    this.eventStartDate,
    this.eventEndDate,
  });
  File? imageFile;
  final List<InventoryItem> items;
  final List<User> selectedLeaders;
  final List<User> selectedMembers;
  final List<Team> selectedTeams;
  final List<Event> events;
  final DateTime? eventStartDate;
  final DateTime? eventEndDate;

  EventFormState copyWith({
    File? imageFile,
    List<InventoryItem>? items,
    List<User>? selectedLeaders,
    List<User>? selectedMembers,
    List<Team>? selectedTeams,
    List<Event>? events,
    DateTime? eventStartDate,
    DateTime? eventEndDate,
  }) {
    return EventFormState(
      imageFile: imageFile ?? this.imageFile,
      items: items ?? this.items,
      selectedLeaders: selectedLeaders ?? this.selectedLeaders,
      selectedMembers: selectedMembers ?? this.selectedMembers,
      selectedTeams: selectedTeams ?? this.selectedTeams,
      events: events ?? this.events,
      eventStartDate: eventStartDate ?? this.eventStartDate,
      eventEndDate: eventEndDate ?? this.eventEndDate,
    );
  }

  String get eventDatesString {
    final DateFormat formatter = DateFormat('MM/dd/yyyy');
    if (eventStartDate != null && eventEndDate != null) {
      final String formattedStartDate = formatter.format(eventStartDate!);
      final String formattedEndDate = formatter.format(eventEndDate!);
      return "$formattedStartDate - $formattedEndDate";
    }
    return '';
  }

  List<User> get selectedUsers {
    return selectedLeaders + selectedMembers;
  }

  List<String> get itemCodes {
    return items.map((item) => item.code).toList();
  }
}

class EventFormCubit extends Cubit<EventFormState> {
  EventFormCubit()
      : super(EventFormState(
            items: [], selectedLeaders: [], selectedMembers: [], selectedTeams: [], events: []));
  final _utils = UtilsService();
  final _eventService = EventService();
  final _itemService = ItemService();

  addImageFile(File? imageFile) {
    emit(state.copyWith(imageFile: imageFile));
  }

  setEventDates(List<DateTime> dates) {
    emit(state.copyWith(eventStartDate: dates[0], eventEndDate: dates[1].beforeMidnight));
  }

  addLeaders(List<User> users) {
    emit(state.copyWith(selectedLeaders: users));
  }

  addMember(List<User> users) {
    emit(state.copyWith(selectedMembers: users));
  }

  removeLeader(User user) {
    emit(state.copyWith(selectedLeaders: [...state.selectedLeaders]..remove(user)));
  }

  removeMember(User user) {
    emit(state.copyWith(selectedMembers: [...state.selectedMembers..remove(user)]));
  }

  addItem(InventoryItem item) {
    emit(state.copyWith(items: [...state.items]..add(item)));
  }

  removeItem(InventoryItem item) {
    emit(state.copyWith(items: [...state.items]..remove(item)));
  }

  addTeams(List<Team> selectedTeams) {
    emit(state.copyWith(selectedTeams: selectedTeams));
  }

  removeTeam(Team team) {
    emit(state.copyWith(selectedTeams: [...state.selectedTeams]..remove(team)));
  }

  Future<Event?> saveEvent(BuildContext context, GlobalKey<FormState> formKey, String eventName,
      String eventLocation, bool isOpenEvent) async {
    if (!formKey.currentState!.validate()) {
      return null;
    }
    // var user = context.read<UserBloc>().state.user;
    var imageObj = await uploadImage(context, state.imageFile);

    showLoaderDialog(context, loadingText: 'Saving event...');

    var event = Event(
        id: _utils.uid(),
        name: eventName,
        image: imageObj,
        location: eventLocation,
        isOpenEvent: isOpenEvent,
        eventStartDate: state.eventStartDate,
        eventEndDate: state.eventEndDate);

    var isSuccess = await _eventService.createEvent(event);

    if (isSuccess) {
      await saveEventMembers(context, event);
      await saveEventTeams(event);
      await saveEventItems(event.id);
      return event;
    } else {
      return null;
    }
  }

  Future<void> saveEventMembers(BuildContext context, Event event) async {
    List<EventMember> eventMembers = [];

    for (var user in state.selectedLeaders) {
      var eventLeader =
          EventMember(id: _utils.uid(), eventId: event.id, isLeader: true, userId: user.id);

      eventMembers.add(eventLeader);
    }
    for (var user in state.selectedMembers) {
      var eventMember =
          EventMember(id: _utils.uid(), eventId: event.id, isLeader: false, userId: user.id);

      eventMembers.add(eventMember);
    }

    _eventService.createEventMembers(eventMembers);
  }

  Future<void> saveEventItems(String eventID) async {
    for (var item in state.items) {
      item.eventId = eventID;
      _itemService.saveInventoryItem(DBTableType.eventItem, item);
    }
  }

  saveEventTeams(Event event) {
    List<EventTeam> eventTeams = [];
    for (var team in state.selectedTeams) {
      var eventTeam = EventTeam(id: _utils.uid(), eventId: event.id, teamId: team.id);
      eventTeams.add(eventTeam);
    }
    _eventService.createEventTeams(eventTeams);
  }
}
