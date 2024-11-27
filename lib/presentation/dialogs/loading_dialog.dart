import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';

showLoaderDialog(BuildContext context, {String? loadingText}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AppDialog(title: '', contents: [
        Row(children: [
          const CircularProgressIndicator(),
          SizedBox(width: 20.0.spMin),
          Container(
            margin: EdgeInsets.only(left: 7.0.spMin),
            child: Text(loadingText ?? 'Loading...'),
          )
        ])
      ]);
    },
  );
}
