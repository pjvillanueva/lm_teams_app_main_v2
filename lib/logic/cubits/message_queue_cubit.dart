import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../data/models/message_model.dart';
import '../../services/web_socket_service.dart';

class MessageQueueState {
  const MessageQueueState({required this.messages});

  final List<Message> messages;

  Map<String, dynamic> toJson() => {'messageQueueList': messages};
  MessageQueueState.fromJson(Map<String, dynamic> json)
      : messages = List.from(json['messageQueueList']).map((e) => Message.fromJson(e)).toList();
}

class MessageQueueCubit extends HydratedCubit<MessageQueueState> {
  MessageQueueCubit() : super(const MessageQueueState(messages: [])) {
    messageQueueSubscription = WebSocketService().messageQueueStream.listen((message) {
      addMessageToQueue(message);
    });
  }

  StreamSubscription? messageQueueSubscription;
  final _socket = WebSocketService();

  addMessageToQueue(Message message) async {
    emit(MessageQueueState(messages: [...state.messages]..add(message)));
  }

  Future<bool> sendMessagesToBackend() async {
    if (state.messages.isNotEmpty && _socket.isConnected) {
      print('Sending ${state.messages.length} queued messages to backend');
      for (var message in state.messages) {
        _socket.send(message);
        removeMessageInQueue(message);
      }
    }
    return true;
  }

  removeMessageInQueue(Message message) async {
    emit(MessageQueueState(messages: [...state.messages]..remove(message)));
  }

  clearMessageQueue() {
    emit(const MessageQueueState(messages: []));
  }

  @override
  fromJson(Map<String, dynamic> json) {
    return MessageQueueState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(MessageQueueState state) {
    return state.toJson();
  }
}
