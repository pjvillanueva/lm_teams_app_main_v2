import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/invitation_data.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/texts.dart';
import 'package:lm_teams_app/services/team_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';

Future<InvitationData?> showInvitationDialog(BuildContext context,
    {bool isLeader = false, bool enableRoleField = true}) async {
  return showDialog(
      context: context,
      builder: (_) {
        return InvitationDialog(isLeader: isLeader, enableRoleField: enableRoleField);
      });
}

class InvitationDialog extends StatefulWidget {
  const InvitationDialog({Key? key, required this.isLeader, required this.enableRoleField})
      : super(key: key);

  final bool isLeader;
  final bool enableRoleField;

  @override
  State<InvitationDialog> createState() => _InvitationDialogState();
}

class _InvitationDialogState extends State<InvitationDialog> {
  final _validators = CustomValidators();
  final _utils = UtilsService();
  final _teamService = TeamService();
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _inviteeRoleController = TextEditingController();
  final _messageController = TextEditingController();
  int errorCode = 0;

  final List<Map<String, dynamic>> _inviteeRoles = [
    {'value': false, 'label': 'Member'},
    {'value': true, 'label': 'Leader'}
  ];

  final List<Map<String, dynamic>> _options = [
    {'value': 'sms', 'label': 'SMS'},
    {'value': 'email', 'label': 'Email'}
  ];

  List<String> _deliveryOptions = [];

  @override
  void initState() {
    var user = context.read<UserBloc>().state.user;
    _inviteeRoleController.text = widget.isLeader ? 'true' : 'false';
    _messageController.text =
        '${user.name} is inviting you to be a ${widget.isLeader ? "leader" : "member"} of a literature ministry team, ';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: SingleChildScrollView(
            child: Container(
                color: Theme.of(context).colorScheme.surface,
                padding: EdgeInsets.all(20.spMin),
                child: Form(
                    key: _formKey,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DialogTitle(
                              title: 'Invite a new ${widget.isLeader ? 'Leader' : 'Member'}'),
                          SizedBox(height: 30.spMin),
                          AppDropdownField(
                              enabled: widget.enableRoleField,
                              items: _inviteeRoles,
                              labelText: 'Role',
                              hintText: '',
                              controller: _inviteeRoleController),
                          SizedBox(height: 15.spMin),
                          AppOutlinedTextFormField(
                              labelText: "First Name",
                              hintText: "Type your answer here",
                              controller: _firstNameController,
                              validator: _validators.emptyValidator),
                          SizedBox(height: 15.0.spMin),
                          AppOutlinedTextFormField(
                              labelText: "Last Name",
                              hintText: "Type your answer here",
                              controller: _lastNameController,
                              validator: _validators.emptyValidator),
                          SizedBox(height: 15.0.spMin),
                          AppOutlinedTextFormField(
                              labelText: "Email",
                              hintText: "Type your answer here",
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              errorText: errorCode == 502 ? "Email already registered" : null,
                              validator: _validators.emailValidator),
                          SizedBox(height: 15.0.spMin),
                          AppOutlinedPhoneNumberInput(
                              isRequired: true,
                              updateController: (value) => _phoneController.text = value ?? ''),
                          SizedBox(height: 15.0.spMin),
                          AppOutlinedTextFormField(
                              labelText: "Invitation message",
                              hintText: "Type your answer here",
                              controller: _messageController,
                              maxLines: 3,
                              validator: _validators.emptyValidator),
                          SizedBox(height: 15.0.spMin),
                          DeliveryOptionFormField(
                              options: _options,
                              context: context,
                              initialValue: _deliveryOptions,
                              validator: (value) {
                                if (value != null) {
                                  if (value.isEmpty) {
                                    return "Delivery option is required";
                                  }
                                }
                                return null;
                              },
                              onChange: (value) => {
                                    setState(() {
                                      _deliveryOptions = value;
                                    })
                                  }),
                          SizedBox(height: 15.0.spMin),
                          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                            TextButton(
                                child: Text("CANCEL",
                                    style: TextStyle(color: Colors.white, fontSize: 16.0.spMin)),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                            TextButton(
                                child: Text("SEND INVITE",
                                    style: TextStyle(
                                        fontSize: 16.0.spMin,
                                        color: Theme.of(context).colorScheme.secondary)),
                                onPressed: () async {
                                  // show loader dialog
                                  showLoaderDialog(context, loadingText: 'Validating details...');

                                  // validate form
                                  if (!_formKey.currentState!.validate()) {
                                    Navigator.pop(context);
                                    return;
                                  }
                                  Navigator.pop(context);

                                  // validate email
                                  showLoaderDialog(context, loadingText: 'Validating email...');
                                  var isValid = await _teamService
                                      .validateInvitedUserEmail(_emailController.text);
                                  Navigator.pop(context);

                                  if (isValid) {
                                    var _invitationData = InvitationData(
                                        id: _utils.uid(),
                                        firstName: _firstNameController.text,
                                        lastName: _lastNameController.text,
                                        email: _emailController.text,
                                        asLeader: widget.isLeader,
                                        phoneNumber: _phoneController.text,
                                        message: _messageController.text,
                                        deliveryOptions: _deliveryOptions);

                                    Navigator.pop(context, _invitationData);
                                  } else {
                                    setState(() {
                                      errorCode = 502;
                                    });
                                  }
                                })
                          ])
                        ])))));
  }
}

class DeliveryOptionFormField extends FormField<List<String>> {
  final List<Map<String, dynamic>> options;
  final Function(List<String>)? onChange;

  DeliveryOptionFormField({
    Key? key,
    required BuildContext context,
    required FormFieldValidator<List<String>> validator,
    required List<String> initialValue,
    required this.options,
    this.onChange,
  }) : super(
            key: key,
            validator: validator,
            initialValue: initialValue,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            builder: (state) {
              return InputDecorator(
                  decoration: InputDecoration(
                      labelText: "Delivery Options",
                      labelStyle: const TextStyle(fontSize: 16),
                      border: const OutlineInputBorder(),
                      errorText: state.hasError ? state.errorText : null,
                      errorStyle: const TextStyle(fontSize: 12, height: 1),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12)),
                  child: SizedBox(
                      height: 20.spMin,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: options.map((option) {
                            bool isChecked = state.value?.contains(option['value']) ?? false;
                            return Row(mainAxisSize: MainAxisSize.min, children: [
                              Checkbox(
                                  activeColor: Theme.of(context).colorScheme.secondary,
                                  value: isChecked,
                                  onChanged: (value) {
                                    if (value != null) {
                                      List<String> updatedOptions = List.from(state.value ?? []);

                                      if (value) {
                                        updatedOptions.add(option['value']);
                                      } else {
                                        updatedOptions.remove(option['value']);
                                      }

                                      state.didChange(updatedOptions);
                                      onChange?.call(updatedOptions);
                                    }
                                  }),
                              Text(option['label'], style: const TextStyle(fontSize: 16))
                            ]);
                          }).toList())));
            });
}
