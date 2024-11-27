import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/data/models/account_member_role.dart';
import 'package:lm_teams_app/logic/blocs/account_bloc.dart';
import 'package:lm_teams_app/logic/blocs/geolocation_bloc.dart';
import 'package:lm_teams_app/logic/blocs/user_bloc.dart';
import 'package:lm_teams_app/logic/cubits/contacts_cubit.dart';
import 'package:lm_teams_app/logic/cubits/message_queue_cubit.dart';
import 'package:lm_teams_app/logic/cubits/theme_cubit.dart';
import 'package:lm_teams_app/logic/cubits/users_cubit.dart';
import 'package:lm_teams_app/services/auth_service.dart';
import '../../data/models/account.dart';
import '../../data/models/session.dart';
import '../../data/models/user model/user.dart';
import '../../services/user_service.dart';
import '../../services/web_socket_service.dart';

//states
abstract class AuthenticationState {
  const AuthenticationState();
}

class UnknownState extends AuthenticationState {}

class AuthenticatedState extends AuthenticationState {}

class UnauthenticatedState extends AuthenticationState {}

class InvitedState extends AuthenticationState {}

//events
abstract class AuthenticationEvent {
  const AuthenticationEvent();
}

class AppStarted extends AuthenticationEvent {
  AppStarted(this.context);
  final BuildContext context;
}

class LoggedIn extends AuthenticationEvent {
  LoggedIn(this.context);
  final BuildContext context;
}

class LoggedOut extends AuthenticationEvent {
  LoggedOut(this.context);
  final BuildContext context;
}

//bloc
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(UnknownState()) {
    on<AuthenticationEvent>(_onEvent);
  }

  Future<void> _onEvent(AuthenticationEvent event, Emitter<AuthenticationState> emit) async {
    if (event is AppStarted) {
      emit(await authenticateData(event.context));
    } else if (event is LoggedOut) {
      emit(await clearData(event.context));
    } else if (event is LoggedIn) {
      emit(await authenticateData(event.context));
    }
  }
}

Future<AuthenticationState> authenticateData(BuildContext context) async {
  final _authService = AuthService();
  var _session = await _authService.session;

  if (_session == null) {
    return UnauthenticatedState();
  }
  if (!await isUserValid(context)) {
    return UnauthenticatedState();
  }

  if (!await isAccountValid(context, _session)) {
    return UnauthenticatedState();
  }
  return AuthenticatedState();
}

Future<bool> isUserValid(BuildContext context) async {
  try {
    final _socketService = WebSocketService();
    final _userService = UserService();

    User _user = User.empty;

    if (_socketService.isConnected) {
      _user = await _userService.getUser();
      context.read<UserBloc>().add(UpdateUser(user: _user));
    } else {
      _user = context.read<UserBloc>().state.user;
    }
    return _user != User.empty;
  } catch (e) {
    return false;
  }
}

Future<bool> isAccountValid(BuildContext context, Session session) async {
  try {
    final _socketService = WebSocketService();
    final _userService = UserService();

    Account _account = Account.empty;

    if (_socketService.isConnected) {
      _account = await _userService.getAccount(session.accountId);
      context.read<AccountBloc>().add(SetAccount(account: _account));
      AccountMemberRole _accountRole = await _userService.getAccountMemberRole(session.userId);
      context.read<AccountBloc>().add(SetAccountRole(role: _accountRole.role));
    } else {
      _account = context.read<AccountBloc>().state.account;
    }
    return _account != Account.empty;
  } catch (e) {
    return false;
  }
}

Future<AuthenticationState> clearData(BuildContext context) async {
  final _authService = AuthService();
  final _geoBloc = context.read<GeolocationBloc>();

  //delete session
  _authService.deleteSession();
  //delete user
  context.read<UserBloc>().add(UpdateUser(user: User.empty));
  //delete account
  context.read<AccountBloc>().add(SetAccount(account: Account.empty));
  //reset theme
  context.read<ThemeCubit>().setTheme(false);
  //clear message queue
  context.read<MessageQueueCubit>().clearMessageQueue();
  //disable geolocation tracking
  if (_geoBloc.state.isEnabled) {
    _geoBloc.add(EnableGeolocation(isEnabled: false, context: context));
  }
  //clear geolocation state
  context.read<GeolocationBloc>().add(const ClearState());
  //clear users
  context.read<UsersCubit>().clearUsers();
  //clear contact cubit state
  context.read<ContactsCubit>().clearState();
  //return unauthenticated
  return UnauthenticatedState();
}
