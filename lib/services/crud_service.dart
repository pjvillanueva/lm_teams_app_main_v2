import 'package:lm_teams_app/data/models/message_model.dart';
import 'package:lm_teams_app/data/models/servermessage_model.dart';
import 'package:lm_teams_app/services/web_socket_service.dart';
import '../data/models/crud model/crud_object_model.dart';

class CrudService {
  final _socket = WebSocketService();

  Future<bool> createOne({required CrudObject crudObject}) async {
    var _response = await _socket.sendAndWait(Message('CreateOne', data: crudObject));
    return _response.success;
  }

  Future<ServerMessage?> readOne({required CrudObject crudObject}) async {
    if (_socket.isConnected) {
      var response = await _socket.sendAndWait(Message('ReadOne', data: crudObject));
      response.handle(success: (data) {
        return data;
      }, error: (errorMessage) {
        print(errorMessage);
        return null;
      });
    }
    return null;
  }

  Future<bool> updateOne({
    required CrudObject crudObject,
  }) async {
    if (!_socket.isConnected) {
      return false;
    }
    var _response = await _socket.sendAndWait(Message('Write', data: crudObject));
    return _response.success;
  }

  Future<bool> deleteOne({required CrudObject crudObject}) async {
    if (!_socket.isConnected) {
      return false;
    }
    var _response = await _socket.sendAndWait(Message('DeleteOne', data: crudObject));
    return _response.success;
  }

  Future<bool> archiveOne({required CrudObject crudObject}) async {
    if (!_socket.isConnected) {
      return false;
    }
    var _response = await _socket.sendAndWait(Message('ArchiveOne', data: crudObject));
    return _response.success;
  }

  Future<ServerMessage?> readMany({required CrudObject crudObject}) async {
    if (_socket.isConnected) {
      var response = await _socket.sendAndWait(Message('ReadMany', data: crudObject));
      response.handle(success: (data) {
        return data;
      }, error: (errorMessage) {
        print(errorMessage);
        return null;
      });
    }
    return null;
  }
}
