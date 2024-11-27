import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/cubits/entry_history_cubit.dart';
import 'package:lm_teams_app/logic/cubits/users_cubit.dart';
import '../../../../data/models/contact_model.dart';
import '../../../../data/models/user model/user.dart';
import '../../../../logic/blocs/user_bloc.dart';
import '../../../../logic/cubits/contacts_cubit.dart';
import '../../../../services/contact_service.dart';
import '../../../dialogs/confirmation_dialog.dart';
import '../../../dialogs/empty_dialog.dart';
import '../../../dialogs/select_list_dialog.dart';
import '../../../widgets/bottom_sheet.dart';
import '../../../widgets/snackbar.dart';
import 'contact_edit_dialog.dart';

// ignore: must_be_immutable
class ContactActionsMenu extends StatefulWidget {
  ContactActionsMenu(this.contact, this.updateContact, {Key? key}) : super(key: key);

  Contact contact;
  void Function(Contact) updateContact;

  @override
  State<ContactActionsMenu> createState() => _ContactActionsMenuState();
}

class _ContactActionsMenuState extends State<ContactActionsMenu> {
  final _contactService = ContactService();

  @override
  Widget build(BuildContext context) {
    var user = context.read<UserBloc>().state.user;

    return IconButton(
        icon: Icon(Icons.more_vert_outlined,
            color: Theme.of(context).colorScheme.onBackground, size: 24.0.spMin),
        onPressed: () {
          showAppBottomSheet(context, [
            Visibility(
                visible: widget.contact.ownerId == user.id,
                child: ListTile(
                    leading: Icon(Icons.share_outlined, size: 24.0.spMin),
                    minLeadingWidth: 30.0.spMin,
                    title: Text('Share Contact', style: TextStyle(fontSize: 16.0.spMin)),
                    onTap: () async {
                      Navigator.pop(context);
                      User user = context.read<UserBloc>().state.user;
                      List<User> userList = List.from(context.read<UsersCubit>().state.users);

                      userList.removeWhere((u) => u.id == user.id);
                      userList.removeWhere((user) => widget.contact.sharedWith.contains(user.id));
                      userList.removeWhere((user) => user.id == widget.contact.ownerId);

                      if (userList.isNotEmpty) {
                        var selectedUser = await showListSelectOneDialog<User?>(
                            context: context,
                            title: 'Share Contact',
                            items: userList,
                            type: ListItemType.user);

                        if (selectedUser != null) {
                          var contact = widget.contact;
                          contact.sharedWith.add(selectedUser.id);
                          _contactService.shareContact(contact);
                          setState(() {
                            widget.contact.sharedWith.add(selectedUser.id);
                          });
                        }
                      } else {
                        await showEmptyDialog(
                            context: context, message: 'No available user to share contact');
                      }
                    })),
            Visibility(
                visible: widget.contact.ownerId == user.id,
                child: ListTile(
                    leading: Icon(Icons.edit_outlined, size: 24.0.spMin),
                    title: Text('Edit Contact', style: TextStyle(fontSize: 16.0.spMin)),
                    minLeadingWidth: 30.0.spMin,
                    onTap: () async {
                      Navigator.pop(context);
                      var _contact = await showContactEditDialog(context, contact: widget.contact);
                      if (_contact != null) {
                        context.read<ContactsCubit>().updateContact(_contact);
                        context.read<EntryHistoryCubit>().updateContactEntry(_contact);
                        widget.updateContact(_contact);
                      }
                    })),
            ListTile(
                leading: Icon(Icons.delete_outlined, size: 24.0.spMin),
                title: Text('Delete Contact', style: TextStyle(fontSize: 16.0.spMin)),
                minLeadingWidth: 30.0.spMin,
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    var proceedDelete = await showDeleteConfirmation(
                        context, 'Delete contact', 'Are you sure you want to delete this contact?');

                    if (proceedDelete) {
                      //delete contact entry in entry page
                      await context.read<EntryHistoryCubit>().deleteContactEntry(widget.contact.id);
                      //delete contact in db and contact screen
                      context.read<ContactsCubit>().deleteContact(widget.contact, user.id);
                      Navigator.pop(context);
                      showAppSnackbar(context, 'Contact deleted');
                    }
                  } catch (e) {
                    print(e);
                    showAppSnackbar(context, 'Failed to delete contact', isError: true);
                  }
                })
          ]);
        });
  }
}
