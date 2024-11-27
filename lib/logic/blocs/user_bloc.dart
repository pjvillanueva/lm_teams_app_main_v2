import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:lm_teams_app/data/models/user%20model/user.dart';
import 'package:lm_teams_app/services/user_service.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

//state
class UserState extends Equatable {
  const UserState({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
}

//events
abstract class UserEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UpdateUser extends UserEvent {
  UpdateUser({required this.user});
  final User? user;
}

//bloc
class UserBloc extends HydratedBloc<UserEvent, UserState> {
  UserBloc() : super(UserState(user: User.empty)) {
    on<UserEvent>(_onEvent);
  }

  final userService = UserService();
  final socketService = WebSocketService();

  Future<void> _onEvent(UserEvent event, Emitter<UserState> emit) async {
    if (event is UpdateUser) {
      emit(UserState(user: event.user ?? User.empty));
    }
  }

  @override
  UserState fromJson(Map<String, dynamic> json) {
    return UserState(user: User.fromJson(json));
  }

  @override
  Map<String, dynamic>? toJson(UserState state) {
    return state.user.toJson();
  }
}
