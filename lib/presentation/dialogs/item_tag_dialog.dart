import 'package:flutter/material.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';

showItemTagDialog(
  BuildContext context,
  List<String> allTags,
) {
  return showDialog(
      context: context,
      builder: (context) {
        return AppDialog(title: "Choose Tag(s)", contents: [
          SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: allTags.length,
                  itemBuilder: (context, int index) {
                    return Column(children: [
                      ListTile(
                          title: Text(allTags[index]),
                          onTap: () {
                            Navigator.pop(context, allTags[index]);
                          })
                    ]);
                  }))
        ]);
      });
}
