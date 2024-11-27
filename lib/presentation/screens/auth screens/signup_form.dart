import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/data/constants/constants.dart';
import 'package:lm_teams_app/data/models/register_model.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/presentation/screens/home%20screen/home_screen.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/list_tiles.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../../../logic/blocs/authentication_bloc.dart';
import '../../../services/auth_service.dart';
import '../../widgets/form_fields.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({Key? key}) : super(key: key);

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final validators = CustomValidators();
  final _accountNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final socket = WebSocketService();
  final _authService = AuthService();
  String? errorMessage;
  bool agreeToTerms = false;

  Future<bool> _validateEmail() async {
    var _errorMessage = await _authService.validateEmail(_emailController.text);
    if (_errorMessage != null) {
      setState(() {
        errorMessage = _errorMessage;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var _deviceSize = MediaQuery.of(context).size;

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        }
      },
      child: Scaffold(
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
                      child:
                          Center(child: Image.asset('assets/logo/logo.png', height: 80.0.spMin))),
                  Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(20.spMin, 20.0.spMin, 20.0.spMin, 0.0),
                          child: Form(
                              key: _formKey,
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const GenericFormTitle(
                                    title: 'Account Creation', subTitle: 'Create new account'),
                                AppOutlinedTextFormField(
                                    controller: _accountNameController,
                                    labelText: "Account Name",
                                    hintText: "Type account name here"),
                                SizedBox(height: 5.0.spMin),
                                const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [Text(" Owner Information:")]),
                                SizedBox(height: 5.0.spMin),
                                Row(children: [
                                  Expanded(
                                      flex: 2,
                                      child: AppOutlinedTextFormField(
                                          controller: _firstNameController,
                                          labelText: "First Name",
                                          hintText: "Type your firstname here",
                                          validator: validators.emptyValidator)),
                                  SizedBox(width: 10.0.spMin),
                                  Expanded(
                                      flex: 2,
                                      child: AppOutlinedTextFormField(
                                          controller: _lastNameController,
                                          labelText: "Last Name",
                                          hintText: "Type your last name here",
                                          validator: validators.emptyValidator))
                                ]),
                                SizedBox(height: 12.0.spMin),
                                AppOutlinedTextFormField(
                                    controller: _emailController,
                                    labelText: "Email",
                                    hintText: "Type your email here",
                                    validator: validators.emailValidator,
                                    errorText: errorMessage),
                                SizedBox(height: 12.0.spMin),
                                AppOutlinedPhoneNumberInput(
                                    updateController: (value) =>
                                        _mobileController.text = value ?? ''),
                                SizedBox(height: 12.0.spMin),
                                AppPasswordInput(
                                    controller: _passwordController,
                                    labelText: "Password",
                                    hintText: "Type your password here",
                                    validator: validators.passwordValidator),
                                SizedBox(height: 12.0.spMin),
                                AppPasswordInput(
                                    controller: _passwordConfirmController,
                                    labelText: "Confirm Password",
                                    hintText: "Type your password here",
                                    validator: (value) {
                                      if (value != _passwordController.text) {
                                        return 'Passwords do not match';
                                      } else {
                                        return null;
                                      }
                                    }),
                                SizedBox(height: 12.0.spMin),
                                TermsAndPrivacyCheckboxListTile(
                                    agreeToTerms: agreeToTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        agreeToTerms = value ?? false;
                                      });
                                    }),
                                AppFullWidthButton(
                                    width: 380.spMin,
                                    title: 'SIGN UP',
                                    color: Theme.of(context).colorScheme.secondary,
                                    onPressed: agreeToTerms
                                        ? () async {
                                            FocusScope.of(context).requestFocus(FocusNode());
                                            if (_formKey.currentState!.validate()) {
                                              if (socket.isConnected) {
                                                if (!await _validateEmail()) return;
                                                showLoaderDialog(context);
                                                try {
                                                  //create register data
                                                  final registerData = RegisterData(
                                                      firstName: _firstNameController.text,
                                                      lastName: _lastNameController.text,
                                                      accountName: _accountNameController.text,
                                                      roleId: AccountRole.owner.name,
                                                      email: _emailController.text,
                                                      password: _passwordController.text,
                                                      password2: _passwordConfirmController.text,
                                                      remember: '*',
                                                      mobile: _mobileController.text.isEmpty
                                                          ? null
                                                          : _mobileController.text);

                                                  final response =
                                                      await _authService.register(registerData);

                                                  //close loader dialog
                                                  Navigator.pop(context);

                                                  response.handle(success: (session) {
                                                    if (session != null) {
                                                      context
                                                          .read<AuthenticationBloc>()
                                                          .add(LoggedIn(context));
                                                    }
                                                  }, error: (message) {
                                                    showAppSnackbar(context, message,
                                                        isError: true);
                                                  });
                                                } catch (e) {
                                                  print(e);
                                                }
                                              } else {
                                                showAppSnackbar(
                                                    context, 'Unable to connect to server',
                                                    isError: true);
                                              }
                                            }
                                          }
                                        : null),
                                SizedBox(height: 12.0.spMin),
                                const _LoginButton()
                              ]))))
                ]))
          ])))),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("I already have an account.", style: TextStyle(fontSize: 12.0.spMin)),
      TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('SIGN IN',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)))
    ]);
  }
}
