import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/user%20model/user_update.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/cards.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import '../../../data/models/account_member_role.dart';
import '../../../logic/cubits/users_cubit.dart';
import '../../../services/user_service.dart';
import '../../widgets/avatars.dart';
import '../../widgets/frames.dart';
import '../../widgets/snackbar.dart';

class UserAdminEditForm extends StatefulWidget {
  const UserAdminEditForm({Key? key, required this.user}) : super(key: key);

  final User user;

  @override
  State<UserAdminEditForm> createState() => _UserAdminEditFormState();
}

class _UserAdminEditFormState extends State<UserAdminEditForm> {
  final _formKey = GlobalKey<FormState>();
  final _validators = CustomValidators();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _userService = UserService();
  var accountMemberRole = AccountMemberRole.empty;

  @override
  void initState() {
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getAccountMemberRole().then((value) {
        setState(() {
          accountMemberRole = value;
        });
      });
    });
    super.initState();
  }

  Future<AccountMemberRole> _getAccountMemberRole() async {
    return await _userService.getAccountMemberRole(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    User user = widget.user;

    return AppFrame(
        title: 'Edit User',
        content: ListView(children: [
          Avatar(
              isCircle: true,
              size: Size(200.0.spMin, 200.0.spMin),
              borderWidth: 4.0.spMin,
              image: user.image,
              placeholder: Text(user.initials, style: TextStyle(fontSize: 16.0.spMin))),
          SizedBox(height: 20.0.spMin),
          Form(
              key: _formKey,
              child: GenericCard(content: [
                const SmallFormTitle(title: 'USER DETAILS'),
                AppOutlinedTextFormField(
                    labelText: "First Name",
                    hintText: "Type first name here",
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.sentences,
                    validator: _validators.emptyValidator),
                SizedBox(height: 12.0.spMin),
                AppOutlinedTextFormField(
                    controller: _lastNameController,
                    labelText: "Last Name",
                    hintText: "Type your last name here",
                    textCapitalization: TextCapitalization.sentences,
                    validator: _validators.emptyValidator),
                SizedBox(height: 12.0.spMin),
                SelectAccountRoleField(
                    labelText: 'AccountRole',
                    selectedOption: accountMemberRole.role,
                    onChanged: (value) {
                      setState(() {
                        accountMemberRole.role = value;
                      });
                    }),
                SizedBox(height: 12.0.spMin),
                FullWidthButton(
                    title: 'SAVE',
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        showLoaderDialog(context);
                        //Update user account member role in db
                        _userService.updateUserAccountRole(accountMemberRole);
                        //Update user account member role in users state
                        context.read<UsersCubit>().updateUserRole(user.id, accountMemberRole);

                        //update user details
                        var updateObject = UserUpdate(
                            id: user.id,
                            firstName: user.firstName != _firstNameController.text
                                ? _firstNameController.text
                                : null,
                            lastName: user.lastName != _lastNameController.text
                                ? _lastNameController.text
                                : null);

                        if (updateObject.hasUpdate) {
                          //Update user in db
                          var response = await _userService.updateUser(updateObject);
                          if (response != null && response.success) {
                            context.read<UsersCubit>().updateUser(updateObject);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            return;
                          } else {
                            Navigator.pop(context);
                            showAppSnackbar(context, response?.errorMessage ?? 'Error',
                                isError: true);
                            return;
                          }
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    }),
                SizedBox(height: 12.0.spMin),
                FullWidthButton(
                    title: 'CANCEL', color: Colors.grey, onPressed: () => Navigator.pop(context)),
              ]))
        ]));
  }
}
