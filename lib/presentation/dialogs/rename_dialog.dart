import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';

Future<String?> showRenameDialog(BuildContext context, String dialogTitle, String currentName) {
  return showDialog<String?>(
      context: context,
      builder: (_) {
        final _nameController = TextEditingController(text: currentName);
        final _validators = CustomValidators();
        return StatefulBuilder(builder: (statefulContext, setState) {
          return AppDialog(title: dialogTitle, contents: [
            SizedBox(height: 10.0.spMin),
            AppOutlinedTextFormField(
                controller: _nameController,
                labelText: "",
                hintText: "Type new name here",
                maxLines: 1,
                validator: _validators.emptyValidator),
            SizedBox(height: 20.0.spMin),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel",
                      style: TextStyle(
                          fontSize: 16.0.spMin, color: Theme.of(context).colorScheme.onSurface))),
              SizedBox(width: 14.0.spMin),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.secondary)),
                  child: Text("Save", style: TextStyle(fontSize: 16.0.spMin, color: Colors.white)),
                  onPressed: () async {
                    Navigator.pop(context, _nameController.text);
                  })
            ])
          ]);
        });
      });
}
