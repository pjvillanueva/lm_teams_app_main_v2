import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';

Future<bool> showLocationOffDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AppDialog(title: '', crossAxisAlignment: CrossAxisAlignment.center, contents: [
          Icon(Icons.location_off, size: 60.spMin),
          Text('Location service is off',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0.spMin)),
          Text('Turn on location service and try again',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0.spMin)),
          const Divider(),
          FullWidthButton(
              title: 'TURN ON',
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                Navigator.pop(context, true);
              }),
          TextButton(
              child: Text('CLOSE', style: TextStyle(fontSize: 16.0.spMin)),
              onPressed: () {
                Navigator.pop(context, false);
              })
        ]);
      });
}
