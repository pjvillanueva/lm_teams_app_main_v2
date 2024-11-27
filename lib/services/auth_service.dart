import 'dart:convert';
import 'package:lm_teams_app/data/models/db_operation_object.dart';
import 'package:lm_teams_app/data/models/login%20models/login_data.dart';
import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/data/models/register_model.dart';
import 'package:lm_teams_app/services/response-handlers/response-handlers.dart';
import 'package:lm_teams_app/services/preference_utils.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../data/constants/constants.dart';
import '../data/models/session.dart';

class AuthService {
  final _socket = WebSocketService();
  int defaultDisableTime = 5;
  String disabledTimeKey = "loginDisabledTime";

  static final AuthService _authSingleton = AuthService._internal();

  factory AuthService() {
    return _authSingleton;
  }

  AuthService._internal() {
    _socket.listenTo("SetSession").observable.stream.listen((message) {
      if (message.data == null || message.data == false) {
        deleteSession();
      }
    });
  }

  //Register User
  Future<Response<Session?>> register(RegisterData registerData) async {
    if (!_socket.isConnected) {
      return Response(data: null, errorMessage: 'Not connected to server');
    }

    var response = await HandleSessionData(
            await _socket.sendAndWait(Message('LeRegister', data: registerData)))
        .run();
    if (response.data != null) {
      setSession(response.data!);
    }
    return response;
  }

  //Login
  Future<Response<Session?>> login(LoginData loginData) async {
    if (!_socket.isConnected) {
      return Response(data: null, errorMessage: 'Not connected to server');
    }
    var response =
        await HandleSessionData(await _socket.sendAndWait(Message('Login', data: loginData))).run();
    if (response.data != null) {
      setSession(response.data!);
    }
    return response;
  }

  void setSession(Session session) {
    PreferenceUtils().saveData('session', jsonEncode(session));
  }

  Future<Session?> get session async {
    try {
      var _hasSession = await PreferenceUtils().containsKey('session');
      if (!_hasSession) return null;
      var session = await PreferenceUtils().getString('session');
      if (session == null) return null;
      return Session.fromJson(jsonDecode(session));
    } catch (e) {
      print('auth get session error: $e');
      return null;
    }
  }

  Future<String?> get sessionID async {
    var _session = await session;
    if (_session == null) return null;
    return _session.id;
  }

  void deleteSession() {
    PreferenceUtils().deleteData('session');
  }

  Stream<int> get timeLeftStream async* {
    var timeLeft = await minutesLeft();

    if (timeLeft != null) {
      for (var i = timeLeft; i >= 0; i--) {
        yield i;
        await Future.delayed(const Duration(seconds: 60));
      }
    }
  }

  void saveLoginDisabledTime() {
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    PreferenceUtils().saveData(disabledTimeKey, currentTime);
  }

  void deleteLoginDisableTime() {
    PreferenceUtils().deleteData(disabledTimeKey);
  }

  Future<bool> hasLoginDisabledTime() async {
    var _minutesLeft = await minutesLeft();

    if (_minutesLeft == null) {
      return false;
    } else if (_minutesLeft <= 0) {
      deleteLoginDisableTime();
      return false;
    } else {
      return true;
    }
  }

  Future<int?> minutesLeft() async {
    var disabledTime = await PreferenceUtils().getInt(disabledTimeKey);

    if (disabledTime != null) {
      var currentTime = DateTime.now().millisecondsSinceEpoch;
      final millisecondsPassed = currentTime - disabledTime;
      final minutesPassed = millisecondsPassed / 60000;

      return defaultDisableTime - minutesPassed.truncate();
    }
    return null;
  }

  void sendPasswordRecoveryOTP(String email) {
    _socket.send(Message('SendPasswordRecoveryOTP', data: {'email': email}));
  }

  Future<bool> verifyPasswordRecoveryOTP(String email, String code) async {
    if (!_socket.isConnected) return false;
    var response = await _socket
        .sendAndWait(Message('VerifyPasswordRecoveryOtp', data: {'email': email, 'code': code}));
    return response.success;
  }

  Future<bool> resetPassword(String email, String code, String password) async {
    if (!_socket.isConnected) return false;

    var response = await _socket.sendAndWait(
        Message("ChangePassword", data: {'email': email, 'code': code, 'newPassword': password}));
    return response.success;
  }

  Future<String?> validateEmail(String email) async {
    if (!_socket.isConnected) return 'Not connected to server';
    var response = await _socket.sendAndWait(Message('Read',
        data: IDBOperationObject(
            table: DBTableType.user.name,
            options: IDBReadOptions(where: {'email': email}, select: ['email'], firstOnly: true))));
    if (response.data == null) {
      return null;
    } else {
      return 'Email already in use';
    }
  }
}
