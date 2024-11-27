import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/models/user%20model/user_update.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/image_options.dialog.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/cards.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/frames.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/uploader_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class UserEditForm extends StatefulWidget {
  const UserEditForm({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State<UserEditForm> createState() => _UserEditFormState();
}

class _UserEditFormState extends State<UserEditForm> {
  File? imageFile;
  int errorCode = 0;
  bool editPassword = false;
  final _formKey = GlobalKey<FormState>();
  final _socket = WebSocketService();
  final _utils = UtilsService();
  final _uploaderService = UploaderService();
  final _userService = UserService();
  final _authService = AuthService();
  String? _errorMessage;
  final _validators = CustomValidators();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _phoneNumberController.text = widget.user.mobile ?? "";
    _emailController.text = widget.user.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = context.read<UserBloc>().state.user;
    var owner = currentUser.id == widget.user.id;

    Future<bool> _validateEmail() async {
      var _errorMessage = await _authService.validateEmail(_emailController.text);
      if (_errorMessage != null) {
        setState(() {
          _errorMessage = _errorMessage;
        });
        return false;
      }
      return true;
    }

    return AppFrame(
        title: owner ? "Edit Profile" : "Edit User",
        content: ListView(children: [
          GenericCard(content: [
            SmallFormTitle(title: owner ? 'PROFILE PICTURE' : "USER PICTURE"),
            Avatar(
                isCircle: true,
                imageFile: imageFile,
                image: widget.user.image,
                borderWidth: 4.0.spMin,
                placeholder: Text(widget.user.initials, style: TextStyle(fontSize: 30.0.spMin)),
                size: Size(200.0.spMin, 200.spMin),
                onTapButton: () async {
                  File? _imageFile = imageFile ??
                      (widget.user.image != null
                          ? await _utils.urlToFile(widget.user.image!.url)
                          : null);
                  File? newFile = await showImageOptionsDialog(context, imageFile: _imageFile);
                  if (newFile != null) {
                    setState(() {
                      imageFile = newFile;
                    });
                  }
                })
          ]),
          SizedBox(height: 14.0.spMin),
          Form(
              key: _formKey,
              child: GenericCard(content: [
                SmallFormTitle(title: owner ? 'PROFILE DETAILS' : 'USER DETAILS'),
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
                AppOutlinedPhoneNumberInput(
                    initialPhoneNumber: _phoneNumberController.text,
                    updateController: (value) => _phoneNumberController.text = value ?? ''),
                SizedBox(height: 12.0.spMin),
                AppOutlinedTextFormField(
                    controller: _emailController,
                    labelText: "Email",
                    hintText: "Type your email here",
                    validator: _validators.emailValidator,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _errorMessage),
                SizedBox(height: 12.0.spMin),
                Visibility(
                    visible: owner,
                    child: Visibility(
                        visible: !editPassword,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              editPassword = true;
                            });
                          },
                          child: Text("Change password",
                              style: TextStyle(
                                  fontSize: 16.0.spMin,
                                  color: Theme.of(context).colorScheme.secondary)),
                        ))),
                Visibility(
                    visible: editPassword,
                    child: Column(children: [
                      AppPasswordInput(
                          controller: _passwordController,
                          labelText: "Current Password",
                          hintText: "Type your current password here",
                          errorText: errorCode == 504 ? "Incorrect password" : null),
                      SizedBox(height: 12.0.spMin),
                      AppPasswordInput(
                          controller: _newPasswordController,
                          labelText: "New Password",
                          hintText: "Type your new password here",
                          validator: (value) {
                            return _validators.validateNewPassword(value, _passwordController.text);
                          }),
                      SizedBox(height: 12.0.spMin),
                      AppPasswordInput(
                          controller: _confirmPasswordController,
                          labelText: "Confirm Password",
                          hintText: "Confirm new password",
                          validator: (value) {
                            return _validators.validateConfirmPassword(
                                value, _newPasswordController.text);
                          }),
                      SizedBox(height: 12.0.spMin)
                    ])),
                SizedBox(height: 12.0.spMin),
                FullWidthButton(
                    title: "SUBMIT",
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () async {
                      //check if connected, if not do not continue
                      if (!_socket.isConnected) {
                        showAppSnackbar(context, "Not connected to server", isError: true);
                        return;
                      }
                      //validate form
                      if (_formKey.currentState!.validate()) {
                        //validate if new email
                        if (widget.user.email != _emailController.text) {
                          if (!await _validateEmail()) return;
                        }
                        showLoaderDialog(context);
                        var imageObj = await _uploaderService.uploadAndGetImageObj(imageFile);

                        var updates = UserUpdate(
                            id: widget.user.id,
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            email: _emailController.text,
                            mobile: _phoneNumberController.text,
                            image: imageObj ?? widget.user.image);

                        var response = await _userService.updateUser(updates);

                        if (response != null && response.success) {
                          context
                              .read<UserBloc>()
                              .add(UpdateUser(user: widget.user.updatedUser(updates)));
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                          showAppSnackbar(context, response?.errorMessage ?? 'Error',
                              isError: true);
                        }
                      }
                    }),
                const SizedBox(height: 12.0),
                FullWidthButton(
                    title: "CANCEL",
                    color: Colors.grey,
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ]))
        ]));
  }
}
