import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';

Future<void> showEmptyDialog({required BuildContext context, required String message}) {
  return showDialog(
      context: context,
      builder: (_) {
        return AppDialog(title: '', contents: [
          Column(children: [
            Icon(Icons.warning_rounded, size: 100.0.spMin, color: Colors.red),
            SizedBox(height: 20.0.spMin),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0.spMin)),
            SizedBox(height: 20.0.spMin),
            TextButton(
                child: Text('DISMISS',
                    style: TextStyle(
                        fontSize: 16.0.spMin, color: Theme.of(context).colorScheme.onSurface)),
                onPressed: () => Navigator.pop(context))
          ])
        ]);
      });
}
