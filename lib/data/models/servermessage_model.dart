class ServerMessage<T> {
  bool success;
  String? message;
  T? data;
  int? errorCode;
  bool? hasInternetConnection;

  ServerMessage(
      {required this.success, this.message, this.data, this.errorCode});

  ServerMessage.fromJson(Map<String, dynamic> json)
      : success = json['success'],
        message = json['message'],
        data = json['data'],
        errorCode = json['errorCode'];

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data,
        'errorCode': errorCode
      };

  @override
  String toString() {
    return 'ServerMessage: {success: $success, message: $message, data: $data, errorCode: $errorCode}';
  }
}
