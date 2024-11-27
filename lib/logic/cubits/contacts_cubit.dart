import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';
import 'package:lm_teams_app/data/models/interaction%20model/interaction_model.dart';
import 'package:lm_teams_app/data/models/reminder_model.dart';
import 'package:lm_teams_app/services/contact_service.dart';
import '../../services/web_socket_service.dart';

// ignore: must_be_immutable
class ContactsState extends Equatable {
  ContactsState(
      {required this.contacts,
      required this.filteredContacts,
      required this.userReminders,
      required this.reminders,
      required this.interactions,
      this.isLoading = false});

  final List<Contact> contacts;
  final List<Contact> filteredContacts;
  final List<Reminder> userReminders;
  final List<Reminder> reminders;
  final List<Interaction> interactions;
  bool? isLoading;

  ContactsState copyWith({
    List<Contact>? contacts,
    List<Contact>? filteredContacts,
    List<Reminder>? userReminders,
    List<Reminder>? reminders,
    List<Interaction>? interactions,
    bool? isLoading,
  }) {
    return ContactsState(
        contacts: contacts ?? this.contacts,
        userReminders: userReminders ?? this.userReminders,
        filteredContacts: filteredContacts ?? this.filteredContacts,
        reminders: reminders ?? this.reminders,
        interactions: interactions ?? this.interactions,
        isLoading: isLoading ?? this.isLoading);
  }

  List<String> get contactIds {
    return contacts.map((contact) => contact.id).toList();
  }

  List<Reminder> getContactReminders(String contactId) {
    return reminders.where((element) => element.contactId == contactId).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  List<Interaction> getContactInteractions(String contactId) {
    return interactions.where((element) => element.contactId == contactId).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  List<Object?> get props =>
      [contacts, userReminders, filteredContacts, isLoading, reminders, interactions];

  @override
  String toString() =>
      "Contacts {contacts: $contacts, userReminders: $userReminders,reminders: $reminders, interactions: $interactions, filteredContacts: $filteredContacts, isLoading: $isLoading}";

  Map<String, dynamic> toJson() {
    return {
      'contacts': contacts,
      'userReminders': userReminders,
      'filteredContacts': filteredContacts,
      'reminders': reminders,
      'interactions': interactions
    };
  }

  ContactsState.fromJson(Map<String, dynamic> json)
      : contacts = List.from(json['contacts']).map((e) => Contact.fromJson(e)).toList(),
        userReminders = List.from(json['userReminders']).map((e) => Reminder.fromJson(e)).toList(),
        filteredContacts =
            List.from(json['filteredContacts']).map((e) => Contact.fromJson(e)).toList(),
        reminders = List.from(json['reminders']).map((e) => Reminder.fromJson(e)).toList(),
        interactions = List.from(json['interactions']).map((e) => Interaction.fromJson(e)).toList();
}

class ContactsCubit extends HydratedCubit<ContactsState> {
  ContactsCubit()
      : super(ContactsState(
            contacts: const [],
            userReminders: const [],
            filteredContacts: const [],
            reminders: const [],
            interactions: const []));
  ContactService contactService = ContactService();
  final _socket = WebSocketService();

  Future<void> initialEvent(String userID) async {
    if (!isClosed) {
      emit(state.copyWith(isLoading: true));
      await getContacts(userID);
      await getUserReminders(userID);
      await getContactReminders(userID);
      await getContactInteractions(userID);
      emit(state.copyWith(isLoading: false));
    }
  }

  //get all contacts
  Future<void> getContacts(String userID) async {
    if (!isClosed && _socket.isConnected) {
      var contacts = await contactService.getContacts(userID);
      emit(state.copyWith(contacts: contacts, filteredContacts: contacts));
    }
  }

  //get userReminders
  Future<void> getUserReminders(String userID) async {
    if (!isClosed && _socket.isConnected) {
      var userReminders = await contactService.getUserReminders(userID)
        ..forEach((rem) {
          rem.deleteNotification();
          rem.schedNotification(userID);
        });
      emit(state.copyWith(userReminders: userReminders..sort((a, b) => b.time.compareTo(a.time))));
    }
  }

  //get all contact reminders
  Future<void> getContactReminders(String userId) async {
    if (!isClosed && _socket.isConnected) {
      var reminders = await contactService.getContactsReminders(state.contactIds, userId);
      emit(state.copyWith(reminders: reminders));
    }
  }

  //get all contact interactions
  Future<void> getContactInteractions(String userId) async {
    if (!isClosed && _socket.isConnected) {
      var interactions = await contactService.getContactsInteractions(state.contactIds);
      emit(state.copyWith(interactions: interactions));
    }
  }

  Future<void> addContact(Contact contact) async {
    if (!isClosed) {
      var contacts = state.contacts..add(contact);
      var filteredfContacts = state.filteredContacts..add(contact);
      emit(state.copyWith(contacts: contacts, filteredContacts: filteredfContacts));
    }
  }

  void updateContact(Contact contact) {
    //update db
    contactService.updateContact(contact);
    //update state
    var index = state.contacts.indexWhere((element) => element.id == contact.id);
    if (index >= 0) {
      emit(state.copyWith(
          contacts: [...state.contacts]
            ..remove(state.contacts[index])
            ..insert(index, contact)));
    }
    var index2 = state.filteredContacts.indexWhere((element) => element.id == contact.id);
    if (index2 >= 0) {
      emit(state.copyWith(
          filteredContacts: [...state.filteredContacts]
            ..remove(state.filteredContacts[index])
            ..insert(index, contact)));
    }
  }

  void deleteContact(Contact contact, String userID) {
    contactService.deleteContact(contact, userID);
    emit(state.copyWith(
        contacts: [...state.contacts]..remove(contact),
        filteredContacts: [...state.filteredContacts]..remove(contact)));
  }

  searchContact(String name) {
    var contacts = state.contacts;

    var filteredContacts = contacts
        .where((element) => element.name.toLowerCase().startsWith(name.toLowerCase()))
        .toList();

    emit(state.copyWith(filteredContacts: filteredContacts));
  }

//filter contact by owner
  ownerFilter(int index, String userID) {
    switch (index) {
      //All Contacts
      case 0:
        emit(state.copyWith(filteredContacts: state.contacts));
        break;
      case 1:
        // Contacts user owned
        var contacts = state.contacts.where((contact) => contact.ownerId == userID).toList();
        emit(state.copyWith(filteredContacts: contacts));
        break;
      case 2:
        // Contacts shared to user
        var contacts = state.contacts.where((c) => c.sharedWith.contains(userID)).toList();
        emit(state.copyWith(filteredContacts: contacts));
        break;
    }
  }

  Future<Contact?> findContact(String contactID) async {
    Contact? match;
    for (var contact in state.contacts) {
      if (contact.id == contactID) {
        match = contact;
      }
    }
    return match;
  }

  //REMINDERS
  Future<void> addReminder(Reminder reminder, String userId) async {
    contactService.addReminder(reminder);
    reminder.schedNotification(userId);

    var reminders = List<Reminder>.from(state.reminders)..add(reminder);
    emit(state.copyWith(reminders: reminders));

    if (userId == reminder.canvasserId) {
      var userReminders = List<Reminder>.from(state.userReminders)..add(reminder);
      emit(state.copyWith(userReminders: userReminders));
    }
  }

  Future<void> updateReminder(Reminder reminder, String userId) async {
    //update in db
    contactService.updateReminder(reminder);
    //update notification
    reminder.deleteNotification();
    reminder.schedNotification(userId);
    //update reminder in contact cubit state
    var reminders = List<Reminder>.from(state.reminders)
      ..removeWhere((rem) => rem.id == reminder.id)
      ..add(reminder)
      ..sort((a, b) => b.time.compareTo(a.time));
    emit(state.copyWith(reminders: reminders));

    if (userId == reminder.canvasserId) {
      var userReminders = List<Reminder>.from(state.userReminders)
        ..removeWhere((rem) => rem.id == reminder.id)
        ..add(reminder)
        ..sort((a, b) => b.time.compareTo(a.time));
      emit(state.copyWith(userReminders: userReminders));
    }
  }

  Future<void> deleteReminder(Reminder reminder, String userId) async {
    // delete in db
    contactService.deleteReminders([reminder.id]);
    // delete notification
    reminder.deleteNotification();

    //delete reminder in contact cubit state
    var reminders = List<Reminder>.from(state.reminders)
      ..removeWhere((rem) => rem.id == reminder.id);
    emit(state.copyWith(reminders: reminders));

    if (userId == reminder.canvasserId) {
      var userReminders = List<Reminder>.from(state.userReminders)
        ..removeWhere((rem) => rem.id == reminder.id);
      emit(state.copyWith(userReminders: userReminders));
    }
  }

  Future<void> deleteRecurringReminder(Reminder reminder, String userId) async {
    var _nextReminder = reminder.nextReminder;
    //update reminder date to next reminder
    contactService.updateReminder(_nextReminder);
    //update notification date to next reminder
    reminder.deleteNotification();
    _nextReminder.schedNotification(userId);
    //replace reminder with the latest reminder in contact cubit state
    var reminders = List<Reminder>.from(state.reminders)
      ..removeWhere((rem) => rem.id == reminder.id)
      ..add(_nextReminder)
      ..sort((a, b) => b.time.compareTo(a.time));
    emit(state.copyWith(reminders: reminders));

    if (userId == reminder.canvasserId) {
      var userReminders = List<Reminder>.from(state.userReminders)
        ..removeWhere((rem) => rem.id == reminder.id)
        ..add(_nextReminder)
        ..sort((a, b) => b.time.compareTo(a.time));
      emit(state.copyWith(userReminders: userReminders));
    }
  }

  //INTERACTIONS
  Future<void> addInteraction(Interaction interaction) async {
    //add to db
    contactService.addInteraction(interaction);
    //add to state
    var interactions = List<Interaction>.from(state.interactions)
      ..add(interaction)
      ..sort((a, b) => b.time.compareTo(a.time));
    emit(state.copyWith(interactions: interactions));
  }

  Future<void> updateInteraction(Interaction interaction) async {
    //update in db
    contactService.updateInteraction(interaction);
    //update in state
    var interactions = List<Interaction>.from(state.interactions)
      ..removeWhere((inter) => inter.id == interaction.id)
      ..add(interaction)
      ..sort((a, b) => b.time.compareTo(a.time));
    emit(state.copyWith(interactions: interactions));
  }

  Future<void> deleteInteraction(Interaction interaction) async {
    //delete in db
    contactService.deleteInteraction(interaction.id);
    //delete in state
    var interactions = List<Interaction>.from(state.interactions)
      ..removeWhere((inter) => inter.id == interaction.id);
    emit(state.copyWith(interactions: interactions));
  }

  Future<void> clearState() async {
    emit(ContactsState(
        contacts: const [],
        filteredContacts: const [],
        interactions: const [],
        reminders: const [],
        userReminders: const [],
        isLoading: false));
  }

  @override
  ContactsState? fromJson(Map<String, dynamic> json) {
    return ContactsState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(ContactsState state) {
    return state.toJson();
  }
}
