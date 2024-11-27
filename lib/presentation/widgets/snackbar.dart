import 'package:flutter/material.dart';

showAppSnackbar(BuildContext context, String text,
    {bool isError = false, String actionLabel = 'DISMISS'}) {
  final snackBar = SnackBar(
    backgroundColor: isError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.surface,
    behavior: SnackBarBehavior.floating,
    elevation: 5.0,
    action: SnackBarAction(
        label: actionLabel,
        textColor:
            isError ? Colors.white : Theme.of(context).colorScheme.secondary,
        onPressed: () {
          // ScaffoldMessenger.of(context).removeCurrentSnackBar();
        }),
    content: Text(text,
        style: TextStyle(
            color: isError
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface)),
  );
  FocusScope.of(context).unfocus();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
