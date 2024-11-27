import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/contacts_cubit.dart';
import 'package:lm_teams_app/logic/cubits/users_cubit.dart';
import '../../../../data/models/contact_model.dart';
import '../../../../data/models/reminder_model.dart';
import '../../../dialogs/confirmation_dialog.dart';
import '../../../dialogs/reminder_dialog.dart';
import '../../../widgets/accordions.dart';
import '../../../widgets/snackbar.dart';

class ContactRemindersSection extends StatefulWidget {
  const ContactRemindersSection(this.contact, {Key? key}) : super(key: key);

  final Contact contact;

  @override
  State<ContactRemindersSection> createState() => _ContactRemindersSectionState();
}

class _ContactRemindersSectionState extends State<ContactRemindersSection> {
  @override
  Widget build(BuildContext context) {
    var users = context.read<UsersCubit>().state.users;
    var user = context.read<UserBloc>().state.user;

    return BlocBuilder<ContactsCubit, ContactsState>(builder: (context, state) {
      List<Reminder> reminders = state.getContactReminders(widget.contact.id);

      return Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Reminders', style: TextStyle(fontSize: 16.spMin)),
          IconButton(
              icon: Icon(Icons.add_circle_outline, size: 24.0.spMin),
              onPressed: () async {
                try {
                  Reminder? _reminder = await showReminderDialog(
                      context: context, contact: widget.contact, canvassers: users);

                  if (_reminder != null) {
                    context.read<ContactsCubit>().addReminder(_reminder, user.id);
                    showAppSnackbar(context, 'Succesfully saved reminder');
                  }
                } catch (e) {
                  print('Error in reminder dialog');
                }
              })
        ]),
        Column(mainAxisSize: MainAxisSize.min, children: [
          ListView.separated(
              shrinkWrap: true,
              itemCount: reminders.length,
              separatorBuilder: (context, index) => SizedBox(height: 5.spMin),
              itemBuilder: (context, index) {
                Reminder reminder = reminders[index];

                return ReminderAccordion(
                    reminder: reminder,
                    inContactView: true,
                    onDelete: () async {
                      if (reminder.repeat == ReminderRepeat.none) {
                        var proceedDelete = await showDeleteConfirmation(context, 'Delete Reminder',
                            'Are you sure you want to delete this reminder?');

                        if (!proceedDelete) return;
                        try {
                          await context.read<ContactsCubit>().deleteReminder(reminder, user.id);
                          showAppSnackbar(context, 'Reminder Deleted');
                        } catch (e) {
                          showAppSnackbar(context, 'Failed to delete reminder', isError: true);
                        }
                      } else {
                        var proceedDeleteAll = await showReccuringDeleteConfirmation(
                            context,
                            'Delete Reminder',
                            'Delete this reminder only, or all future re-occuring reminders?');

                        if (proceedDeleteAll == false) {
                          //Delete this reminder only and reassign next reminder
                          try {
                            await context
                                .read<ContactsCubit>()
                                .deleteRecurringReminder(reminder, user.id);
                            showAppSnackbar(context, 'Reminder Deleted');
                          } catch (e) {
                            showAppSnackbar(context, 'Failed to delete reminder', isError: true);
                          }
                        } else if (proceedDeleteAll == true) {
                          //Delete this reminder and all repeating reminders
                          try {
                            await context.read<ContactsCubit>().deleteReminder(reminder, user.id);
                            showAppSnackbar(context, 'Reminder Deleted');
                          } catch (e) {
                            showAppSnackbar(context, 'Failed to delete reminder', isError: true);
                          }
                        }
                      }
                    },
                    onEdit: () async {
                      try {
                        Reminder? updatedReminder = await showReminderDialog(
                            context: context,
                            contact: widget.contact,
                            canvassers: users,
                            reminder: reminder);

                        if (updatedReminder == null) return;

                        if (updatedReminder == reminder) {
                          showAppSnackbar(context, 'No changes made', isError: true);
                          return;
                        }

                        try {
                          await context
                              .read<ContactsCubit>()
                              .updateReminder(updatedReminder, user.id);
                          showAppSnackbar(context, 'Changes saved');
                        } catch (e) {
                          showAppSnackbar(context, 'Failed to update reminder', isError: true);
                        }
                      } catch (e) {
                        print('Error in reminder dialog, $e');
                      }
                    },
                    onDone: () async {
                      if (reminder.repeat == ReminderRepeat.none) {
                        try {
                          await context.read<ContactsCubit>().deleteReminder(reminder, user.id);
                          showAppSnackbar(context, 'Reminder Done');
                        } catch (e) {
                          showAppSnackbar(context, 'Failed to delete reminder', isError: true);
                        }
                      } else {
                        try {
                          await context
                              .read<ContactsCubit>()
                              .deleteRecurringReminder(reminder, user.id);
                          showAppSnackbar(context, 'Set reminder to next date');
                        } catch (e) {
                          showAppSnackbar(context, 'Failed update reminder', isError: true);
                        }
                      }
                    });
              })
        ])
      ]);
    });
  }
}
