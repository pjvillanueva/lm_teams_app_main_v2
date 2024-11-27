import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/models/contact_model.dart';
import '../../../dialogs/select_list_dialog.dart';

class ContactButtonsRow extends StatelessWidget {
  const ContactButtonsRow(this.contact, {Key? key}) : super(key: key);

  final Contact contact;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Divider(thickness: 1.0.spMin),
      SizedBox(
          height: 48.0.spMin,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            IconButton(
                icon: Icon(Icons.call_outlined, size: 30.spMin),
                onPressed: () async {
                  var phone = await showListSelectOneDialog(
                      context: context,
                      title: 'Select phone number',
                      items: contact.phone,
                      type: ListItemType.phone);

                  if (phone != null) {
                    Uri url = Uri(scheme: 'tel', path: phone);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      print("Can't open dial pad, $url");
                    }
                  }
                }),
            IconButton(
                icon: Icon(Icons.mail_outlined, size: 30.spMin),
                onPressed: () async {
                  Uri uri = Uri(scheme: 'mailto', path: contact.email);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    throw 'Could not launch $uri';
                  }
                }),
            IconButton(
                icon: Icon(Icons.directions_outlined, size: 30.spMin),
                onPressed: contact.hasLocationEvent
                    ? () async {
                        Uri url = Uri(
                            scheme: 'https',
                            host: 'www.google.com',
                            path: 'maps/search/?api=1&query=${contact.fullAddress}');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        } else {
                          print("Can't open maps");
                        }
                      }
                    : null)
          ])),
      Divider(thickness: 1.0.spMin)
    ]);
  }
}
