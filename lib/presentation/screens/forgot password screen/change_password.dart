import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/cubits/account_recovery_cubit.dart';
import 'package:lm_teams_app/logic/utility/enums.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../../dialogs/loading_dialog.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    return const ChangePasswordContent();
  }
}

class ChangePasswordContent extends StatefulWidget {
  const ChangePasswordContent({Key? key}) : super(key: key);

  @override
  State<ChangePasswordContent> createState() => _ChangePasswordContentState();
}

class _ChangePasswordContentState extends State<ChangePasswordContent> {
  final CustomValidators validators = CustomValidators();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final socket = WebSocketService();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountRecoveryCubit, AccountRecoveryState>(
        listenWhen: (previous, current) => previous.status3 != current.status3,
        listener: (context, state) {
          if (state.status3 == SubmissionStatus.submissionInProgress) {
            showLoaderDialog(context);
          } else if (state.status3 == SubmissionStatus.submissionFailed) {
            Navigator.pop(context);
            showAppSnackbar(context, 'Failed to change password', isError: true);
          } else if (state.status3 == SubmissionStatus.submissionSuccesful) {
            Navigator.pop(context);
            showAppSnackbar(context, 'Password successfully changed');
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return SizedBox(
              height: 320.spMin,
              width: double.infinity,
              child: Card(
                  elevation: 5.0,
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20.spMin, 20.spMin, 20.spMin, 10.spMin),
                      child: Column(children: [
                        Text("NEW PASSWORD",
                            style: TextStyle(
                                fontSize: 20.spMin,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 20.spMin),
                        Form(
                            key: _formKey,
                            child: Column(children: [
                              AppPasswordInput(
                                  validator: validators.passwordValidator,
                                  controller: newPasswordController,
                                  labelText: "New Password",
                                  hintText: "Type your new password here"),
                              SizedBox(height: 12.0.spMin),
                              AppPasswordInput(
                                  validator: (value) {
                                    if (value != newPasswordController.text) {
                                      return 'Password do not match';
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: confirmPasswordController,
                                  labelText: "Confirm New Password",
                                  hintText: "Confirm your new password here"),
                              SizedBox(height: 12.0.spMin),
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          Theme.of(context).colorScheme.secondary)),
                                  child:
                                      const Text("SUBMIT", style: TextStyle(color: Colors.white)),
                                  onPressed: state.status3 != SubmissionStatus.submissionInProgress
                                      ? () {
                                          if (!_formKey.currentState!.validate()) return;
                                          if (!socket.isConnected) {
                                            showAppSnackbar(context, 'Unable to connect to server',
                                                isError: true);
                                            return;
                                          }
                                          context
                                              .read<AccountRecoveryCubit>()
                                              .submitPassword(newPasswordController.text);
                                        }
                                      : null)
                            ]))
                      ]))));
        });
  }
}
