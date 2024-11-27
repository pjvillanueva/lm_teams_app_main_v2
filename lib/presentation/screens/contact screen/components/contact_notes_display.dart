import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/models/contact_model.dart';

class ContactNotesDisplay extends StatelessWidget {
  ContactNotesDisplay(this.contact, {Key? key}) : super(key: key);

  final Contact contact;
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _noteController.text = contact.notes ?? '';

    return Column(children: [
      Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text('Notes', style: TextStyle(fontSize: 16.spMin))]),
      SizedBox(height: 5.spMin),
      TextField(
          maxLines: 3,
          readOnly: true,
          controller: _noteController,
          style: TextStyle(fontSize: 16.0.spMin),
          decoration: const InputDecoration(
              border: InputBorder.none, alignLabelWithHint: true, filled: true))
    ]);
  }
}
