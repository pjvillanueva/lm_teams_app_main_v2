import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/cubits/team_form_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/invitation_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';

//for teams form
Future<User?> showUserListDialog({
  required BuildContext icontext,
  required String title,
  required bool isLeader,
  required List<User> allUsers,
  required List<User> selectedUsers,
}) async {
  return await showDialog(
      context: icontext,
      builder: (_) {
        bool isSearching = false;
        var _users = allUsers;
        final _controller = TextEditingController();
        return StatefulBuilder(builder: (context, setState) {
          void searchUser(String query) {
            if (query.isNotEmpty) {
              var filteredUsers = allUsers
                  .where((user) => user.name
                      .toLowerCase()
                      .replaceAll(' ', '')
                      .contains(query.toLowerCase().replaceAll(' ', '')))
                  .toList();

              setState(() {
                _users = filteredUsers;
              });
            } else {
              setState(() {
                _users = allUsers;
              });
            }
          }

          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 14),
                  child: Text(title,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: GenericSearchBar(
                      onchanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            isSearching = true;
                          });
                        } else {
                          setState(() {
                            isSearching = false;
                          });
                        }
                        searchUser(value);
                      },
                      controller: _controller,
                      onpressed: () {
                        if (isSearching == true) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _controller.clear();
                          setState(() {
                            _users = allUsers;
                            isSearching = false;
                          });
                        }
                      },
                      icon:
                          isSearching == true ? const Icon(Icons.close) : const Icon(Icons.search)),
                ),
                // Middle Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _users
                            .map((user) => Visibility(
                                visible: !selectedUsers.contains(user),
                                child: ListTile(
                                    leading: Avatar(
                                        isCircle: true,
                                        size: Size(40.0.spMin, 40.0.spMin),
                                        image: user.image,
                                        placeholder: Text(user.initials,
                                            style: TextStyle(fontSize: 16.0.spMin))),
                                    title: Text(user.name),
                                    onTap: () {
                                      Navigator.pop(context, user);
                                    })))
                            .toList()),
                  ),
                ),
                ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.add)),
                    title: Text("Invite new ${isLeader ? "leader" : "member"}"),
                    onTap: () async {
                      var invitation = await showInvitationDialog(context, isLeader: isLeader);

                      if (invitation != null) {
                        BlocProvider.of<TeamFormCubit>(icontext).addInvitation(invitation);

                        var user = User(
                            id: invitation.id,
                            firstName: invitation.firstName,
                            lastName: invitation.lastName,
                            email: invitation.email,
                            mobile: invitation.phoneNumber);

                        Navigator.pop(context, user);
                      }
                    }),
                // Bottom Action Bar
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      });
}
