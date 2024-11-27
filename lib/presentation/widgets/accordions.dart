import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:getwidget/getwidget.dart';
import 'package:lm_teams_app/data/models/interaction%20model/interaction_model.dart';
import 'package:lm_teams_app/data/models/reminder_model.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';

class ReminderAccordion extends StatelessWidget {
  const ReminderAccordion(
      {Key? key,
      required this.reminder,
      required this.inContactView,
      this.onDelete,
      this.onEdit,
      this.onDone,
      this.onView})
      : super(key: key);

  final Reminder reminder;
  final bool inContactView;
  final void Function()? onDelete;
  final void Function()? onEdit;
  final void Function()? onDone;
  final void Function()? onView;

  @override
  Widget build(BuildContext context) {
    Color reminderColor() {
      return reminder.isDatePassed ? Colors.red : Theme.of(context).colorScheme.primary;
    }

    return GFAccordion(
      title: reminder.reminderTitle,
      textStyle: TextStyle(fontSize: 14.0.spMin, color: Theme.of(context).colorScheme.onPrimary),
      collapsedTitleBackgroundColor: reminderColor(),
      expandedTitleBackgroundColor: reminderColor(),
      collapsedIcon: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 24.0.spMin),
      expandedIcon: Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 24.0.spMin),
      margin: EdgeInsets.zero,
      contentBackgroundColor: reminderColor(),
      contentChild: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                reminder.notes,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 14.0.spMin),
              ),
            ],
          ),
          Divider(thickness: 1.0.spMin, color: Colors.white),
          Visibility(
            visible: inContactView,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    child: Text(
                      'Delete',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary, fontSize: 16.0.spMin),
                    ),
                    onPressed: onDelete),
                TextButton(
                    child: Text(
                      'Edit',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary, fontSize: 16.0.spMin),
                    ),
                    onPressed: onEdit),
                TextButton(
                    child: Text(
                      'Done',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary, fontSize: 16.0.spMin),
                    ),
                    onPressed: onDone),
              ],
            ),
            replacement: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    child: Text(
                      'VIEW CONTACT',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    onPressed: onView),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class InteractionAccordion extends StatelessWidget {
  const InteractionAccordion(
      {Key? key, required this.interaction, required this.users, this.onDelete, this.onEdit})
      : super(key: key);

  final Interaction interaction;
  final List<User> users;
  final void Function()? onDelete;
  final void Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    var _noteController = TextEditingController(text: interaction.notes);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: interaction.type == InteractionType.BibleStudy
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent),
      ),
      child: GFAccordion(
        title: interaction.simpleDate,
        textStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14.0.spMin),
        collapsedTitleBackgroundColor: Theme.of(context).colorScheme.surface,
        expandedTitleBackgroundColor: Theme.of(context).colorScheme.surface,
        margin: EdgeInsets.zero,
        collapsedIcon: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 24.0.spMin),
        expandedIcon: Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 24.0.spMin),
        contentBackgroundColor: Theme.of(context).colorScheme.surface,
        contentChild: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(fontSize: 14.0.spMin),
              controller: _noteController,
              readOnly: true,
              decoration: InputDecoration(
                  label: Text(
                'Notes',
                style: TextStyle(fontSize: 14.0.spMin),
              )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                interaction.typeView,
                Text(
                  interaction.visitedBy(users),
                  style: TextStyle(fontSize: 14.0.spMin),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    child: Text(
                      'Edit',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface, fontSize: 16.0.spMin),
                    ),
                    onPressed: onEdit),
                TextButton(
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red, fontSize: 16.0.spMin),
                    ),
                    onPressed: onDelete)
              ],
            )
          ],
        ),
      ),
    );
  }
}
