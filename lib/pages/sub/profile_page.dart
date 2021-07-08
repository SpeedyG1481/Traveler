import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:traveler/components/standart_text_field.dart';
import 'package:traveler/data/ads.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/data/func.dart';
import 'package:traveler/data/iap.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/models/other/progress_dialog.dart';
import 'package:traveler/pages/main_page.dart';

class ProfilePage extends StatefulWidget {
  final ParentMainPageState mainPage;

  ProfilePage(this.mainPage);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  InterstitialAd profileInterstitial;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  Future loadAd() async {
    if (Constants.canRemoveAds) {
      return;
    }

    InterstitialAd.load(
      adUnitId: Ads.getProfileInterstitialId(),
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          this.profileInterstitial = ad;
          showAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("AD Error: " + error.message);
        },
      ),
    );
  }

  Future showAd() async {
    if (this.profileInterstitial != null) {
      await this.profileInterstitial.show();
    }
  }

  @override
  void dispose() {
    if (profileInterstitial != null) profileInterstitial.dispose();
    super.dispose();
  }

  @override
  void initState() {
    this.loadAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: getBody(),
    );
  }

  getBody() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          height: height,
          width: width,
          child: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, user) {
              if (user == null || !user.hasData) {
                return loginBody();
              }
              return getProfileBody(user.data);
            },
          ),
        ),
        Positioned(
          left: 10,
          top: 10,
          child: GestureDetector(
            onTap: () {
              this.widget.mainPage.changeBody(null);
            },
            child: CircleAvatar(
              radius: 22,
              child: Icon(
                MdiIcons.arrowLeftBold,
                color: Color(0xff1C88FF),
                size: 30,
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  loginBody() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Traveler",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 35,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          StandartTextField(
            color: Colors.white,
            hintText: Language.mail,
            editingController: email,
          ),
          SizedBox(
            height: 15,
          ),
          StandartTextField(
            color: Colors.white,
            hintText: Language.password,
            editingController: password,
            passwordText: true,
          ),
          SizedBox(
            height: 35,
          ),
          ArgonButton(
            onTap: (start, stop, state) async {
              if (state == ButtonState.Busy) {
                return;
              }
              start();
              await loginOrRegisterUser();
              stop();
            },
            borderRadius: 10,
            color: Color(0xff1C88FF),
            loader: SpinKitFadingFour(
              color: Colors.white,
              size: 30,
            ),
            height: 50,
            width: 200,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.key,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Text(
                      Language.login,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loginOrRegisterUser() async {
    String mailText = email.text;
    String passwordText = password.text;

    bool isValidMail = Functions.isValidMail(mailText);
    bool isValidPassword = passwordText.length > 3;
    if (!isValidMail || !isValidPassword) {
      AwesomeDialog(
        btnOkText: Language.okey,
        context: context,
        dialogType: DialogType.WARNING,
        btnOkColor: Colors.orange,
        animType: AnimType.BOTTOMSLIDE,
        title: Language.warning,
        desc: Language.emailOrPasswordSyntaxError,
        btnOkOnPress: () {},
      )..show();
      return;
    }

    final list =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(mailText);
    if (list.isEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: mailText, password: passwordText);
        final CollectionReference postsRef =
            FirebaseFirestore.instance.collection('userdata');

        var postID = userCredential.user.uid;
        await postsRef.doc(postID).set(
          {
            "play_count": 0,
            "total_point": 0,
            "maximum_point": 0,
            "true_answers": 0,
            "false_answers": 0,
          },
        );
      } catch (e) {
        AwesomeDialog(
          btnOkText: Language.okey,
          context: context,
          btnOkColor: Colors.red,
          dialogType: DialogType.ERROR,
          animType: AnimType.BOTTOMSLIDE,
          title: Language.error,
          desc: Language.registerError,
          btnOkOnPress: () {},
        )..show();
      }
    } else {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: mailText, password: passwordText);
        setState(() {
          email.clear();
          password.clear();
        });
      } catch (e) {
        AwesomeDialog(
          btnOkText: Language.okey,
          btnOkColor: Colors.red,
          context: context,
          dialogType: DialogType.ERROR,
          animType: AnimType.BOTTOMSLIDE,
          title: Language.error,
          desc: Language.loginError,
          btnOkOnPress: () {},
        )..show();
      }
    }
  }

  getProfileBody(User user) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Column(
          children: [
            AvatarGlow(
              glowColor: Colors.white,
              endRadius: 70.0,
              animate: true,
              curve: Curves.bounceOut,
              duration: Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              child: Material(
                // Replace this child with your own
                elevation: 5.0,
                shape: CircleBorder(),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoURL == null
                      ? Images.profileAvatarBackground
                      : NetworkImage(
                          user.photoURL,
                        ),
                  child: user.photoURL == null
                      ? Icon(
                          MdiIcons.closeThick,
                          size: 30,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    uploadAnProfileImage(user);
                  },
                  child: CircleAvatar(
                    radius: 17.5,
                    child: Icon(
                      MdiIcons.upload,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    setState(() {});
                  },
                  child: CircleAvatar(
                    radius: 17.5,
                    child: Icon(
                      MdiIcons.logout,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 60,
              width: width / 1.1,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: Images.profileNameBackground, fit: BoxFit.fill),
              ),
              child: Center(
                child: StandartTextField(
                  border: false,
                  editingController: usernameController,
                  color: Colors.white,
                  hintText: user.displayName != null
                      ? user.displayName
                      : Language.typeUsername,
                  passwordText: false,
                  suffix: IconButton(
                    onPressed: () async {
                      String text = usernameController.text;
                      if (text.length <= 3) {
                        AwesomeDialog(
                          btnOkText: Language.okey,
                          btnOkColor: Colors.orange,
                          context: context,
                          dialogType: DialogType.WARNING,
                          animType: AnimType.BOTTOMSLIDE,
                          title: Language.warning,
                          desc: Language.usernameMinLenghtError,
                          btnOkOnPress: () {},
                        )..show();
                        return;
                      }
                      await user.updateDisplayName(text);
                      setState(() {
                        usernameController.clear();
                      });
                      AwesomeDialog(
                        btnOkText: Language.okey,
                        context: context,
                        dialogType: DialogType.SUCCES,
                        animType: AnimType.BOTTOMSLIDE,
                        title: Language.success,
                        desc: Language.usernameChangeSuccess,
                        btnOkOnPress: () {},
                      )..show();
                    },
                    icon: Icon(
                      MdiIcons.update,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 75,
            ),
            Container(
              width: width / 1.1,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: Images.profileStatusBackground, fit: BoxFit.fill),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          AutoSizeText(
                            Language.gamesPlayed,
                            maxLines: 1,
                            maxFontSize: 25,
                            minFontSize: 20,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            Language.maximumPoint,
                            maxLines: 1,
                            maxFontSize: 25,
                            minFontSize: 20,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            Language.totalPoint,
                            maxLines: 1,
                            maxFontSize: 25,
                            minFontSize: 20,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            Language.pointAverage,
                            maxLines: 1,
                            maxFontSize: 25,
                            minFontSize: 20,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            Language.countOfTrues,
                            maxLines: 1,
                            maxFontSize: 25,
                            minFontSize: 20,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AutoSizeText(
                            Language.countOfFalses,
                            maxLines: 1,
                            maxFontSize: 25,
                            minFontSize: 20,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("userdata")
                            .doc(user.uid)
                            .snapshots(),
                        builder: (context, data) {
                          if (!data.hasData) {
                            return SpinKitFadingFour(
                              color: Colors.white,
                            );
                          }
                          DocumentSnapshot doc = data.data;
                          Map map = doc.data();

                          int pointPercentage = 0;

                          int playCount = map["play_count"];
                          int maxPoint = map["maximum_point"];
                          int totalPoint = map["total_point"];
                          int countOfTrue = map["true_answers"];
                          int countOfFalse = map["false_answers"];

                          if (playCount > 0) {
                            pointPercentage = totalPoint ~/ playCount;
                          }

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              AutoSizeText(
                                playCount.toString(),
                                maxLines: 1,
                                maxFontSize: 25,
                                minFontSize: 20,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AutoSizeText(
                                maxPoint.toString(),
                                maxLines: 1,
                                maxFontSize: 25,
                                minFontSize: 20,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AutoSizeText(
                                totalPoint.toString(),
                                maxLines: 1,
                                maxFontSize: 25,
                                minFontSize: 20,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AutoSizeText(
                                pointPercentage.toString(),
                                maxLines: 1,
                                maxFontSize: 25,
                                minFontSize: 20,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AutoSizeText(
                                countOfTrue.toString(),
                                maxLines: 1,
                                maxFontSize: 25,
                                minFontSize: 20,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AutoSizeText(
                                countOfFalse.toString(),
                                maxLines: 1,
                                maxFontSize: 25,
                                minFontSize: 20,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void uploadAnProfileImage(User user) async {
    ProggressDialog dialog = ProggressDialog(mainContext: this.context);
    dialog.show();
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    File file = File(pickedFile.path);
    String fileName = user.uid;
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String url = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      user.updatePhotoURL(url);
    });
    dialog.hide();
  }
}
