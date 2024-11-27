import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lm_teams_app/data/models/reminder_model.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/contacts_cubit.dart';
import 'package:lm_teams_app/logic/cubits/entry_history_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/select_list_dialog.dart';
import 'package:lm_teams_app/presentation/screens/contact%20screen/contact_view.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:badges/badges.dart' as bd;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  var isSelected = [true, false, false];
  var isSearching = false;
  var utils = UtilsService();
  final _searchController = TextEditingController();

  @override
  void initState() {
    var user = context.read<UserBloc>().state.user;
    context.read<ContactsCubit>().initialEvent(user.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = context.read<UserBloc>().state.user;
    double width = MediaQuery.of(context).size.width;

    return BlocBuilder<ContactsCubit, ContactsState>(builder: (context, state) {
      var contacts = state.filteredContacts;
      var userReminders = state.userReminders;

      void _onChange(String text) {
        if (text.isNotEmpty) {
          context.read<ContactsCubit>().searchContact(text);
        }
      }

      return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Padding(
              padding: EdgeInsets.all(10.0.spMin),
              child: SafeArea(
                  child: Column(children: [
                Flex(direction: Axis.horizontal, children: [
                  Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                        IconButton(
                            icon: bd.Badge(
                                badgeContent: Text(userReminders.length.toString(),
                                    style: TextStyle(fontSize: 16.0.spMin)),
                                position: BadgePosition.topEnd(),
                                showBadge: userReminders.isNotEmpty,
                                child: Icon(Icons.notifications_outlined, size: 24.0.spMin)),
                            onPressed: userReminders.isNotEmpty
                                ? () async {
                                    var selected = await showListSelectOneDialog<Reminder?>(
                                        context: context,
                                        title: 'Reminders',
                                        items: userReminders,
                                        type: ListItemType.reminder);

                                    if (selected != null) {
                                      var _contact = await BlocProvider.of<ContactsCubit>(context)
                                          .findContact(selected.contactId);

                                      if (_contact != null) {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (newContext) {
                                          return MultiBlocProvider(providers: [
                                            BlocProvider.value(
                                                value: BlocProvider.of<EntryHistoryCubit>(context)),
                                            BlocProvider.value(
                                                value: BlocProvider.of<ContactsCubit>(context))
                                          ], child: ContactView(contact: _contact));
                                        }));
                                      }
                                    }
                                  }
                                : null)
                      ])),
                  Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: SizedBox(
                          height: 50.spMin,
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Visibility(
                                visible: !isSearching,
                                child: ToggleButtons(
                                    constraints: BoxConstraints(
                                        maxHeight: 50.spMin,
                                        minHeight: 50.spMin,
                                        maxWidth: 70.spMin,
                                        minWidth: 70.spMin),
                                    children: [
                                      Text('All', style: TextStyle(fontSize: 12.0.spMin)),
                                      Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10.spMin),
                                          child: Text('Personal',
                                              style: TextStyle(fontSize: 12.0.spMin))),
                                      Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10.spMin),
                                          child: Text('Shared',
                                              style: TextStyle(fontSize: 12.0.spMin)))
                                    ],
                                    isSelected: isSelected,
                                    onPressed: (index) {
                                      setState(() {
                                        for (int i = 0; i < isSelected.length; i++) {
                                          isSelected[i] = i == index;
                                        }
                                      });
                                      BlocProvider.of<ContactsCubit>(context)
                                          .ownerFilter(index, currentUser.id);
                                    }),
                                replacement: SizedBox(
                                    width: 210.spMin,
                                    height: 50.spMin,
                                    child: TextField(
                                        controller: _searchController,
                                        style: TextStyle(fontSize: 16.0.spMin),
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.search, size: 16.0.spMin),
                                            contentPadding: EdgeInsets.all(16.spMin),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(50.0.spMin))),
                                        onChanged: _onChange)))
                          ]))),
                  Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        IconButton(
                            icon: Icon(isSearching ? Icons.close_outlined : Icons.search_outlined,
                                size: 24.0.spMin),
                            onPressed: () {
                              if (isSearching) {
                                _searchController.clear();
                                BlocProvider.of<ContactsCubit>(context)
                                    .ownerFilter(0, currentUser.id);
                              }
                              setState(() {
                                isSearching = !isSearching;
                              });
                            })
                      ]))
                ]),
                Flexible(
                    flex: 0,
                    child: DividerWithText(title: "C O N T A C T S  [ ${contacts.length} ]")),
                Flexible(
                    flex: 10,
                    child: MasonryGridView.count(
                        itemCount: contacts.length,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        crossAxisCount: getCrossAxisCount(width),
                        itemBuilder: (context, index) {
                          return ContactListTile(contact: contacts[index]);
                        }))
              ]))));
    });
  }
}

int getCrossAxisCount(double screenWidth) {
  if (screenWidth > 1000) {
    return 3;
  } else if (screenWidth > 600) {
    return 2;
  }
  return 1;
}
