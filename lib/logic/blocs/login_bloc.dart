import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:lm_teams_app/data/models/login%20models/login_data.dart';
import 'package:lm_teams_app/logic/utility/enums.dart';
import 'package:lm_teams_app/presentation/dialogs/loading_dialog.dart';
import 'package:lm_teams_app/services/auth_service.dart';

class LoginState extends Equatable {
  const LoginState(
      {this.status = SubmissionStatus.initial, this.loginAttempt = 0, this.isAllowed = true});

  final SubmissionStatus status;
  final int loginAttempt;
  final bool isAllowed;

  LoginState copyWith({SubmissionStatus? status, int? loginAttempt, bool? isAllowed}) {
    return LoginState(
        status: status ?? this.status,
        loginAttempt: loginAttempt ?? this.loginAttempt,
        isAllowed: isAllowed ?? this.isAllowed);
  }

  @override
  List<Object> get props => [
        status,
        loginAttempt,
        isAllowed,
      ];

  @override
  String toString() =>
      "LoginState: FormStatus : $status, LoginAttempt: $loginAttempt, IsAllowed: $isAllowed";
}

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginFormSubmitted extends LoginEvent {
  const LoginFormSubmitted(
      {required this.email, required this.password, required this.remember, required this.context});

  final String email;
  final String password;
  final String remember;
  final BuildContext context;
}

class LoginDisabled extends LoginEvent {
  const LoginDisabled();
}

class LoginCheck extends LoginEvent {
  const LoginCheck();
}

class LoginEnabled extends LoginEvent {
  const LoginEnabled();
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginEvent>(_onEvent);
  }

  StreamSubscription<int>? _timeLeftSubscription;
  final _authService = AuthService();

  @override
  Future<void> close() {
    _timeLeftSubscription?.cancel();
    return super.close();
  }

  Future<void> _onEvent(LoginEvent event, Emitter<LoginState> emit) async {
    if (event is LoginCheck) {
      await _mapLoginCheckToState(state, event, emit);
    } else if (event is LoginDisabled) {
      _mapLoginDisabledToState(state, emit);
    } else if (event is LoginEnabled) {
      _mapLoginEnabledToState(state, emit);
    } else if (event is LoginFormSubmitted) {
      await _mapLoginSubmittedToState(event, state, emit);
    }
  }

  Future<void> _mapLoginCheckToState(
      LoginState state, LoginEvent event, Emitter<LoginState> emit) async {
    bool hasDisableTime = await _authService.hasLoginDisabledTime();

    if (hasDisableTime) {
      emit(state.copyWith(isAllowed: false));
    } else {
      emit(state.copyWith(isAllowed: true));
    }
  }

  _mapLoginDisabledToState(LoginState state, Emitter<LoginState> emit) {
    _authService.saveLoginDisabledTime();
    emit(state.copyWith(isAllowed: false));
  }

  void _mapLoginEnabledToState(LoginState state, Emitter<LoginState> emit) {
    _authService.deleteLoginDisableTime();
    emit(state.copyWith(status: SubmissionStatus.initial, isAllowed: true, loginAttempt: 0));
  }

  Future<void> _mapLoginSubmittedToState(
      LoginFormSubmitted event, LoginState state, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: SubmissionStatus.submissionInProgress));
    showLoaderDialog(event.context, loadingText: 'Signing in...');
    try {
      final response = await _authService
          .login(LoginData(email: event.email, password: event.password, remember: event.remember));
      Navigator.pop(event.context);
      response.handle(success: (session) {
        if (session != null) {
          emit(state.copyWith(status: SubmissionStatus.submissionSuccesful, loginAttempt: 0));
        }
      }, error: (message) {
        int attempts = state.loginAttempt;
        emit(state.copyWith(status: SubmissionStatus.submissionFailed, loginAttempt: attempts + 1));
      });
    } on Exception catch (_) {
      emit(state.copyWith(status: SubmissionStatus.submissionFailed));
    }
  }
}
