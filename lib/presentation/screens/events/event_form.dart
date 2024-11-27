import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/blocs/account_bloc.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/event_form_cubit.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/daterange_picker_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/item_picker_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/select_team_dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/user_checkbox_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/cards.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/items_service.dart';
import '../../dialogs/image_options.dialog.dart';

// ignore: must_be_immutable
class EventForm extends StatefulWidget {
  EventForm({Key? key, required this.users}) : super(key: key);

  List<User> users;

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _validators = CustomValidators();
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _visibilityController = TextEditingController(text: 'true');
  final _itemService = ItemService();

  @override
  Widget build(BuildContext context) {
    final _user = context.read<UserBloc>().state.user;
    final _account = context.read<AccountBloc>().state.account;
    final _homestate = context.read<HomeScreenBloc>().state;
    return BlocProvider(
        create: (context) => EventFormCubit(),
        child: BlocBuilder<EventFormCubit, EventFormState>(builder: (context, state) {
          return AppFrame(
              title: "New Event",
              content: ListView(children: [
                GenericCard(content: [
                  const SmallFormTitle(title: "EVENT IMAGE"),
                  Avatar(
                      imageFile: state.imageFile,
                      size: Size(200.spMin, 200.spMin),
                      borderWidth: 4.0.spMin,
                      placeholder: Icon(Icons.group, size: 100.spMin),
                      onTapButton: () async {
                        var _newImageFile =
                            await showImageOptionsDialog(context, imageFile: state.imageFile);

                        if (_newImageFile != null) {
                          BlocProvider.of<EventFormCubit>(context).addImageFile(_newImageFile);
                        }
                      }),
                  SizedBox(height: 20.spMin)
                ]),
                Divider(thickness: 2.0.spMin),
                Form(
                    key: _formKey,
                    child: GenericCard(content: [
                      const SmallFormTitle(title: "EVENT DETAILS"),
                      AppOutlinedTextFormField(
                          labelText: 'Event Name',
                          hintText: 'Type event name here',
                          controller: _eventNameController,
                          validator: _validators.emptyValidator),
                      const SizedBox(height: 14),
                      DateRangeFormField(
                        controller: TextEditingController(text: state.eventDatesString),
                        validator: _validators.emptyValidator,
                        onPressed: () async {
                          var dates = await openDateRangePicker(
                              context, state.eventStartDate, state.eventEndDate);
                          if (dates != null) {
                            context.read<EventFormCubit>().setEventDates(dates);
                          }
                        },
                      ),
                      SizedBox(height: 14.spMin),
                      AppOutlinedTextFormField(
                          labelText: 'Location',
                          hintText: 'Type event location here',
                          validator: _validators.emptyValidator,
                          controller: _locationController),
                      SizedBox(height: 14.spMin),
                      GenericDropDownInput(
                          items: const [
                            {'value': 'true', 'label': 'Open event'},
                            {'value': 'false', 'label': 'Close event'}
                          ],
                          labelText: 'Visibility',
                          controller: _visibilityController,
                          hintText: 'Please select one option'),
                      const SizedBox(height: 14),
                      ChipInputField(
                          label: 'Leader(s)',
                          onPressed: () async {
                            var selectedLeaders = await showUserCheckboxDialog(
                                icontext: context,
                                title: "Select leader(s)",
                                allUsers: widget.users,
                                selectedLeaders: state.selectedLeaders,
                                selectedMembers: state.selectedMembers,
                                isLeader: true,
                                allowInvite: false);

                            if (selectedLeaders != null) {
                              context.read<EventFormCubit>().addLeaders(selectedLeaders);
                            }
                          },
                          children: state.selectedLeaders
                              .map((leader) => InputChip(
                                  label: Text(leader.name, style: const TextStyle(fontSize: 12)),
                                  avatar: Avatar(
                                      isCircle: true,
                                      size: Size(20.0.spMin, 20.0.spMin),
                                      image: leader.image,
                                      placeholder: Text(leader.initials,
                                          style: TextStyle(fontSize: 12.0.spMin))),
                                  deleteIcon: const Icon(Icons.close),
                                  onDeleted: () {
                                    context.read<EventFormCubit>().removeLeader(leader);
                                  }))
                              .toList()),
                      SizedBox(height: 14.0.spMin),
                      ChipInputField(
                          label: 'Inventory Items',
                          onPressed: () async {
                            var item = await showItemPickerDialog(
                                context: context,
                                items: await _itemService.getItemsForItemPicker(
                                    _user.id, _homestate.team.id, _homestate.event.id),
                                pickedItemCodes: context.read<EventFormCubit>().state.itemCodes);

                            if (item != null) {
                              BlocProvider.of<EventFormCubit>(context).addItem(item);
                            }
                          },
                          children: state.items
                              .map((item) => InputChip(
                                  avatar: Avatar(
                                      size: Size(15.0.spMin, 20.spMin),
                                      image: item.image,
                                      placeholder: Icon(Icons.book, size: 10.spMin)),
                                  label: Text(item.name),
                                  shape: const BeveledRectangleBorder(),
                                  deleteIcon: const Icon(Icons.close),
                                  onDeleted: () {
                                    BlocProvider.of<EventFormCubit>(context).removeItem(item);
                                  }))
                              .toList()),
                      SizedBox(height: 14.spMin),
                      Text("Give teams or individuals access to this event",
                          style: TextStyle(fontSize: 16.0.spMin)),
                      SizedBox(height: 14.spMin),
                      ChipInputField(
                          label: 'Team(s)',
                          onPressed: () async {
                            var selectedTeams = await showSelectTeamDialog(
                                context: context,
                                title: 'Select team',
                                accountId: _account.id,
                                selectedTeams: state.selectedTeams);

                            if (selectedTeams != null && selectedTeams.isNotEmpty) {
                              BlocProvider.of<EventFormCubit>(context).addTeams(selectedTeams);
                            }
                          },
                          children: state.selectedTeams
                              .map((team) => InputChip(
                                    label: Text(team.name, style: const TextStyle(fontSize: 12)),
                                    shape: const BeveledRectangleBorder(),
                                    deleteIcon: const Icon(Icons.close),
                                    onDeleted: () {
                                      context.read<EventFormCubit>().removeTeam(team);
                                    },
                                  ))
                              .toList()),
                      const SizedBox(height: 14),
                      ChipInputField(
                          label: 'Individuals(s)',
                          onPressed: () async {
                            var selectedMembers = await showUserCheckboxDialog(
                                icontext: context,
                                title: 'Select individual(s)',
                                allUsers: widget.users,
                                selectedLeaders: state.selectedLeaders,
                                selectedMembers: state.selectedMembers,
                                isLeader: false,
                                allowInvite: false);

                            if (selectedMembers != null) {
                              context.read<EventFormCubit>().addMember(selectedMembers);
                            }
                          },
                          children: state.selectedMembers
                              .map((member) => InputChip(
                                  label: Text(member.name, style: const TextStyle(fontSize: 12)),
                                  avatar: Avatar(
                                      isCircle: true,
                                      size: Size(20.0.spMin, 20.0.spMin),
                                      image: member.image,
                                      placeholder: Text(member.initials,
                                          style: TextStyle(fontSize: 12.0.spMin))),
                                  deleteIcon: const Icon(Icons.close),
                                  onDeleted: () {
                                    context.read<EventFormCubit>().removeMember(member);
                                  }))
                              .toList()),
                      SizedBox(height: 14.spMin),
                      BlocBuilder<ConnectivityBloc, ConnectivityState>(
                          builder: (context, connectivityState) {
                        return FullWidthButton(
                            title: "SUBMIT",
                            color: Theme.of(context).colorScheme.secondary,
                            onPressed: connectivityState is ConnectedState
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      var event = await BlocProvider.of<EventFormCubit>(context)
                                          .saveEvent(
                                              context,
                                              _formKey,
                                              _eventNameController.text,
                                              _locationController.text,
                                              _visibilityController.text == 'true');

                                      if (event != null) {
                                        Navigator.pop(context, event);
                                        showAppSnackbar(context, 'Successfully added event');
                                        Navigator.pop(context, event);
                                      } else {
                                        Navigator.pop(context);
                                        showAppSnackbar(context, 'Failed to add event',
                                            isError: true);
                                      }
                                    }
                                  }
                                : null);
                      }),
                      SizedBox(height: 14.spMin),
                      FullWidthButton(
                          title: "CANCEL",
                          color: Colors.grey,
                          onPressed: () => Navigator.pop(context))
                    ]))
              ]));
        }));
  }
}
