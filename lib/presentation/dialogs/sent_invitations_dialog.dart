import 'package:flutter/material.dart';
import 'package:lm_teams_app/data/models/user%20model/team_invitee.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';

showSentInvitationListDialog({
  required BuildContext context,
  required List<TeamInvitee> invitees,
}) {
  return showDialog(
      context: context,
      builder: (context) {
        return AppDialog(title: 'Sent Invitations', contents: [
          SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(children: [
                const DividerWithText(title: 'I N V I T A T I O N S'),
                Expanded(
                    child: invitees.isNotEmpty
                        ? Scrollbar(
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: invitees.length,
                                itemBuilder: (context, index) {
                                  var _invitee = invitees[index];
                                  return Card(
                                      color: Theme.of(context).colorScheme.surface,
                                      child: ListTile(
                                        leading: const Icon(Icons.person),
                                        title: Text(_invitee.name),
                                        subtitle: Text('Invited by ${_invitee.inviterName}'),
                                        tileColor: Theme.of(context).colorScheme.surface,
                                      ));
                                }))
                        : Column(children: [
                            Center(
                                child:
                                    Image.asset('assets/logo/folder.png', width: 200, height: 200)),
                            const Text('Invitations is empty')
                          ]))
              ]))
        ]);
      });
}
