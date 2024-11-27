import 'package:flutter/material.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';

Future<bool> showPermissionNeededDialog(
    {required BuildContext context, required String title, required String message}) async {
  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AppDialog(title: title, contents: [
          Text(message)
        ], actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
          TextButton(child: const Text('Proceed'), onPressed: () => Navigator.pop(context, true))
        ]);
      });
}
