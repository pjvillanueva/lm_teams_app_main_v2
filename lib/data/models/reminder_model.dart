import 'package:equatable/equatable.dart';
import 'package:lm_teams_app/presentation/dialogs/interaction_dialog.dart';
import 'package:lm_teams_app/services/time_helpers.dart';

enum ReminderRepeat { none, weekly, fornightly, monthly, yearly }

class Reminder extends Equatable {
  Reminder({
    required this.id,
    required this.notificationId,
    required this.contactId,
    required this.notes,
    required this.repeat,
    required this.time,
    required this.canvasserId,
  });

  final String id;
  final int notificationId;
  final String contactId;
  final String notes;
  final ReminderRepeat repeat;
  final DateTime time;
  final String canvasserId;

  final _timeService = TimeService();
  // final _notifService = NotificationService();

  @override
  List<Object?> get props => [id, notificationId, contactId, notes, repeat, time, canvasserId];

  Reminder.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        notificationId = json['notificationId'],
        contactId = json['contactId'],
        notes = json['notes'],
        repeat = stringToEnum<ReminderRepeat>(ReminderRepeat.values, json['repeat']),
        time = DateTime.parse(json['time']).toLocal(),
        canvasserId = json['canvasserId'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'notificationId': notificationId,
        'contactId': contactId,
        'notes': notes,
        'repeat': repeat.name,
        'time': time.toIso8601String(),
        'canvasserId': canvasserId
      };

  String get reminderTitle {
    return _timeService.formatRelativeDate(time) + ' @ ' + _timeService.timeToString(time);
  }

  bool get isDatePassed {
    return time.isBefore(DateTime.now());
  }

  DateTime get nextDate {
    switch (repeat) {
      case ReminderRepeat.weekly:
        return time.add(const Duration(days: 7));
      case ReminderRepeat.fornightly:
        return time.add(const Duration(days: 14));
      case ReminderRepeat.monthly:
        return time.nextMonth;
      case ReminderRepeat.yearly:
        return time.nextYear;
      default:
        return time;
    }
  }

  Reminder get nextReminder {
    return Reminder(
        id: id,
        notificationId: notificationId,
        contactId: contactId,
        notes: notes,
        repeat: repeat,
        time: nextDate,
        canvasserId: canvasserId);
  }

  Future<void> schedNotification(String userID) async {
    if (userID == canvasserId) {
      if (time.isAfter(DateTime.now())) {
        // await _notifService.scheduleNotification(
        //     id: notificationId, title: 'Follow-up Reminder', body: notes, time: time);
      }
    }
  }

  Future<void> deleteNotification() async {
    // await _notifService.deleteNotification(notificationId);
  }

  @override
  String toString() =>
      'Reminder (_id: $id, notificationId: $notificationId, contactId: $contactId, notes: $notes, repeat: $repeat, time: $time, canvasserId: $canvasserId)';
}
