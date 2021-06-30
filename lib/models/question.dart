import 'package:flutter/foundation.dart';
import 'package:traveler/models/city.dart';

class Question {
  int questionId;
  String photoUrl;
  bool status;
  String uploader;
  City city;
  String uploaderName;

  Question({
    @required this.photoUrl,
    @required this.status,
    @required this.questionId,
    @required this.uploader,
    @required this.city,
    this.uploaderName,
  });

  Question.fromMap(Map map, {City city})
      : this(
          photoUrl: map["photoUrl"],
          uploader: map["uploader"],
          uploaderName: map["uploaderName"],
          status: map["status"] == "1" || map["status"] == "true",
          city: city,
          questionId: int.parse(map["questionId"]),
        );
}
