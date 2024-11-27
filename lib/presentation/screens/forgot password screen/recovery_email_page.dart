import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/cubits/account_recovery_cubit.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../../widgets/form_fields.dart';

class RecoveryEmailPage extends StatefulWidget {
  const RecoveryEmailPage({Key? key}) : super(key: key);

  @override
  State<RecoveryEmailPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<RecoveryEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final CustomValidators validators = CustomValidators();
  final emailController = TextEditingController(text: "");
  final socket = WebSocketService();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Card(
            elevation: 5.0.spMin,
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
                padding: EdgeInsets.fromLTRB(20.spMin, 20.spMin, 20.spMin, 10.spMin),
                child: Column(children: [
                  Text("EMAIL VERIFICATION",
                      style: TextStyle(
                          fontSize: 20.spMin, fontFamily: "Roboto", fontWeight: FontWeight.bold)),
                  Text('Enter your registered email below to recover your account',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 12.0.spMin)),
                  SizedBox(height: 20.spMin),
                  Form(
                      key: _formKey,
                      child: AppOutlinedTextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          labelText: "Email",
                          hintText: "Type your registered email here",
                          validator: validators.emptyValidator)),
                  SizedBox(height: 10.spMin),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Theme.of(context).colorScheme.secondary)),
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;

                        if (!socket.isConnected) {
                          showAppSnackbar(context, 'Unable to connect to server', isError: true);
                          return;
                        }
                        BlocProvider.of<AccountRecoveryCubit>(context)
                            .submitRecoveryEmail(emailController.text);
                        BlocProvider.of<AccountRecoveryCubit>(context).nextStep();
                      },
                      child: const Text("SEND OTP", style: TextStyle(color: Colors.white)))
                ]))));
  }
}
