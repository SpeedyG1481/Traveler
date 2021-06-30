import 'dart:async';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:traveler/audio/audio_controller.dart';
import 'package:traveler/components/save_score_text_field.dart';
import 'package:traveler/data/audio_files.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/data/data_model.dart';
import 'package:traveler/data/database_controller.dart';
import 'package:traveler/data/func.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/models/city.dart';
import 'package:traveler/models/country.dart';
import 'package:traveler/models/meter_types.dart';
import 'package:traveler/models/question.dart';
import 'package:traveler/models/state.dart';
import 'package:traveler/pages/main_page.dart';

class SinglePlayerBuildPrediction extends StatefulWidget {
  @override
  _SinglePlayerBuildPredictionState createState() =>
      _SinglePlayerBuildPredictionState();
}

class _SinglePlayerBuildPredictionState
    extends State<SinglePlayerBuildPrediction> {
  TextEditingController controller = TextEditingController();

  DateTime currentBackPressTime;

  Completer<GoogleMapController> _controller = Completer();
  static Marker selectMarker = Marker(markerId: MarkerId("marker"));

  List<Question> questions;
  bool isLoading = false;
  Timer timer;

  int round = 0;
  int point = 0;

  int time = 0;
  int roundTimer = 0;

  bool saving = false;
  bool canSave = true;

  @override
  void dispose() {
    if (timer != null) timer.cancel();
    timer = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadQuestions();
    AudioController.stopBackgroundMusic();
  }

  var _markers = Set<Marker>.of([selectMarker]);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              getBody(),
              Positioned(
                top: 0,
                right: width / 4,
                child: Container(
                  width: width / 2,
                  height: height / 10,
                  decoration: BoxDecoration(
                    color: Color(0xffD0F3F7),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(
                        20,
                      ),
                      bottomRight: Radius.circular(
                        20,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (round <
                          Constants.BuildPredictionSinglePlayerRoundCount)
                        Expanded(
                          flex: 2,
                          child: Text(
                            (round + 1).toString() +
                                "/" +
                                Constants.BuildPredictionSinglePlayerRoundCount
                                    .toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xff1683DB),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (round <
                          Constants.BuildPredictionSinglePlayerRoundCount)
                        Expanded(
                          child: Text(
                            (roundTimer - time).toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xff1683DB),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          point.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xff1683DB),
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (round >= Constants.BuildPredictionSinglePlayerRoundCount) {
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(
                  builder: (context) => ParentMainPage(),
                ),
                (Route<dynamic> route) => false,
              );
              return;
            }
            selectDialog(width, height);
          },
          backgroundColor: Color(0xffD0F3F7),
          child: Icon(
            round >= Constants.BuildPredictionSinglePlayerRoundCount
                ? MdiIcons.arrowLeft
                : MdiIcons.mapMarker,
            color: Color(0xff1683DB),
          ),
        ),
      ),
    );
  }

  getBody() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    if (isLoading || !(this.questions != null))
      return Center(child: CircularProgressIndicator());

    if (this.questions.length == 0) {
      return Center(
        child: Text(
          Language.noDataFound,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (round < Constants.BuildPredictionSinglePlayerRoundCount &&
        round < this.questions.length)
      return Container(
        height: height,
        width: width,
        child: Image(
          fit: BoxFit.fill,
          image: NetworkImage(
            this.questions[round].photoUrl,
          ),
        ),
      );

    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Color(0xff000000),
          ),
          child: Image(
            fit: BoxFit.fill,
            image: NetworkImage(
              this.questions[min(round, this.questions.length - 1)].photoUrl,
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7.5,
            ),
            decoration: BoxDecoration(
              color: Color(0xffD0F3F7).withOpacity(
                .85,
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(
                  10,
                ),
              ),
            ),
            child: Text(
              "© " +
                  this
                      .questions[min(round, this.questions.length - 1)]
                      .uploaderName,
              style: TextStyle(
                color: Color(
                  0xff00276B,
                ),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        Center(
          child: !canSave
              ? Container()
              : Container(
                  decoration: BoxDecoration(
                    color: Color(0xffD0F3F7),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  width: width / 1.35,
                  height: height / 3,
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Language.doYouWantToSaveScore,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(
                            0xff00276B,
                          ),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SaveScoreTextField(
                        editingController: controller,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(
                            () {
                              saving = true;
                            },
                          );
                          await saveScore();
                          setState(
                            () {
                              saving = false;
                            },
                          );
                        },
                        child: !saving
                            ? CircleAvatar(
                                backgroundColor: Color(
                                  0xff00276B,
                                ),
                                child: Icon(
                                  MdiIcons.checkBold,
                                  size: 30,
                                  color: Color(0xffD0F3F7),
                                ),
                              )
                            : SpinKitWave(
                                size: 30,
                                color: Color(0xffD0F3F7),
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  void selectDialog(double width, double height) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
              builder: (context, innerSetState) {
                return Container(
                  width: width * .9,
                  height: height * .9,
                  child: GoogleMap(
                    mapType: MapType.terrain,
                    markers: _markers,
                    onTap: (LatLng lng) {
                      innerSetState(() {
                        selectMarker =
                            selectMarker.copyWith(positionParam: lng);
                        _markers.clear();
                        _markers.add(selectMarker);
                      });
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(0, 0),
                      zoom: 0,
                    ),
                    mapToolbarEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                );
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  check(context);
                },
                child: Text(
                  Language.checkDistance,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  Language.cancel,
                ),
              ),
            ],
          );
        });
  }

  void check(BuildContext context) {
    Navigator.pop(context);
    if (selectMarker != null && this.questions.length > 0) {
      City questionState = questions[round].city;
      MeterTypes meterTypes = Functions.distanceBetween(
          selectMarker.position.latitude,
          selectMarker.position.longitude,
          questionState.latitude,
          questionState.longitude);
      if (round <
          min(Constants.BuildPredictionSinglePlayerRoundCount,
              this.questions.length)) {
        nextRound(meterTypes: meterTypes);
      }
    }
  }

  Future loadQuestions() async {
    DataModel dataModel = await DatabaseController.query(
        "SELECT questions.*, cities.*, states.name as stateName, countries.name as countryName FROM "
                "questions, cities, states, countries WHERE cities.state_id = states.id AND countries.id = cities.country_id AND "
                "cities.id = questions.cityId AND status = true ORDER BY RAND() LIMIT " +
            Constants.BuildPredictionSinglePlayerRoundCount.toString());
    this.questions = [];
    for (Map m in dataModel.data) {
      this.questions.add(
            Question.fromMap(
              m,
              city: City.fromMap(
                m,
                state: Province(
                  name: m["stateName"],
                ),
                country: Country(
                  name: m["countryName"],
                ),
              ),
            ),
          );
    }

    loadTimer();
    setState(() {
      this.isLoading = false;
    });
  }

  void nextRound({MeterTypes meterTypes}) {
    if (meterTypes != null) {
      Question question = this.questions[min(round, this.questions.length - 1)];
      AwesomeDialog(
        context: context,
        dialogType: DialogType.INFO_REVERSED,
        animType: AnimType.SCALE,
        title: Language.accuary,
        body: Column(
          children: [
            Text(
              Language.tourInfo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              Language.cityName + ": " + question.city.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              Language.stateName + ": " + question.city.state.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              Language.countryName + ": " + question.city.country.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              Language.mistakeCount +
                  ": " +
                  meterTypes.externalKm.toString() +
                  " km " +
                  meterTypes.externalMt.toString() +
                  " mt ",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              Language.wonPoint + ": " + meterTypes.point.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        btnOkOnPress: () {},
      )..show();

      if (meterTypes.externalKm < Constants.BuildPredictionSuccessLevels[0]) {
        AudioController.playSoundEffect(AudioFiles.SuccessHighSound);
      } else if (meterTypes.externalKm <
          Constants.BuildPredictionSuccessLevels[1]) {
        AudioController.playSoundEffect(AudioFiles.SuccessMediumSound);
      } else if (meterTypes.externalKm <
          Constants.BuildPredictionSuccessLevels[2]) {
        AudioController.playSoundEffect(AudioFiles.SuccessLowSound);
      } else {
        AudioController.playSoundEffect(AudioFiles.SuccessVeryLowSound);
      }
      point += meterTypes.point;
    } else {
      Fluttertoast.showToast(
        msg: Language.noMoreTimes,
      );
      AudioController.playSoundEffect(AudioFiles.WrongSound);
    }

    roundTimer = time + Constants.BuildPredictionSinglePlayerQuestionTimer;
    setState(() {
      round++;
    });
    if (round == Constants.BuildPredictionSinglePlayerRoundCount) {
      AudioController.playSoundEffect(AudioFiles.LevelEnd);
    }
  }

  saveScore() async {
    String text = controller.text;

    if (text.length < 3) {
      Fluttertoast.showToast(msg: Language.minimumThreeCharacterForSaveToTable);
      return;
    }

    Response response = await post(
      Uri.parse(Constants.newScoreUrl),
      body: {
        "name": text,
        "score": point.toString(),
        "securityToken": Constants.securityToken
      },
    );
    if (response.body == "true" || response.body == "1") {
      AwesomeDialog(
        btnOkText: Language.okey,
        context: context,
        dialogType: DialogType.SUCCES,
        animType: AnimType.BOTTOMSLIDE,
        title: Language.success,
        desc: Language.saveSuccessToTable,
        btnOkOnPress: () {},
      )..show();
    } else {
      AwesomeDialog(
        btnOkText: Language.okey,
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.BOTTOMSLIDE,
        title: Language.error,
        desc: Language.saveErrorToTable,
        btnOkOnPress: () {},
      )..show();
    }

    setState(() {
      canSave = false;
    });
  }

  void loadTimer() {
    if (timer == null)
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (round < Constants.BuildPredictionSinglePlayerRoundCount) {
          setState(() {
            time++;
          });

          if (roundTimer - time <= 0) {
            nextRound();
          }
        }
      });

    roundTimer = time + Constants.BuildPredictionSinglePlayerQuestionTimer;
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: Language.exitTwoTap);
      return Future.value(false);
    }
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(
        builder: (context) => ParentMainPage(),
      ),
      (Route<dynamic> route) => false,
    );
    return Future.value(false);
  }
}
