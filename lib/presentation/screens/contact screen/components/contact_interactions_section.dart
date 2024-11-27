import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/contacts_cubit.dart';
import 'package:lm_teams_app/logic/cubits/users_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/interaction_dialog.dart';
import '../../../../data/models/contact_model.dart';
import '../../../../data/models/interaction model/interaction_model.dart';
import '../../../dialogs/confirmation_dialog.dart';
import '../../../widgets/accordions.dart';
import '../../../widgets/snackbar.dart';

class ContactInteractionsSection extends StatefulWidget {
  const ContactInteractionsSection(this.contact, {Key? key}) : super(key: key);

  final Contact contact;

  @override
  State<ContactInteractionsSection> createState() => _ContactInteractionsSectionState();
}

class _ContactInteractionsSectionState extends State<ContactInteractionsSection> {
  @override
  Widget build(BuildContext context) {
    var users = context.read<UsersCubit>().state.users;
    var user = context.read<UserBloc>().state.user;

    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        var interactions = state.getContactInteractions(widget.contact.id);
        return Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Visits & Studies', style: TextStyle(fontSize: 16.spMin)),
            IconButton(
                icon: Icon(Icons.add_circle_outline, size: 24.0.spMin),
                onPressed: () async {
                  try {
                    InteractionDialogData? dialogData = await showInteractionDialog(
                        context: context, contact: widget.contact, canvassers: users);

                    if (dialogData == null) return;

                    if (dialogData.interaction != null) {
                      try {
                        context.read<ContactsCubit>().addInteraction(dialogData.interaction!);
                        showAppSnackbar(context, 'Interaction Saved');
                      } catch (e) {
                        showAppSnackbar(context, 'Error saving interaction', isError: true);
                      }
                    }

                    if (dialogData.reminder != null) {
                      try {
                        context.read<ContactsCubit>().addReminder(dialogData.reminder!, user.id);
                        showAppSnackbar(context, 'Reminder Set');
                      } catch (e) {
                        showAppSnackbar(context, 'Error setting reminder', isError: true);
                      }
                    }
                  } catch (e) {
                    print('Error in interaction dialog');
                  }
                })
          ]),
          Column(mainAxisSize: MainAxisSize.min, children: [
            ListView.separated(
                shrinkWrap: true,
                itemCount: interactions.length,
                separatorBuilder: (context, index) => SizedBox(height: 5.spMin),
                itemBuilder: (context, index) {
                  Interaction interaction = interactions[index];

                  return InteractionAccordion(
                      interaction: interaction,
                      users: users,
                      onEdit: () async {
                        try {
                          InteractionDialogData? _dialogData = await showInteractionDialog(
                              context: context,
                              contact: widget.contact,
                              canvassers: users,
                              interaction: interaction);

                          if (_dialogData == null) return;

                          if (_dialogData.interaction! == interaction) {
                            showAppSnackbar(context, 'No changes made', isError: true);
                            return;
                          }

                          if (_dialogData.interaction != null) {
                            context
                                .read<ContactsCubit>()
                                .updateInteraction(_dialogData.interaction!);
                            showAppSnackbar(context, 'Changes saved');
                          }
                        } catch (e) {
                          print('Error in interaction dialog: $e');
                        }
                      },
                      onDelete: () async {
                        try {
                          bool isStudy = interaction.type == InteractionType.BibleStudy;
                          var proceedDelete = await showDeleteConfirmation(
                              context,
                              'Delete ${isStudy ? 'Bible Study' : 'Visit'}',
                              'Are you sure you want to delete this ${isStudy ? 'study' : 'visit'} interaction?');

                          if (proceedDelete) {
                            await context.read<ContactsCubit>().deleteInteraction(interaction);
                            showAppSnackbar(context,
                                '${isStudy ? 'Bible Study' : 'Visit'} interaction deleted');
                          }
                        } catch (e) {
                          print(e);
                        }
                      });
                })
          ])
        ]);
      },
    );
  }
}
