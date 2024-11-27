// ignore_for_file: must_be_immutable
import 'package:flutter/material.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'components/contact_actions_menu.dart';
import 'components/contact_buttons_row.dart';
import 'components/contact_interactions_section.dart';
import 'components/contact_name_plate.dart';
import 'components/contact_notes_display.dart';
import 'components/contact_reminders_section.dart';

class ContactView extends StatefulWidget {
  ContactView({Key? key, required this.contact}) : super(key: key);

  Contact contact;

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  late Contact _contact;

  @override
  void initState() {
    _contact = widget.contact;
    super.initState();
  }

  void _updateContact(Contact updatedContact) {
    setState(() {
      _contact = updatedContact;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: false,
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: PreferredSize(
            preferredSize: Size(double.infinity, 56.spMin),
            child: AppBar(
                leadingWidth: 56.0.spMin,
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: Theme.of(context).colorScheme.onBackground, size: 24.0.spMin),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                actions: [ContactActionsMenu(_contact, _updateContact)],
                backgroundColor: Theme.of(context).colorScheme.background,
                elevation: 0.0,
                centerTitle: true)),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.spMin),
                child: ListView(children: [
                  Column(children: [
                    ContactNamePlate(_contact),
                    SizedBox(height: 10.spMin),
                    ContactButtonsRow(_contact),
                    SizedBox(height: 10.spMin),
                    ContactNotesDisplay(_contact),
                    ContactRemindersSection(_contact),
                    ContactInteractionsSection(_contact)
                  ])
                ]))));
  }
}
