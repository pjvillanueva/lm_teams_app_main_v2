import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/logic/blocs/account_bloc.dart';
import 'package:lm_teams_app/logic/blocs/authentication_bloc.dart';
import 'package:lm_teams_app/logic/blocs/connectivity_bloc.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/contacts_cubit.dart';
import 'package:lm_teams_app/logic/cubits/events_cubit.dart';
import 'package:lm_teams_app/logic/cubits/message_queue_cubit.dart';
import 'package:lm_teams_app/logic/cubits/teams_cubit.dart';
import 'package:lm_teams_app/logic/cubits/theme_cubit.dart';
import 'package:lm_teams_app/logic/cubits/users_cubit.dart';

class AppBlocProviders extends StatelessWidget {
  const AppBlocProviders({required this.child, Key? key}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<ConnectivityBloc>(create: (context) => ConnectivityBloc()),
      BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      BlocProvider<MessageQueueCubit>(
          create: (context) => MessageQueueCubit()..sendMessagesToBackend(), lazy: false),
      BlocProvider<UserBloc>(create: (context) => UserBloc()),
      BlocProvider<AccountBloc>(create: (context) => AccountBloc()),
      BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc()..add(AppStarted(context)), lazy: false),
      BlocProvider<GeolocationBloc>(
          create: (context) => GeolocationBloc(user: context.read<UserBloc>().state.user),
          lazy: false),
      BlocProvider<UsersCubit>(
          create: (context) =>
              UsersCubit()..getUsers(context.read<UserBloc>().state.user.accountId ?? ''),
          lazy: false),
      BlocProvider<TeamsCubit>(create: (context) => TeamsCubit()),
      BlocProvider<EventsCubit>(create: (context) => EventsCubit()),
      BlocProvider<ContactsCubit>(
          create: ((context) =>
              ContactsCubit()..initialEvent(context.read<UserBloc>().state.user.id))),
    ], child: child);
  }
}
