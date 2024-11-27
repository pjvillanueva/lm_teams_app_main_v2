import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';

enum ConnectivityStatus { connected, disconnected }

abstract class ConnectivityState {
  const ConnectivityState();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ConnectivityState && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

class ConnectedState extends ConnectivityState {}

class DisconnectedState extends ConnectivityState {}

abstract class ConnectivityEvent {
  const ConnectivityEvent();
}

class ConnectivityStatusChange extends ConnectivityEvent {
  ConnectivityStatusChange({required this.connectivityStatus});

  final ConnectivityStatus connectivityStatus;
}

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  StreamSubscription? socketSubscription;

  ConnectivityBloc() : super(DisconnectedState()) {
    on<ConnectivityEvent>(_onEvent);

    socketSubscription = WebSocketService().websocketStream.listen((status) {
      add(ConnectivityStatusChange(
          connectivityStatus:
              status ? ConnectivityStatus.connected : ConnectivityStatus.disconnected));
    });
  }

  @override
  Future<void> close() {
    socketSubscription?.cancel();
    WebSocketService().dispose();
    return super.close();
  }

  Future<void> _onEvent(ConnectivityEvent event, Emitter<ConnectivityState> emit) async {
    if (event is ConnectivityStatusChange) {
      switch (event.connectivityStatus) {
        case ConnectivityStatus.connected:
          emit(ConnectedState());
          break;
        case ConnectivityStatus.disconnected:
          emit(DisconnectedState());
          break;
      }
    }
  }
}
