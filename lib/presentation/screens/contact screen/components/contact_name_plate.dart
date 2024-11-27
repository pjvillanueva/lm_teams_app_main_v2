import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';

class ContactNamePlate extends StatelessWidget {
  const ContactNamePlate(this.contact, {Key? key}) : super(key: key);

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
          height: 60.spMin,
          width: 60.spMin,
          child: CircleAvatar(
              backgroundColor: Color(contact.avatarColor),
              child: Center(
                  child: Text(contact.initials,
                      style: TextStyle(color: Colors.white, fontSize: 20.spMin))))),
      SizedBox(width: 20.0.spMin),
      Flexible(
          flex: 1,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(contact.name, style: TextStyle(fontSize: 30.spMin)),
            Text(contact.fullAddress, style: TextStyle(fontSize: 15.spMin))
          ]))
    ]);
  }
}
