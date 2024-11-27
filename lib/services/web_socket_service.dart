import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/services/internet_service.dart';
import 'package:lm_teams_app/services/preference_utils.dart';
import '../data/constants/constants.dart';
import '../data/models/session.dart';

class WebSocketService {
  static final WebSocketService _webSocketService = WebSocketService._internal();
  factory WebSocketService() {
    return _webSocketService;
  }
  WebSocketService._internal();
  WebSocket? _socket;
  bool isConnected = false;
  Timer? timer;
  // final Duration _pongTimeout = const Duration(seconds: 10);
  final Duration _reconnectInterval = const Duration(seconds: 10);
  final endpoint = ENDPOINT;
  final Map<String, ReqObserver> _observers = {};
  final Map<String, String> _fingerPrintMap = {};
  final _internetService = InternetService();
  bool isReplied = true;

  final StreamController<bool> _socketStreamController = StreamController<bool>();
  final StreamController<Message> _messageQueueStreamController = StreamController<Message>();

  Stream<bool> get websocketStream => _socketStreamController.stream;

  Stream<Message> get messageQueueStream => _messageQueueStreamController.stream;

  Future init() async {
    connectAndListen();
  }

  Future<String?> get sessionId async {
    try {
      var hasSession = await PreferenceUtils().containsKey('session');
      if (!hasSession) return null;
      var savedSession = await PreferenceUtils().getString('session');
      if (savedSession == null) return null;
      var session = Session.fromJson(jsonDecode(savedSession));
      return session.id;
    } catch (e) {
      print('Failed getting session id: $e');
      return null;
    }
  }

// connect to server
  Future<void> connectAndListen() async {
    if (isConnected && _socket != null) {
      isConnected = false;
      _socket?.close();
    }

    var _isConnectedToInternet = await _internetService.isConnectedToInternet;
    if (_isConnectedToInternet) {
      try {
        _socket = await WebSocket.connect(endpoint)
            .timeout(const Duration(seconds: 60))
            .then((socket) async {
          var _sessionID = await sessionId;
          if (_sessionID != null && _sessionID.isNotEmpty) {
            socket.add(Message('SetSession', data: _sessionID).toString());
          }
          return socket;
        });

        // Timer(_pongTimeout, () {
        //   if (!isReplied) {
        //     print('Pong message not received within 10 seconds');
        //     closeAndReconnect();
        //   }
        // });

        _socket?.listen((event) {
          if (!isConnected) {
            isConnected = true;
            _socketStreamController.add(true);
          }
          if (event.runtimeType == String) {
            var _message = Message.fromString(event);
            handleIncoming(_message);
          } else {
            print('Unexpected event type: $event');
          }
        }, onError: (error) {
          print('WebSocket error: $error');
          closeAndReconnect();
        }, onDone: () {
          print('Websocket done');
          closeAndReconnect();
        });
      } catch (e) {
        print('Failed connecting to websocket: $e');
        isConnected = false;
        _socketStreamController.add(false);
        closeAndReconnect();
      }
    } else {
      print('reconnect - not connected to internet');
      isConnected = false;
      closeAndReconnect();
    }
  }

  closeAndReconnect() {
    _socket?.close();
    isConnected = false;
    _socketStreamController.add(false);
    reconnect();
  }

  void reconnect() {
    if (!isConnected) {
      print('reconnecting...');
      Timer(_reconnectInterval, () {
        connectAndListen();
      });
    }
  }

  void dispose() {
    _socket?.close();
    isConnected = false;
    isReplied = true;
  }

  void send<M>(Message message) {
    print('Sending message: ${message.subject}');
    if (!isConnected) {
      _messageQueueStreamController.add(message);
    } else {
      try {
        _socket?.add(message.toString());
      } catch (e) {
        _messageQueueStreamController.add(message);
      }
    }
  }

  ReqObserver<dynamic> listenTo(String fingerPrint) {
    return _getObserver<dynamic>(fingerPrint);
  }

  Future<Response> sendAndWait(Message message) async {
    final fingerPrint = _getFingerprint(message, FingerprintType.Unique);
    var completer = Completer<Response>();
    send(message);
    _fingerPrintMap[message.id] = fingerPrint;
    var observer = _getObserver<dynamic>(fingerPrint);
    observer.observable.stream.first.then((responseMessage) {
      _fingerPrintMap.remove(message.id);
      completer.complete(Response(data: responseMessage.data, errorMessage: responseMessage.error));
    });
    return completer.future;
  }

  ReqObserver<dynamic> sendAndListen(Message message, {String? customFingerPrint}) {
    final fingerPrint =
        customFingerPrint ?? _getFingerprint(message, FingerprintType.SubjectAndData);
    send(message);
    _fingerPrintMap[message.id] = fingerPrint;
    return _getObserver<dynamic>(fingerPrint);
  }

  void handleIncoming(Message<dynamic> message) {
    _handleError(message);
    var fingerPrint = _fingerPrintMap[message.id] ?? message.subject;
    var observer = _observers[fingerPrint];
    if (observer != null) {
      observer.observable._controller.add(message);
    } else {
      print('No observer for incoming request:\'' + fingerPrint + '\'');
    }
  }

  void _handleError(Message<dynamic> message) {
    if (message.error != null) {
      print("ERROR from backend server;");
      print(message.error);
    }
  }

  ReqObserver<T> _getObserver<T>(String fingerPrint) {
    if (_observers[fingerPrint] == null) {
      _observers[fingerPrint] = ReqObserver<T>(fingerPrint, MessageSubcriber());
    }
    return _observers[fingerPrint] as ReqObserver<T>;
  }

  String _getFingerprint<T>(Message message, FingerprintType fpType) {
    var output = '';
    switch (fpType) {
      case FingerprintType.Subject:
        output = message.subject;
        break;
      case FingerprintType.SubjectAndData:
        output = message.subject + json.encode(message.data);
        break;
      case FingerprintType.Unique:
        output = json.encode(message.id);
        break;
    }
    return output;
  }
}

abstract class MessageSubcriberAbstract<T> {
  Stream<Message> get stream;
  Message? lastValue;
  Message receive(Message message);
}

class MessageSubcriber<T> implements MessageSubcriberAbstract {
  final StreamController<Message<T>> _controller = StreamController<Message<T>>.broadcast();
  @override
  Stream<Message<T>> get stream => _controller.stream;

  @override
  Message<dynamic>? lastValue;

  @override
  receive(Message<dynamic> message) {
    lastValue = message as Message<T>;
    _controller.add(message);
    return message;
  }
}

class ReqObserver<T> {
  String fingerPrint;
  MessageSubcriber<T> observable;
  ReqObserver(this.fingerPrint, this.observable);
}

typedef SuccessCallback<T, R> = R Function(T data);
typedef ErrorCallback<R> = R Function(String errorMessage);

class Response<T> {
  final T? data;
  final bool isError;
  final String? errorMessage;

  bool get success => !isError;

  Response({
    required this.data,
    this.errorMessage,
  }) : isError = errorMessage != null;

  R handle<R>({
    required SuccessCallback<T, R> success,
    required ErrorCallback<R> error,
  }) {
    return errorMessage == null ? success(data!) : error(errorMessage!);
  }

  @override
  String toString() => 'Response(data: $data, isError: $isError, errorMessage: $errorMessage)';
}

enum FingerprintType { Subject, SubjectAndData, Unique }
