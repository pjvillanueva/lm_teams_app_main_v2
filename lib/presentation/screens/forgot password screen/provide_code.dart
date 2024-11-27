import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/cubits/account_recovery_cubit.dart';
import 'package:lm_teams_app/logic/utility/enums.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

class ProvideCode extends StatelessWidget {
  const ProvideCode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProvideCodePageContent();
  }
}

class ProvideCodePageContent extends StatefulWidget {
  const ProvideCodePageContent({Key? key}) : super(key: key);

  @override
  State<ProvideCodePageContent> createState() => _VerificationPageContentState();
}

class _VerificationPageContentState extends State<ProvideCodePageContent> {
  final _formKey = GlobalKey<FormState>();
  final CustomValidators validators = CustomValidators();
  final TextEditingController textController = TextEditingController();

  final socket = WebSocketService();
  String? _errorText;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccountRecoveryCubit, AccountRecoveryState>(
        listenWhen: (previous, current) => previous.status2 != current.status2,
        listener: (context, state) {
          if (state.status2 == SubmissionStatus.submissionInProgress) {
            showLoaderDialog(context);
          } else if (state.status2 == SubmissionStatus.submissionFailed) {
            Navigator.pop(context);
            setState(() {
              _errorText = "Invalid Code";
            });
            showAppSnackbar(context, 'Invalid verification code', isError: true);
          } else if (state.status2 == SubmissionStatus.submissionSuccesful) {
            Navigator.pop(context);
            BlocProvider.of<AccountRecoveryCubit>(context).nextStep();
          }
        },
        builder: (context, state) {
          return SizedBox(
              height: 240.spMin,
              width: double.infinity,
              child: Card(
                  elevation: 5.0,
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(20.spMin, 20.spMin, 20.spMin, 10.spMin),
                      child: Column(children: [
                        Text("ENTER VERIFICATION CODE",
                            style: TextStyle(
                                fontSize: 20.spMin,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 20.spMin),
                        Form(
                            key: _formKey,
                            child: AppOutlinedTextFormField(
                                controller: textController,
                                labelText: "Verification Code",
                                hintText: "Type verification code here",
                                validator: validators.emptyValidator,
                                onChanged: (value) {
                                  setState(() {
                                    _errorText = null;
                                  });
                                },
                                errorText: _errorText)),
                        SizedBox(height: 10.spMin),
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    Theme.of(context).colorScheme.secondary)),
                            onPressed: state.status2 != SubmissionStatus.submissionInProgress
                                ? () {
                                    if (!_formKey.currentState!.validate()) return;
                                    if (!socket.isConnected) {
                                      showAppSnackbar(context, 'Unable to connect to server',
                                          isError: true);
                                      return;
                                    }
                                    BlocProvider.of<AccountRecoveryCubit>(context)
                                        .submitCode(textController.text);
                                  }
                                : null,
                            child: const Text("SUBMIT", style: TextStyle(color: Colors.white)))
                      ]))));
        });
  }
}
