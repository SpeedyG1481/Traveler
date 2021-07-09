import 'package:flutter/foundation.dart';
import 'package:traveler/data/func.dart';
import 'package:traveler/models/city.dart';

class Question {
  int questionId;
  String photoUrl;
  bool status;
  String uploader;
  City city;
  String uploaderName;

  List<City> otherAnswers;

  List<City> allAnswers;

  Question({
    @required this.photoUrl,
    @required this.status,
    @required this.questionId,
    @required this.uploader,
    @required this.city,
    @required this.otherAnswers,
    this.uploaderName,
  });

  Question.fromMap(Map map, {City city, List<City> otherAnswers})
      : this(
          photoUrl: map["photoUrl"],
          uploader: map["uploader"],
          uploaderName: map["uploaderName"],
          status: map["status"] == "1" || map["status"] == "true",
          city: city,
          otherAnswers: otherAnswers,
          questionId: int.parse(map["questionId"]),
        );

  void addOtherAnswers(List<City> others) {
    allAnswers = [];
    allAnswers.addAll(others);
    allAnswers.add(city);
    allAnswers = Functions.shuffle(allAnswers);
  }
}
