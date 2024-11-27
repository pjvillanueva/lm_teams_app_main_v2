import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/logic/blocs/authentication_bloc.dart';
import 'package:lm_teams_app/presentation/screens/home%20screen/home_screen.dart';
import 'package:lm_teams_app/presentation/screens/loading_screen.dart';
import 'package:lm_teams_app/presentation/screens/auth%20screens/login_page.dart';
import 'package:lm_teams_app/services/deep_link_service.dart';

// ignore: must_be_immutable
class AuthNavigator extends StatelessWidget {
  AuthNavigator({Key? key, required this.authBloc}) : super(key: key);
  AuthenticationBloc authBloc = AuthenticationBloc();

  @override
  Widget build(BuildContext context) {
    DeepLinkService().init(context);

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(builder: (context, state) {
      if (state is UnknownState) {
        return const LoadingScreen();
      } else if (state is AuthenticatedState) {
        return const HomeScreen();
      } else {
        return const LoginPage();
      }
    });
  }
}
