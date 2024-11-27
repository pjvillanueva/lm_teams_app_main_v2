import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';
import '../../logic/cubits/team_form_cubit.dart';
import 'invitation_dialog.dart';

Future<List<User>?> showUserCheckboxDialog({
  required BuildContext icontext,
  required String title,
  required List<User> allUsers,
  required List<User> selectedLeaders,
  required List<User> selectedMembers,
  required bool isLeader,
  required bool allowInvite,
}) async {
  return await showDialog(
      context: icontext,
      builder: (context) {
        bool isSearching = false;
        List<UserCheckboxItem> items =
            userToCheckboxItem(allUsers, selectedLeaders, selectedMembers, isLeader);
        List<UserCheckboxItem> filteredItems = [];

        final _controller = TextEditingController();

        return StatefulBuilder(builder: (context, setState) {
          void searchUser(String query) {
            if (query.isNotEmpty) {
              var _filteredItems = items
                  .where((_item) => _item.user.name
                      .toLowerCase()
                      .replaceAll(' ', '')
                      .contains(query.toLowerCase().replaceAll(' ', '')))
                  .toList();

              setState(() {
                isSearching = true;
                filteredItems = _filteredItems;
              });
            } else {
              setState(() {
                isSearching = false;
              });
            }
          }

          var _items = isSearching ? filteredItems : items;

          return Dialog(
              child: Container(
                  height: 400.spMin,
                  color: Theme.of(context).colorScheme.background,
                  padding: EdgeInsets.all(20.0.spMin),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DialogTitle(title: title),
                        SizedBox(height: 20.0.spMin),
                        GenericSearchBar(
                            icon: isSearching ? const Icon(Icons.close) : const Icon(Icons.search),
                            onchanged: (value) {
                              searchUser(value);
                            },
                            controller: _controller,
                            onpressed: () {
                              if (isSearching == true) {
                                FocusScope.of(context).requestFocus(FocusNode());
                                _controller.clear();
                                setState(() {
                                  isSearching = false;
                                });
                              }
                            }),
                        SizedBox(height: 10.0.spMin),
                        Expanded(
                            child: Scrollbar(
                                child: ListView.builder(
                                    itemCount: _items.length,
                                    itemBuilder: (context, int index) {
                                      UserCheckboxItem _item = _items[index];
                                      return Visibility(
                                          visible: isLeader
                                              ? !selectedMembers.contains(_item.user)
                                              : !selectedLeaders.contains(_item.user),
                                          child: CheckboxListTile(
                                              title: Row(children: [
                                                Avatar(
                                                    isCircle: true,
                                                    size: Size(40.0.spMin, 40.0.spMin),
                                                    image: _item.user.image,
                                                    placeholder: Text(_item.user.initials,
                                                        style: TextStyle(fontSize: 16.0.spMin))),
                                                SizedBox(width: 5.0.spMin),
                                                Flexible(
                                                    child: Text(_item.user.name,
                                                        overflow: TextOverflow.ellipsis))
                                              ]),
                                              activeColor: Theme.of(context).colorScheme.secondary,
                                              value: _item.isChecked,
                                              onChanged: (value) {
                                                setState(() {
                                                  _item.isChecked = value!;
                                                });
                                              }));
                                    }))),
                        SizedBox(height: 15.spMin),
                        Visibility(
                          visible: allowInvite,
                          child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.add)),
                              title: Text("Invite new ${isLeader ? "leader" : "member"}"),
                              onTap: () async {
                                var invitation =
                                    await showInvitationDialog(context, isLeader: isLeader);

                                if (invitation != null) {
                                  icontext.read<TeamFormCubit>().addInvitation(invitation);

                                  var user = User(
                                      id: invitation.id,
                                      firstName: invitation.firstName,
                                      lastName: invitation.lastName,
                                      email: invitation.email,
                                      mobile: invitation.phoneNumber);

                                  Navigator.pop(context, [user]);
                                }
                              }),
                        ),
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          TextButton(
                              onPressed: () {
                                List<User> selectedUsers = [];
                                for (var item in _items) {
                                  if (item.isChecked) {
                                    selectedUsers.add(item.user);
                                  }
                                }
                                Navigator.pop(context, selectedUsers);
                              },
                              child: const Text("DONE")),
                          TextButton(
                              onPressed: () => Navigator.pop(context), child: const Text("CANCEL"))
                        ])
                      ])));
        });
      });
}

class UserCheckboxItem {
  UserCheckboxItem({required this.user, required this.isChecked});
  final User user;
  bool isChecked;

  @override
  String toString() => "UserCheckboxItem: user: $user, isChecked: $isChecked";
}

List<UserCheckboxItem> userToCheckboxItem(
    List<User> allUsers, List<User> selectedLeaders, List<User> selectedMembers, bool isLeader) {
  List<UserCheckboxItem> items = [];
  for (var user in allUsers) {
    items.add(UserCheckboxItem(
        user: user,
        isChecked: isLeader ? selectedLeaders.contains(user) : selectedMembers.contains(user)));
  }
  return items;
}
