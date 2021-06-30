import 'package:connectivity/connectivity.dart';

class ConnectionData {
  bool isConnected;
  ConnectivityResult connectionType;

  ConnectionData();

  static Future<ConnectionData> getConnectionData() async {
    ConnectionData data = ConnectionData();
    Connectivity c = Connectivity();
    ConnectivityResult result = await c.checkConnectivity();
    data.connectionType = result;
    if (result == ConnectivityResult.none)
      data.isConnected = false;
    else
      data.isConnected = true;
    return Future.value(data);
  }
}
