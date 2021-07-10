import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:traveler/data/connection_data.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/data/data_model.dart';
import 'package:traveler/language/language.dart';

class DatabaseController {
  static Future<DataModel> query(String query) async {
    ConnectionData data = await ConnectionData.getConnectionData();
    if (data.isConnected) {
      http.Response response = await http.post(
        Uri.parse(Constants.apiURL),
        body: {"queryToken": query, "securityToken": Constants.securityToken},
      );
      return DataModel.fromResponse(response);
    } else {
      Fluttertoast.showToast(
        msg: Language.checkConnection,
        timeInSecForIosWeb: 2,
      );
      return DataModel();
    }
  }
}
