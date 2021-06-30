import 'dart:convert';

import 'package:http/http.dart';

class DataModel {
  bool response;
  List<dynamic> data;
  bool queryIsInsert;
  int lastInsertID;

  DataModel() {
    this.response = false;
    this.data = [];
  }

  DataModel.fromResponse(Response response) {
    this.data = [];
    this.response = false;
    if (response != null) {
      if (response.statusCode == 200) {
        String realResponse = response.body;
        this.data = jsonDecode(realResponse);
        this.response = this.data.length > 0 ? true : false;
      }
    }
  }
}
