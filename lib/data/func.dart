import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:styled_text/styled_text.dart';
import 'package:traveler/data/constants.dart';

class Functions {
  static Future<DateTime> getGMT({Duration subtract, Duration add}) async {
    Response response = await get(
      Uri.parse(Constants.timeUrl),
    );
    String notFormattedDate = response.body;
    DateTime time = DateFormat("d/MM/y HH:mm:ss").parse(notFormattedDate);
    if (subtract != null) time = time.subtract(subtract);
    if (add != null) time = time.add(add);

    return time;
  }

  static Future<String> getDeviceDetails() async {
    //String deviceName;
    //String deviceVersion;
    String identifier;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var build = await deviceInfoPlugin.androidInfo;
      //deviceName = build.model;
      //deviceVersion = build.version.toString();
      identifier = build.androidId; //UUID for Android
    } else if (Platform.isIOS) {
      var data = await deviceInfoPlugin.iosInfo;
      //deviceName = data.name;
      //deviceVersion = data.systemVersion;
      identifier = data.identifierForVendor; //UUID for iOS
    }
    //return [deviceName, deviceVersion, identifier];
    return identifier;
  }

  static Future<List<Widget>> getUserContract() async {
    List<Widget> list = [];
    Response response = await get(Uri.parse(Constants.userContractUrl));
    Map map = jsonDecode(utf8.decode(response.bodyBytes.toList()));
    List<String> headers = List.from(map["Başlıklar"]);
    int i = 0;
    list.add(
      Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                "v" + map["Version"],
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              child: Text(
                map["Tarih"],
                textAlign: TextAlign.end,
              ),
            )
          ],
        ),
      ),
    );
    for (String header in headers) {
      Map content = map["İçerik"];
      List<String> mainContent = List.from(content[i.toString()]);
      list.add(
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 5.0,
                  top: 15,
                ),
                child: Text(
                  header,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      for (String contentIn in mainContent) {
        list.add(
          Padding(
            padding: EdgeInsets.only(
              left: 20,
            ),
            child: StyledText(
              text: "<big>•</big> " + contentIn,
              // ignore: deprecated_member_use
              styles: {
                "big": TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )
              },
              style: TextStyle(
                color: Colors.black,
                fontSize: 12.1,
              ),
            ),
          ),
        );
      }
      i++;
    }

    return list;
  }

  static List shuffle(List items) {
    var random = new Random();
    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  static bool isValidMail(String mail){
    return EmailValidator.validate(mail);
  }

}
