import 'dart:convert';
import 'package:lm_teams_app/data/models/message_model.dart';

class JsonHelpers {
  Message getServerMessage(dynamic reqResponse) {
    return _reqResponseToServerMessage(reqResponse);
  }

  T? getObject<T>(dynamic reqResponse) {
    return _decodeJson<T>(reqResponse);
  }

  bool? getBoolResult(dynamic reqResponse) {
    final _serverMessage = _reqResponseToServerMessage(reqResponse);
    return _serverMessage.error == null;
  }

  Message _reqResponseToServerMessage(dynamic reqResponse) {
    Map<String, dynamic> serverMessageMap = json.decode(reqResponse);
    return Message.fromJson(serverMessageMap);
  }

  T? _decodeJson<T>(dynamic jsonString) {
    Map<String, dynamic> decodedData = jsonDecode(jsonString);
    print('Test');
    return _fromJson<T>(decodedData);
  }

  T? _fromJson<T>(Map<String, dynamic> json) {
    // if (T == String) {
    //   return json.toString() as T;
    // } else {
    return _getFromJson<T>(json);
    // }
  }

  T? _getFromJson<T>(Map<String, dynamic> json) {
    try {
      return (json).cast<String, dynamic>() as T;
    } catch (_) {
      return null;
    }
  }
}
