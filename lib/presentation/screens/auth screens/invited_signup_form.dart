import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/user%20model/team_invitee.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/screens/auth%20screens/login_page.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/auth_service.dart';
import 'package:lm_teams_app/services/team_service.dart';
import 'package:lm_teams_app/services/utils_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../../../data/models/register_model.dart';
import '../../../data/models/team model/team_member.dart';
import '../../../logic/blocs/authentication_bloc.dart';

class InvitedSignupForm extends StatefulWidget {
  const InvitedSignupForm({
    Key? key,
    required this.invitee,
  }) : super(key: key);

  final TeamInvitee invitee;

  @override
  State<InvitedSignupForm> createState() => _InvitedSignupFormState();
}

class _InvitedSignupFormState extends State<InvitedSignupForm> {
  final _formKey = GlobalKey<FormState>();
  final validators = CustomValidators();
  final _socket = WebSocketService();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  var errorMessage = '';
  bool agreeToTerms = false;

  @override
  void initState() {
    _firstNameController.text = widget.invitee.firstName;
    _lastNameController.text = widget.invitee.lastName;
    _emailController.text = widget.invitee.email;
    _phoneController.text = widget.invitee.phoneNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _deviceSize = MediaQuery.of(context).size;
    final _utils = UtilsService();
    final _authService = AuthService();
    final _teamService = TeamService();

    return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(children: [
          Padding(
              padding: EdgeInsets.only(
                  left: _deviceSize.height * 0.05, right: _deviceSize.height * 0.05),
              child: Column(children: [
                SizedBox(
                    height: 120.0.spMin,
                    child: Center(child: Image.asset('assets/logo/logo.png', height: 80.0.spMin))),
                Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20.spMin, 20.spMin, 20.spMin, 0.0),
                        child: Form(
                            key: _formKey,
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const GenericFormTitle(
                                  title: 'Signup as member', subTitle: 'Join a team now'),
                              AppOutlinedTextFormField(
                                  controller: _firstNameController,
                                  labelText: "First Name",
                                  hintText: "Type your firstname here",
                                  validator: validators.emptyValidator),
                              SizedBox(height: 12.0.spMin),
                              AppOutlinedTextFormField(
                                  controller: _lastNameController,
                                  labelText: 'Last Name',
                                  hintText: 'Type your last name here',
                                  validator: validators.emptyValidator),
                              SizedBox(height: 12.0.spMin),
                              AppOutlinedTextFormField(
                                  controller: _emailController,
                                  labelText: 'Email',
                                  hintText: 'Type your email here',
                                  validator: validators.emptyValidator),
                              SizedBox(height: 12.spMin),
                              AppOutlinedPhoneNumberInput(
                                  initialPhoneNumber: _phoneController.text,
                                  updateController: (value) => _phoneController.text = value ?? ''),
                              SizedBox(height: 12.spMin),
                              AppPasswordInput(
                                  labelText: 'Password',
                                  hintText: 'Type your password here',
                                  validator: validators.emptyValidator,
                                  controller: _passwordController),
                              SizedBox(height: 12.spMin),
                              if (errorMessage.isNotEmpty)
                                Text(errorMessage, style: const TextStyle(color: Colors.red)),
                              TermsAndPrivacyCheckboxListTile(
                                  agreeToTerms: agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      agreeToTerms = value ?? false;
                                    });
                                  }),
                              FullWidthButton(
                                  title: 'SIGNUP',
                                  color: Theme.of(context).colorScheme.secondary,
                                  onPressed: agreeToTerms
                                      ? () async {
                                          if (_formKey.currentState!.validate()) {
                                            if (!_socket.isConnected) {
                                              showAppSnackbar(
                                                  context, 'Unable to connect to server',
                                                  isError: true);
                                              return;
                                            }
                                            showLoaderDialog(context);

                                            try {
                                              final registerData = RegisterData(
                                                  accountId: widget.invitee.accountId,
                                                  roleId: AccountRole.le.name,
                                                  firstName: _firstNameController.text,
                                                  lastName: _lastNameController.text,
                                                  email: _emailController.text,
                                                  password: _passwordController.text,
                                                  password2: _passwordController.text,
                                                  remember: '*',
                                                  mobile: _phoneController.text.isEmpty
                                                      ? null
                                                      : _phoneController.text);

                                              final response =
                                                  await _authService.register(registerData);
                                              response.handle(success: (session) {
                                                if (session != null) {
                                                  var teamMember = TeamMember(
                                                      id: _utils.uid(),
                                                      teamId: widget.invitee.teamId,
                                                      isLeader: widget.invitee.isLeader,
                                                      userId: session.userId,
                                                      inviterId: widget.invitee.inviterId);

                                                  // add teamMember to db
                                                  _teamService.addTeamMembers([teamMember]);

                                                  //delete invitation in db
                                                  _teamService.deleteInvitation(widget.invitee.id);

                                                  context
                                                      .read<AuthenticationBloc>()
                                                      .add(LoggedIn(context));
                                                }
                                              }, error: (message) {
                                                showAppSnackbar(context, message, isError: true);
                                              });
                                            } catch (e) {
                                              print(e);
                                            }
                                          }
                                        }
                                      : null),
                              SizedBox(height: 12.spMin),
                              const _LoginButton()
                            ]))))
              ]))
        ]))));
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("I already have an account.", style: TextStyle(fontSize: 12.spMin)),
      TextButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil<void>(
                context,
                MaterialPageRoute<void>(builder: (BuildContext context) => const LoginPage()),
                (Route<dynamic> route) => false);
          },
          child: Text('SIGN IN',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)))
    ]);
  }
}
