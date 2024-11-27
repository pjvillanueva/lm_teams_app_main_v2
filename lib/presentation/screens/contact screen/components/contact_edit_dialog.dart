import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/contact_model.dart';
import 'package:lm_teams_app/presentation/dialogs/dialog%20models/app_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import '../../../widgets/snackbar.dart';

Future<Contact?> showContactEditDialog(BuildContext context, {required Contact contact}) async {
  bool isLoading = false;
  List _phoneNumbers = _initializePhoneNumbers(contact.phone);
  final _contactNameController = TextEditingController(text: contact.name);
  final _houseNumberController = TextEditingController(text: contact.houseNumber);
  final _streetNameController = TextEditingController(text: contact.street);
  var _addressController = TextEditingController(text: contact.address);
  final _emailController = TextEditingController(text: contact.email);
  final _notesController = TextEditingController(text: contact.notes);

  return await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (statefulContext, setState) {
          return AppDialog(title: 'Edit Contact', contents: [
            SizedBox(height: 20.0.spMin),
            AppOutlinedTextFormField(
                labelText: 'Name', hintText: 'John Smith', controller: _contactNameController),
            SizedBox(height: 10.0.spMin),
            Row(children: [
              Expanded(
                  flex: 2,
                  child: AppOutlinedTextFormField(
                      controller: _houseNumberController,
                      labelText: '#',
                      hintText: 'Type your answer here...')),
              SizedBox(width: 10.0.spMin),
              Expanded(
                  flex: 4,
                  child: AppOutlinedTextFormField(
                      controller: _streetNameController,
                      labelText: "Street",
                      hintText: "Type your answer here..."))
            ]),
            SizedBox(height: 10.0.spMin),
            AppOutlinedTextFormField(
                controller: _addressController,
                labelText: "Address",
                hintText: "Type your answer here..."),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(width: 3.0.spMin),
              Text('PHONE NUMBER(S)', style: TextStyle(fontSize: 12.spMin)),
              const Spacer(),
              Visibility(
                  visible: _phoneNumbers.length < 3,
                  child: IconButton(
                      icon: Icon(Icons.add, size: 16.0.spMin),
                      onPressed: () {
                        if (_phoneNumbers.length < 3) {
                          setState(() {
                            _phoneNumbers.add('');
                          });
                        }
                      }),
                  replacement: const IconButton(onPressed: null, icon: Text('')))
            ]),
            Column(
                mainAxisSize: MainAxisSize.min,
                children: _phoneNumbers.asMap().entries.map((phoneNumber) {
                  var index = phoneNumber.key;
                  return Column(children: [
                    AppOutlinedPhoneNumberInput(
                        initialPhoneNumber: _phoneNumbers[index],
                        labelText: 'Phone ${index + 1}',
                        suffixIcon: IconButton(
                            icon: Icon(Icons.delete_outlined, size: 24.0.spMin),
                            onPressed: () => setState(() {
                                  _phoneNumbers.removeAt(index);
                                })),
                        updateController: (value) => _phoneNumbers[index] = value),
                    SizedBox(height: 10.0.spMin)
                  ]);
                }).toList()),
            AppOutlinedTextFormField(
                controller: _emailController,
                labelText: "Email",
                hintText: "Type your answer here..."),
            SizedBox(height: 10.0.spMin),
            AppOutlinedTextFormField(
                controller: _notesController,
                labelText: "Notes",
                hintText: "Type your answer here...",
                maxLines: 3),
            SizedBox(height: 10.0.spMin),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel",
                      style: TextStyle(
                          fontSize: 16.0.spMin, color: Theme.of(context).colorScheme.onSurface))),
              SizedBox(width: 14.0.spMin),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Theme.of(context).colorScheme.secondary)),
                  child: isLoading
                      ? SizedBox(
                          child: CircularProgressIndicator(
                            strokeWidth: 4.0.spMin,
                          ),
                          height: 20.0.spMin,
                          width: 20.0.spMin)
                      : Text("Save", style: TextStyle(fontSize: 16.0.spMin, color: Colors.white)),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);

                          var _contact = Contact(
                              id: contact.id,
                              ownerId: contact.ownerId,
                              name: _contactNameController.text,
                              houseNumber: _houseNumberController.text,
                              street: _streetNameController.text,
                              address: _addressController.text,
                              color: contact.color,
                              phone: _phoneNumbers
                                  .where((phoneNumber) => phoneNumber.isNotEmpty)
                                  .toList(),
                              email: _emailController.text,
                              notes: _notesController.text,
                              sharedWith: const [],
                              locationEvent: contact.locationEvent);

                          if (contact == _contact) {
                            Navigator.pop(context);
                            showAppSnackbar(context, 'No changes made', isError: true);
                            return;
                          }
                          Navigator.pop(context, _contact);
                        })
            ])
          ]);
        });
      });
}

//initialize phone numbers
List _initializePhoneNumbers(List? phoneNumbers) {
  if (phoneNumbers != null && phoneNumbers.isNotEmpty) {
    return phoneNumbers.map((e) => e).toList();
  }
  return [];
}
