import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/logic/blocs/home_screen_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/team_form_cubit.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/image_options.dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/item_picker_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/cards.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/items_service.dart';

import '../../dialogs/user_checkbox_dialog.dart';

// ignore: must_be_immutable
class TeamForm extends StatefulWidget {
  TeamForm({Key? key, required this.teams, required this.users}) : super(key: key);

  List<Team> teams;
  List<User> users;

  @override
  State<TeamForm> createState() => _TeamFormState();
}

class _TeamFormState extends State<TeamForm> {
  final validators = CustomValidators();
  final _formKey = GlobalKey<FormState>();
  final _parentTeamController = TextEditingController(text: "*");
  final _teamNameController = TextEditingController();
  final _itemService = ItemService();

  @override
  Widget build(BuildContext context) {
    final _user = context.read<UserBloc>().state.user;
    final _homeState = context.read<HomeScreenBloc>().state;

    return MultiBlocProvider(
        providers: [BlocProvider<TeamFormCubit>(create: (context) => TeamFormCubit())],
        child: BlocBuilder<TeamFormCubit, TeamFormState>(builder: (context, state) {
          List<Map<String, dynamic>> getTeamOptions(List<Team> teams) {
            List<Map<String, dynamic>> list = [
              {'value': '*', 'label': 'Top level team'},
            ];
            for (var team in widget.teams) {
              list.add({'value': team.id, 'label': team.name});
            }
            return list;
          }

          return AppFrame(
              title: "New Team",
              content: ListView(children: [
                GenericCard(content: [
                  const SmallFormTitle(title: "TEAM IMAGE"),
                  Avatar(
                      imageFile: state.imageFile,
                      size: Size(200.spMin, 200.spMin),
                      borderWidth: 4.0.spMin,
                      placeholder: Icon(Icons.group, size: 100.spMin),
                      onTapButton: () async {
                        var _newImageFile =
                            await showImageOptionsDialog(context, imageFile: state.imageFile);

                        if (_newImageFile != null) {
                          BlocProvider.of<TeamFormCubit>(context).addImageFile(_newImageFile);
                        }
                      }),
                  SizedBox(height: 20.spMin)
                ]),
                Divider(thickness: 2.0.spMin),
                Form(
                    key: _formKey,
                    child: GenericCard(content: [
                      const SmallFormTitle(title: "TEAM DETAILS"),
                      GenericDropDownInput(
                          items: getTeamOptions(widget.teams),
                          labelText: "Parent Team",
                          hintText: "Please select a parent team",
                          controller: _parentTeamController,
                          validator: validators.emptyValidator),
                      SizedBox(height: 14.spMin),
                      AppOutlinedTextFormField(
                          labelText: "Team Name",
                          hintText: "Type team name here",
                          controller: _teamNameController,
                          validator: validators.emptyValidator),
                      SizedBox(height: 14.spMin),
                      ChipInputField(
                          label: "Leader(s)",
                          onPressed: () async {
                            var selectedLeaders = await showUserCheckboxDialog(
                                icontext: context,
                                title: "Select leader(s)",
                                allUsers: widget.users,
                                selectedLeaders: state.selectedLeaders,
                                selectedMembers: state.selectedMembers,
                                isLeader: true,
                                allowInvite: true);

                            if (selectedLeaders != null) {
                              context.read<TeamFormCubit>().addLeaders(selectedLeaders);
                            }
                          },
                          children: state.selectedLeaders
                              .map((user) => InputChip(
                                  avatar: Avatar(
                                      isCircle: true,
                                      size: Size(20.spMin, 20.spMin),
                                      image: user.image,
                                      placeholder: Text(user.initials,
                                          style: TextStyle(fontSize: 12.0.spMin))),
                                  label: Text(user.name,
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.onBackground)),
                                  deleteIcon: const Icon(Icons.close),
                                  onDeleted: () {
                                    BlocProvider.of<TeamFormCubit>(context).removeLeader(user);
                                  }))
                              .toList()),
                      SizedBox(height: 14.spMin),
                      ChipInputField(
                          label: "Member(s)",
                          onPressed: () async {
                            var selectedMembers = await showUserCheckboxDialog(
                                icontext: context,
                                title: 'Select member(s)',
                                allUsers: widget.users,
                                selectedLeaders: state.selectedLeaders,
                                selectedMembers: state.selectedMembers,
                                isLeader: false,
                                allowInvite: true);

                            if (selectedMembers != null) {
                              context.read<TeamFormCubit>().addMembers(selectedMembers);
                            }
                          },
                          children: state.selectedMembers
                              .map((user) => InputChip(
                                  avatar: Avatar(
                                      isCircle: true,
                                      size: Size(20.0.spMin, 20.0.spMin),
                                      image: user.image,
                                      placeholder: Text(user.initials,
                                          style: TextStyle(fontSize: 12.0.spMin))),
                                  label: Text(user.name,
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.onBackground)),
                                  deleteIcon: const Icon(Icons.close),
                                  onDeleted: () {
                                    BlocProvider.of<TeamFormCubit>(context).removeMember(user);
                                  }))
                              .toList()),
                      SizedBox(height: 14.spMin),
                      ChipInputField(
                          label: "Inventory Items",
                          onPressed: () async {
                            var item = await showItemPickerDialog(
                                context: context,
                                items: await _itemService.getItemsForItemPicker(
                                    _user.id, _homeState.team.id, _homeState.event.id),
                                pickedItemCodes: context.read<TeamFormCubit>().state.itemCodes);
                            if (item != null) {
                              BlocProvider.of<TeamFormCubit>(context).addItem(item);
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
                                    BlocProvider.of<TeamFormCubit>(context).removeItem(item);
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
                                      var team = await BlocProvider.of<TeamFormCubit>(context)
                                          .saveTeam(context, _formKey, _teamNameController.text,
                                              _parentTeamController.text);

                                      if (team != null) {
                                        Navigator.pop(context, team);
                                        showAppSnackbar(context, 'Successfully added team');
                                        Navigator.pop(context, team);
                                      } else {
                                        Navigator.pop(context);
                                        showAppSnackbar(context, 'Failed to add team',
                                            isError: true);
                                      }
                                    }
                                  }
                                : null);
                      }),
                      SizedBox(height: 14.0.spMin),
                      FullWidthButton(
                          title: "CANCEL",
                          color: Colors.grey,
                          onPressed: () {
                            Navigator.pop(context);
                          })
                    ]))
              ]));
        }));
  }
}
