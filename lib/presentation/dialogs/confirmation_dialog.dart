import 'package:flutter/material.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';

Future<bool> showDeleteConfirmation(BuildContext context, String title, String question) async {
  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AppDialog(title: title, contents: [
          Text(question, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("OK", style: TextStyle(color: Theme.of(context).colorScheme.secondary)))
          ])
        ]);
      });
}

Future<bool?> showReccuringDeleteConfirmation(
    BuildContext context, String title, String question) async {
  return await showDialog(
      context: context,
      builder: (_) {
        return AppDialog(title: title, contents: [
          Text(question, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          Wrap(children: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("This Reminder",
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("This & Future Reminders",
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary)))
          ])
        ]);
      });
}
