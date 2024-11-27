import 'dart:convert';
import 'package:lm_teams_app/services/utils_service.dart';

class Message<T> {
  String subject;
  T? data;
  String id = UtilsService().uid();
  String? error;

  Message(this.subject, {this.data, this.error, String? idOverride}) {
    if (idOverride != null) {
      id = idOverride;
    }
  }

  @override
  String toString() {
    return json
        .encode({"subject": subject, "data": data, "id": id, "error": error});
  }

  static Message fromString(String str) {
    return Message.fromJson(json.decode(str));
  }

  Message.fromJson(Map<String, dynamic> json)
      : subject = json['subject'],
        data = json['data'],
        id = json['id'],
        error = json['error'];

  Map<String, dynamic> toJson() =>
      {'subject': subject, 'data': data, 'id': id, 'error': error};
}
