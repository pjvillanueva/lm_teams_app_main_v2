import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/logic/blocs/authentication_bloc.dart';
import 'package:lm_teams_app/logic/blocs/login_bloc.dart';
import 'package:lm_teams_app/logic/utility/enums.dart';
import 'package:lm_teams_app/logic/utility/form_validators.dart';
import 'package:lm_teams_app/presentation/screens/auth%20screens/signup_form.dart';
import 'package:lm_teams_app/presentation/screens/forgot%20password%20screen/account_recovery_page.dart';
import 'package:lm_teams_app/presentation/widgets/buttons.dart';
import 'package:lm_teams_app/presentation/widgets/form_fields.dart';
import 'package:lm_teams_app/presentation/widgets/form_inputs.dart';
import 'package:lm_teams_app/presentation/widgets/snackbar.dart';
import 'package:lm_teams_app/services/auth_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final validators = CustomValidators();
  final socket = WebSocketService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rememberController = TextEditingController(text: "*");

  final List<Map<String, dynamic>> _durations = [
    {'value': '10', 'label': 'for 10 minutes'},
    {'value': '60', 'label': 'for 1 hour'},
    {'value': '1440', 'label': 'for 1 day'},
    {'value': '10080', 'label': 'for 1 week'},
    {'value': '43200', 'label': 'for 1 month'},
    {'value': '*', 'label': 'Forever (until I logout)'},
  ];
  @override
  Widget build(BuildContext context) {
    var _deviceSize = MediaQuery.of(context).size;

    return BlocProvider<LoginBloc>(
        create: (context) => LoginBloc()..add(const LoginCheck()),
        child: BlocConsumer<LoginBloc, LoginState>(listener: (context, state) {
          if (state.loginAttempt == 5) {
            context.read<LoginBloc>().add(const LoginDisabled());
          } else if (state.status == SubmissionStatus.submissionFailed) {
            showAppSnackbar(context, 'Incorrect Email or Password', isError: true);
          } else if (state.status == SubmissionStatus.submissionSuccesful) {
            context.read<AuthenticationBloc>().add(LoggedIn(context));
          }
        }, builder: (context, state) {
          return Scaffold(
              backgroundColor: const Color(0xFF121212),
              body: SafeArea(
                  child: SingleChildScrollView(
                      child: Center(
                          child: Column(children: [
                Padding(
                    padding: EdgeInsets.only(
                        left: _deviceSize.height * 0.05,
                        right: _deviceSize.height * 0.05,
                        top: _deviceSize.height * 0.05),
                    child: Column(children: [
                      SizedBox(
                          height: _deviceSize.height * 0.15,
                          child: Padding(
                              padding: EdgeInsets.all(_deviceSize.height * 0.02),
                              child: Image.asset('assets/logo/logo.png'))),
                      Container(
                          color: Theme.of(context).colorScheme.surface,
                          constraints: const BoxConstraints(minWidth: 400),
                          child: Padding(
                              padding: EdgeInsets.all(_deviceSize.height * 0.02),
                              child: SizedBox(
                                  child: Form(
                                      key: _formKey,
                                      child: Column(children: [
                                        const GenericFormTitle(
                                            title: 'Welcome back!',
                                            subTitle: 'Login to your account.'),
                                        AppOutlinedTextFormField(
                                            width: 380,
                                            controller: _emailController,
                                            enable: state.isAllowed,
                                            labelText: "Email",
                                            hintText: "Type your email here",
                                            validator: validators.emptyValidator),
                                        SizedBox(height: 12.spMin),
                                        AppPasswordInput(
                                            width: 380,
                                            controller: _passwordController,
                                            enabled: state.isAllowed,
                                            validator: validators.emptyValidator,
                                            labelText: 'Password',
                                            hintText: 'Type your password here'),
                                        SizedBox(height: 12.0.spMin),
                                        AppDropdownField(
                                            width: 380,
                                            controller: _rememberController,
                                            enabled: state.isAllowed,
                                            items: _durations,
                                            labelText: 'Remember me on this device:',
                                            hintText: ""),
                                        SizedBox(height: 10.0.spMin),
                                        _DisableText(),
                                        AppFullWidthButton(
                                            width: 380.spMin,
                                            title: "LOGIN",
                                            color: Theme.of(context).colorScheme.secondary,
                                            onPressed: state.isAllowed &&
                                                    state.status !=
                                                        SubmissionStatus.submissionInProgress
                                                ? () {
                                                    FocusScope.of(context)
                                                        .requestFocus(FocusNode());
                                                    if (_formKey.currentState!.validate()) {
                                                      if (socket.isConnected) {
                                                        context.read<LoginBloc>().add(
                                                            LoginFormSubmitted(
                                                                email: _emailController.text,
                                                                password: _passwordController.text,
                                                                remember: _rememberController.text,
                                                                context: context));
                                                      } else {
                                                        showAppSnackbar(
                                                            context, 'Unable to connect to server',
                                                            isError: true);
                                                      }
                                                    }
                                                  }
                                                : null),
                                        AppTextButton(
                                            text: "Forgot Password?",
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ForgotPasswordPage()));
                                            }),
                                        const _SignupButton(),
                                      ])))))
                    ]))
              ])))));
        }));
  }
}

class _DisableText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _authService = AuthService();

    return BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
      return SizedBox(
          child: state.isAllowed
              ? null
              : StreamBuilder<int>(
                  stream: _authService.timeLeftStream,
                  initialData: 5,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var timeLeft = snapshot.data;

                      if (timeLeft! <= 0) {
                        context.read<LoginBloc>().add(const LoginEnabled());
                        return const CircularProgressIndicator();
                      } else {
                        return Text(
                            "Maximum login attempts reached. Try again after $timeLeft ${timeLeft > 1 ? "mins" : "min"}.",
                            style: TextStyle(
                                color: Colors.red, fontSize: 12.0.sp, fontWeight: FontWeight.bold));
                      }
                    } else {
                      return const Text('No data');
                    }
                  }));
    });
  }
}

class _SignupButton extends StatelessWidget {
  const _SignupButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Create new organisation.",
            style: TextStyle(fontSize: 12.0.spMin, color: Theme.of(context).colorScheme.onSurface)),
        SizedBox(
          height: 45.0.h,
          child: TextButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const SignupForm()));
              },
              child: Text(
                'CREATE',
                style: TextStyle(
                    fontSize: 14.0.spMin, color: Colors.orange[900], fontWeight: FontWeight.bold),
              )),
        )
      ],
    );
  }
}
