import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';
import 'package:lm_teams_app/data/models/db_operation_object.dart';
import 'package:lm_teams_app/data/models/interaction%20model/interaction_model.dart';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/data/models/reminder_model.dart';
import 'package:lm_teams_app/services/response-handlers/response-handlers.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

class ContactService {
  final _socket = WebSocketService();

  void addContact(Contact contact) {
    _socket.send(
        Message('Write', data: IDBOperationObject(table: DBTableType.contact.name, data: contact)));
  }

  void updateContact(Contact contact) {
    _socket.send(
        Message('Write', data: IDBOperationObject(table: DBTableType.contact.name, data: contact)));
  }

  void deleteContact(Contact contact, String userID) {
    //check if contact is shared
    if (contact.ownerId == userID) {
      //delete contact
      _socket.send(Message('Delete', data: {'table': DBTableType.contact.name, 'id': contact.id}));
    } else {
      //remove userid from contact sharedWith list
      contact.sharedWith.remove(userID);
      _socket.send(Message('Write',
          data: IDBOperationObject(table: DBTableType.contact.name, data: contact)));
    }
    //delete interactions
    _socket.send(Message('DeleteWhere', data: {
      'table': DBTableType.interaction.name,
      'params': {'contact_id': contact.id, '_owner_id': userID}
    }));
    //delete reminders
    _socket.send(Message('DeleteWhere', data: {
      'table': DBTableType.reminder.name,
      'params': {'contact_id': contact.id, '_owner_id': userID}
    }));
  }

  Future<List<Contact>> getContacts(String userID) async {
    List<Contact> allContacts = [];

    allContacts.addAll(await _getUserContacts(userID));
    allContacts.addAll(await _getSharedContacts(userID));
    return allContacts;
  }

  Future<List<Contact>> _getUserContacts(String userID) async {
    if (!_socket.isConnected) return [];
    var response = await HandleContactList(await _socket.sendAndWait(Message('Read',
            data: IDBOperationObject(
                table: DBTableType.contact.name,
                options: IDBReadOptions(where: {'_owner_id': userID})))))
        .run();
    return response.handle(success: (data) async {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  Future<List<Contact>> _getSharedContacts(String userID) async {
    if (!_socket.isConnected) return [];
    var response = await HandleContactList(
            await _socket.sendAndWait(Message('ReadSharedContacts', data: userID)))
        .run();
    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  void shareContact(Contact contact) {
    _socket.send(
        Message('Write', data: IDBOperationObject(table: DBTableType.contact.name, data: contact)));
  }

  //get all contact's interactions
  Future<List<Interaction>> getContactsInteractions(List<String> contactIds) async {
    if (!_socket.isConnected) return [];
    var response = await HandleInteractionList(await _socket.sendAndWait(Message('Read',
            data: IDBOperationObject(
                table: DBTableType.interaction.name,
                options: IDBReadOptions(where: {'contact_id': contactIds})))))
        .run();
    return response.handle(success: (data) {
      return data ?? [];
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  //get all contact's reminders
  Future<List<Reminder>> getContactsReminders(List<String> contactIds, String userId) async {
    if (!_socket.isConnected) return [];
    var response = await HandleReminderList(await _socket.sendAndWait(Message('Read',
            data: IDBOperationObject(
                table: DBTableType.reminder.name,
                options: IDBReadOptions(where: {'contact_id': contactIds, '_owner_id': userId})))))
        .run();
    return response.handle(success: (data) {
      List<Reminder> reminders = data ?? [];
      reminders = _filterFetchedReminders(List.from(reminders));
      return reminders;
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  Future<List<Reminder>> getUserReminders(String userID) async {
    if (!_socket.isConnected) return [];

    var response = await HandleReminderList(await _socket.sendAndWait(Message('Read',
            data: IDBOperationObject(
                table: DBTableType.reminder.name,
                options: IDBReadOptions(where: {'_owner_id': userID})))))
        .run();

    return response.handle(success: (data) {
      List<Reminder> reminders = data ?? [];
      reminders = _filterFetchedReminders(List.from(reminders));
      return reminders;
    }, error: (errorMessage) {
      print(errorMessage);
      return [];
    });
  }

  void addInteraction(Interaction interaction) {
    _socket.send(Message('Write',
        data: IDBOperationObject(table: DBTableType.interaction.name, data: interaction)));
  }

  void updateInteraction(Interaction interaction) {
    _socket.send(Message('Write',
        data: IDBOperationObject(table: DBTableType.interaction.name, data: interaction)));
  }

  void deleteInteraction(String interactionID) {
    _socket.send(
        Message('Delete', data: {'table': DBTableType.interaction.name, 'id': interactionID}));
  }

  void addReminder(Reminder reminder) {
    _socket.send(Message('Write',
        data: IDBOperationObject(table: DBTableType.reminder.name, data: reminder)));
  }

  void updateReminder(Reminder reminder) {
    _socket.send(Message('Write',
        data: IDBOperationObject(table: DBTableType.reminder.name, data: reminder)));
  }

  void deleteReminders(List<String> reminderIds) {
    _socket.send(Message('Delete', data: {'table': DBTableType.reminder.name, 'id': reminderIds}));
  }

  List<Reminder> _filterFetchedReminders(List<Reminder> reminders) {
    var now = DateTime.now();
    var daysAgo = now.subtract(const Duration(days: 1));

    List<Reminder> validReminders = [];
    List<Reminder> remindersToUpdate = [];
    List<String> reminderIdsToDelete = [];

    for (var reminder in reminders) {
      if (reminder.time.isAfter(daysAgo)) {
        validReminders.add(reminder);
      } else {
        if (reminder.repeat == ReminderRepeat.none) {
          reminderIdsToDelete.add(reminder.id);
        } else {
          remindersToUpdate.add(reminder.nextReminder);
          validReminders.add(reminder.nextReminder);
        }
      }
    }
    //delete outdated reminders
    if (reminderIdsToDelete.isNotEmpty) {
      deleteReminders(reminderIdsToDelete);
    }
    //update recurring reminders in db
    for (var reminder in remindersToUpdate) {
      updateReminder(reminder);
    }
    return validReminders;
  }
}
