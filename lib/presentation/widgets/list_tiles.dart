// ignore_for_file: must_be_immutable

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';
import 'package:lm_teams_app/data/models/reminder_model.dart';
import 'package:lm_teams_app/data/models/team%20model/team.dart';
import 'package:lm_teams_app/logic/cubits/entry_history_cubit.dart';
import 'package:lm_teams_app/presentation/dialogs/select_list_dialog.dart';
import 'package:lm_teams_app/presentation/screens/app_web_view.dart';
import 'package:lm_teams_app/presentation/screens/contact%20screen/contact_view.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/presentation/widgets/under_maintenance.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/inventory models/inventory_item.dart';
import '../../logic/cubits/contacts_cubit.dart';
import '../../logic/cubits/teams_cubit.dart';
import 'avatars.dart';

class GenericListTile extends StatelessWidget {
  const GenericListTile({Key? key, this.leading, this.title, this.subTitle, this.onTap})
      : super(key: key);
  final Widget? leading;
  final String? title;
  final String? subTitle;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      minLeadingWidth: 50.0.spMin,
      title: Text(
        title ?? "",
        style: TextStyle(
            fontSize: 16.0.spMin,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface),
      ),
      subtitle: Text(subTitle ?? "", style: TextStyle(fontSize: 14.0.spMin)),
      onTap: onTap,
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile(this.title, this.assetName, this.widget, {Key? key, this.onTap})
      : super(key: key);

  final String title;
  final String assetName;
  final Widget? widget;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 60.spMin,
        child: ListTile(
            leading: SvgPicture.asset('assets/svgIcons/' + assetName,
                width: 30.0.spMin,
                height: 30.0.spMin,
                allowDrawingOutsideViewBox: false,
                fit: BoxFit.cover,
                colorFilter:
                    ColorFilter.mode(Theme.of(context).colorScheme.secondary, BlendMode.srcIn)),
            title: Text(title, style: TextStyle(fontSize: 18.0.spMin)),
            onTap: onTap ??
                () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => widget ?? const UnderMaintenance()));
                }));
  }
}

class ReminderListTile extends StatelessWidget {
  const ReminderListTile(
      {Key? key,
      required this.reminder,
      required this.trailingIcon,
      this.onPressedLeading,
      this.onPressedTrailing})
      : super(key: key);

  final Reminder reminder;
  final IconData trailingIcon;
  final void Function()? onPressedLeading;
  final void Function()? onPressedTrailing;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: reminder.isDatePassed ? Colors.red : Colors.blue,
            borderRadius: BorderRadius.all(Radius.circular(5.0.spMin))),
        child: Padding(
            padding: EdgeInsets.all(10.0.spMin),
            child: Row(children: [
              GestureDetector(
                child: Icon(
                    reminder.isDatePassed ? Icons.notifications_off : Icons.notifications_active,
                    color: reminder.isDatePassed ? Colors.white : Colors.yellow,
                    size: 24.0.spMin),
                onTap: onPressedLeading,
              ),
              SizedBox(width: 10.spMin),
              Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(reminder.reminderTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0.spMin)),
                Text(reminder.notes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.0.spMin))
              ])),
              SizedBox(width: 10.spMin),
              GestureDetector(child: Icon(trailingIcon, size: 24.0.spMin), onTap: onPressedTrailing)
            ])));
  }
}

class ContactListTile extends StatelessWidget {
  const ContactListTile({Key? key, required this.contact}) : super(key: key);

  final Contact contact;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: GestureDetector(
            child: Card(
                shape: const RoundedRectangleBorder(),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                    padding: EdgeInsets.all(8.0.spMin),
                    child: Column(children: [
                      Row(children: [
                        SizedBox(
                            height: 50.spMin,
                            width: 50.spMin,
                            child: CircleAvatar(
                                backgroundColor: Color(contact.avatarColor),
                                child: Center(
                                    child: Text(contact.initials,
                                        style: TextStyle(color: Colors.white, fontSize: 20.sp))))),
                        SizedBox(width: 10.0.spMin),
                        Flexible(
                            flex: 1,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(contact.name, style: TextStyle(fontSize: 20.sp)),
                              Visibility(
                                  visible: contact.fullAddress.isNotEmpty,
                                  child: Text(contact.fullAddress,
                                      style: TextStyle(fontSize: 15.sp, color: Colors.grey)))
                            ]))
                      ]),
                      const Divider(color: Colors.grey),
                      Visibility(
                          visible: contact.notes?.isNotEmpty ?? false,
                          child: Row(children: [
                            SizedBox(height: 50.0.spMin, width: 60.0.spMin),
                            Flexible(
                                flex: 1,
                                child: Text(contact.notes ?? '',
                                    maxLines: 2, style: TextStyle(fontSize: 16.0.spMin)))
                          ])),
                      Visibility(
                          visible: contact.phone.isNotEmpty &&
                              contact.email != null &&
                              contact.email!.isNotEmpty &&
                              contact.fullAddress.isNotEmpty,
                          child: SizedBox(
                              height: 30.spMin,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Visibility(
                                        visible: contact.phone.isNotEmpty,
                                        child: GestureDetector(
                                            child: Icon(Icons.call,
                                                color: Colors.orange, size: 24.0.spMin),
                                            onTap: () async {
                                              var selectedPhone = await showListSelectOneDialog(
                                                  context: context,
                                                  title: 'Select phone number',
                                                  items: contact.phone,
                                                  type: ListItemType.phone);
                                              if (selectedPhone != null) {
                                                Uri url = Uri(scheme: 'tel', path: selectedPhone);
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(url);
                                                } else {
                                                  showAppSnackbar(context, "Can't open dial pad",
                                                      isError: true);
                                                }
                                              }
                                            })),
                                    SizedBox(width: 20.0.spMin),
                                    Visibility(
                                        visible: contact.email != null && contact.email!.isNotEmpty,
                                        child: GestureDetector(
                                            child: Icon(Icons.mail,
                                                color: Colors.green, size: 24.0.spMin),
                                            onTap: () async {
                                              Uri uri = Uri(scheme: 'mailto', path: contact.email);

                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri);
                                              } else {
                                                throw 'Could not launch $uri';
                                              }
                                            })),
                                    SizedBox(width: 20.0.spMin),
                                    Visibility(
                                        visible: contact.fullAddress.isNotEmpty,
                                        child: GestureDetector(
                                            child: Icon(Icons.directions,
                                                color: Colors.blue, size: 24.0.spMin),
                                            onTap: () async {
                                              Uri url = Uri(
                                                  scheme: 'https',
                                                  host: 'www.google.com',
                                                  path:
                                                      'maps/search/?api=1&query=${contact.fullAddress}');
                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(url);
                                              } else {
                                                print("Can't open maps");
                                              }
                                            }))
                                  ])))
                    ]))),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (newContext) {
                return MultiBlocProvider(providers: [
                  BlocProvider.value(value: BlocProvider.of<EntryHistoryCubit>(context)),
                  BlocProvider.value(value: BlocProvider.of<ContactsCubit>(context))
                ], child: ContactView(contact: contact));
              }));
            }));
  }
}

class InventoryItemListTile extends StatelessWidget {
  const InventoryItemListTile({Key? key, required this.item, this.trailing, this.onTap})
      : super(key: key);
  final InventoryItem item;
  final Widget? trailing;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Card(
        color: Theme.of(context).colorScheme.surface,
        child: ListTile(
            title: Text(item.name, style: TextStyle(fontSize: 18.0.spMin)),
            minLeadingWidth: 50.spMin,
            leading: Avatar(
                size: Size(screenWidth / 9.spMin, 80.spMin),
                image: item.image,
                placeholder: Text(item.code, style: TextStyle(fontSize: 20.spMin))),
            contentPadding: EdgeInsets.all(10.0.spMin),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text("\$ ${item.cost}", style: TextStyle(fontSize: 16.0.spMin)),
              SizedBox(width: 10.spMin),
              trailing ?? const SizedBox()
            ]),
            onTap: onTap));
  }
}

class TermsAndPrivacyCheckboxListTile extends StatefulWidget {
  TermsAndPrivacyCheckboxListTile({Key? key, required this.agreeToTerms, required this.onChanged})
      : super(key: key);

  bool agreeToTerms;
  void Function(bool?)? onChanged;
  @override
  State<TermsAndPrivacyCheckboxListTile> createState() => _TermsAndPrivacyCheckboxListTileState();
}

class _TermsAndPrivacyCheckboxListTileState extends State<TermsAndPrivacyCheckboxListTile> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Checkbox(value: widget.agreeToTerms, onChanged: widget.onChanged),
      Flexible(
          child: RichText(
              text: TextSpan(
                  text: 'I have read and agree to the ',
                  style: TextStyle(
                      fontSize: 14.0.spMin, color: Theme.of(context).colorScheme.onSurface),
                  children: [
            TextSpan(
                text: 'Terms of Service',
                style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    print(termsOfServiceUrl);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AppWebView(title: 'Terms of Service', url: termsOfServiceUrl)));
                  }),
            const TextSpan(text: ' and '),
            TextSpan(
                text: 'Privacy Policy',
                style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AppWebView(title: 'Privacy Policy', url: privacyPolicyUrl)));
                  })
          ])))
    ]);
  }
}

class TeamExpansionTile extends StatefulWidget {
  const TeamExpansionTile(
      {Key? key, required this.parent, required this.children, required this.depth, this.onTap})
      : super(key: key);

  final Parent parent;
  final List<Widget> children;
  final int depth;
  final void Function()? onTap;

  @override
  State<TeamExpansionTile> createState() => _TeamExpansionTileState();
}

class _TeamExpansionTileState extends State<TeamExpansionTile> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        leading: widget.children.isNotEmpty
            ? Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: _isExpanded ? Colors.grey : Theme.of(context).colorScheme.secondary,
                size: 20.0.spMin)
            : const SizedBox(),
        tilePadding: widget.depth == 1 ? EdgeInsets.zero : EdgeInsets.only(left: widget.depth * 10),
        title: _teamNameAndImage(context, widget.parent.self, widget.onTap),
        children: widget.children.toList(),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (isExpanded) {
          setState(() {
            _isExpanded = isExpanded;
          });
        });
  }
}

Widget _teamNameAndImage(BuildContext context, Team team, void Function()? onTap) {
  return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Avatar(
            image: team.image,
            placeholder: Icon(Icons.groups, color: Colors.grey.shade100),
            size: Size(30.spMin, 30.spMin)),
        SizedBox(width: 10.0.spMin),
        Expanded(
            child: Text(team.name,
                style:
                    TextStyle(fontSize: 16.0.spMin, color: Theme.of(context).colorScheme.onSurface),
                overflow: TextOverflow.ellipsis))
      ]));
}
