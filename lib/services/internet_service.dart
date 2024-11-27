import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetService {
  static final InternetService _internetService = InternetService._internal();
  factory InternetService() {
    return _internetService;
  }
  InternetService._internal();
  final Connectivity _connectivity = Connectivity();
  bool hasInternetConnection = false;
  final StreamController<bool> _connectionChangeController =
      StreamController<bool>();

  Stream<bool> get connectionChange => _connectionChangeController.stream;

  void dispose() {
    _connectionChangeController.close();
  }

  //The test to actually see if there is a connection
  Future<bool> lookUpInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasInternetConnection = true;
      } else {
        hasInternetConnection = false;
      }
    } on SocketException catch (_) {
      hasInternetConnection = false;
    }
    return hasInternetConnection;
  }

  Future<bool> get isConnectedToInternet async {
    var result = await _connectivity.checkConnectivity();

    if (result == ConnectivityResult.none) {
      return false;
    } else if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      return await lookUpInternetConnection();
    }
    return false;
  }
}
