// ignore_for_file: file_names
import 'package:lm_teams_app/services/web_socket_service.dart';

abstract class ResponseHandler<T> {
  Future<Response<T?>> run();
}
