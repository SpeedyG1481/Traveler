import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveler/components/mega_dropdown.dart';
import 'package:traveler/data/ads.dart';
import 'package:traveler/data/constants.dart';
import 'package:traveler/data/data_model.dart';
import 'package:traveler/data/database_controller.dart';
import 'package:traveler/data/func.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/language/language.dart';
import 'package:traveler/models/city.dart';
import 'package:traveler/models/country.dart';
import 'package:traveler/models/state.dart';
import 'package:traveler/pages/main_page.dart';

class UploadPage extends StatefulWidget {
  final ParentMainPageState mainPage;

  UploadPage(this.mainPage);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  InterstitialAd promoteCityInterstitial;

  PickedFile uploadimage;
  Future<Uint8List> image;

  TextEditingController cityNameController = TextEditingController();
  TextEditingController photoUploaderNameController = TextEditingController();
  Future<List<String>> citiesFuture;
  String _currentCity;
  bool loading = false;
  bool isUploading = false;
  bool uploadStatus = false;
  bool lastUploadStatus = false;

  Future loadAd() async {
    if (Constants.canRemoveAds) {
      return;
    }

    InterstitialAd.load(
      adUnitId: Ads.getPromoteCityInterstitialId(),
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          this.promoteCityInterstitial = ad;
          showAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("AD Error: " + error.message);
        },
      ),
    );
  }

  Future showAd() async {
    if (this.promoteCityInterstitial != null) {
      await this.promoteCityInterstitial.show();
    }
  }

  @override
  void dispose() {
    if (promoteCityInterstitial != null) promoteCityInterstitial.dispose();
    super.dispose();
  }

  @override
  void initState() {
    this.loadAd();
    firstUpload();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          getBody(),
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
      ),
    );
  }

  void firstUpload() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool isFirst =
        preferences.getBool("IsTheFirstUploadFromThisPhone") == null ||
            !preferences.getBool("IsTheFirstUploadFromThisPhone");
    if (isFirst) {
      showPrivacyContent();
      preferences.setBool("IsTheFirstUploadFromThisPhone", true);
    }
  }

  void showPrivacyContent() async {
    List<Widget> contractBody = await Functions.getUserContract();
    AwesomeDialog(
      btnOkText: Language.okey,
      context: context,
      dialogType: DialogType.INFO,
      animType: AnimType.BOTTOMSLIDE,
      title: Language.contract,
      body: Column(
        children: contractBody,
      ),
      btnOkOnPress: () {},
    )..show();
  }

  void uploadAnImage() async {
    setState(() {
      isUploading = true;
    });

    if (uploadimage == null || _currentCity == null) {
      Fluttertoast.showToast(msg: Language.warningSelectProvince);
      setState(() {
        isUploading = false;
      });
      return;
    }

    List<int> imageBytes = await uploadimage.readAsBytes();

    var image = await decodeImageFromList(imageBytes);
    if (image.width < image.height) {
      Fluttertoast.showToast(msg: Language.warningUploadPhotoMustLandscape);
      setState(() {
        isUploading = false;
      });
      return;
    }
    int size = imageBytes.length;
    if (size > Constants.MaximumUploadSizeBytes) {
      Fluttertoast.showToast(
          msg: Language.warningMaximumUploadSize.replaceAll(
              "<arg_1>", Constants.MaximumUploadSizeMegaBytes.toString()));
      setState(() {
        isUploading = false;
      });
      return;
    }

    String stateString = _currentCity.split(" ").last.split("-")[2];
    String stateId = stateString.substring(0, stateString.length - 1);

    String baseimage = base64Encode(imageBytes);
    var response = await http.post(
      Uri.parse(
        Constants.userImageUploadURL,
      ),
      body: {
        "image": baseimage,
        "securityToken": Constants.securityToken,
        "uploader": await Functions.getDeviceDetails(),
        "cityId": stateId,
        "uploaderName": photoUploaderNameController.text,
      },
    );

    String body = response.body;
    setState(() {
      lastUploadStatus = true;
      if (body != "1" && body != "true") {
        lastUploadStatus = false;
      }

      _currentCity = null;
      cityNameController.clear();
      photoUploaderNameController.clear();
      isUploading = false;
      uploadStatus = true;
    });
  }

  Widget getBody() {
    return uploadimage == null ? selectButton() : showImage();
  }

  showImage() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(
          height: 50,
        ),
        Expanded(
          flex: 4,
          child: Container(
            padding: EdgeInsets.all(
              15,
            ),
            width: width / 1.05,
            child: FutureBuilder(
              future: image,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SpinKitCubeGrid(
                    color: Colors.white,
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                    image: DecorationImage(
                      image: Image.memory(
                        snapshot.data,
                        height: height,
                        width: width,
                        fit: BoxFit.fill,
                      ).image,
                      fit: BoxFit.fill,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            width: width / 2,
            child: getCities(),
          ),
        ),
      ],
    );
  }

  selectButton() {
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        padding: EdgeInsets.all(
          10,
        ),
        width: width / 1.45,
        decoration: BoxDecoration(
          color: Color(0xff0088FF).withOpacity(0.60),
          borderRadius: BorderRadius.circular(
            20,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Language.attention,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(
              height: 7.5,
            ),
            Text(
              Language.warningReadTermsOfUsage,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 25,
            ),
            GestureDetector(
              onTap: () {
                chooseImageGallery();
              },
              child: Container(
                width: width / 2,
                height: 50,
                child: Center(
                  child: Text(
                    Language.pickImage,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Images.bigButton,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                showPrivacyContent();
              },
              child: Container(
                width: width / 3,
                height: 35,
                child: Center(
                  child: Text(
                    Language.termsOfUsage,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Images.smallButton,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> chooseImageGallery() async {
    ImagePicker picker = ImagePicker();

    PickedFile choosedimage =
        await picker.getImage(source: ImageSource.gallery);

    setState(() {
      uploadimage = choosedimage;
      if (uploadimage != null) this.image = uploadimage.readAsBytes();
    });
  }

  Future<void> chooseImageCamera() async {
    ImagePicker picker = ImagePicker();

    PickedFile choosedimage = await picker.getImage(source: ImageSource.camera);
    setState(() {
      uploadimage = choosedimage;
      this.image = uploadimage.readAsBytes();
    });
  }

  getCities() {
    if (uploadStatus) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(
              10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                10,
              ),
              color: this.lastUploadStatus
                  ? Color(
                      0xff1C88FF,
                    )
                  : Colors.red,
            ),
            child: Center(
              child: Text(
                this.lastUploadStatus
                    ? Language.uploadPhotoSuccess
                    : Language.uploadPhotoUnsuccess,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        getTextField(
          contentPadding: 5.5,
          maxLines: 1,
          minLines: 1,
          hint: Language.whereIsHere,
          controller: cityNameController,
          onSubmitted: (String string) {
            getCityData(query: string);
          },
        ),
        SizedBox(
          height: 15,
        ),
        if (loading)
          SpinKitDualRing(
            color: Colors.white,
            size: 30,
          )
        else
          FutureBuilder(
            future: citiesFuture,
            builder: (BuildContext context, AsyncSnapshot<List<String>> data) {
              if (!data.hasData) {
                return Container();
              }
              return Column(
                children: [
                  MegaDropdown<String>(
                    mode: Mode.DIALOG,
                    showSelectedItem: true,
                    items: data.data,
                    hint: _currentCity,
                    onChanged: (String item) {
                      setState(() {
                        _currentCity = item;
                      });
                    },
                    selectedItem: _currentCity != null
                        ? _currentCity
                        : Language.chooseCity,
                    dropDownButton: Icon(
                      MdiIcons.selection,
                      size: 0,
                    ),
                    dropdownBuilder: (context, str, str1) {
                      return Text(
                        str1,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      );
                    },
                    contentPadding: 15,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  getTextField(
                    contentPadding: 5.5,
                    maxLines: 1,
                    hint: Language.wantToShareName,
                    controller: photoUploaderNameController,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  if (isUploading)
                    SpinKitDualRing(
                      color: Colors.white,
                    )
                  else
                    CircleAvatar(
                      child: IconButton(
                        icon: Icon(
                          MdiIcons.checkBold,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          //DOUBLE TAB ENGELLEME
                          if (isUploading) return;
                          uploadAnImage();
                        },
                      ),
                      backgroundColor: Color(0xff1C88FF),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  void getCityData({String query}) async {
    setState(() {
      loading = true;
      this.citiesFuture = null;
      _currentCity = null;
    });

    if (query != null && query.length >= 3) {
      List<String> mainList = [];

      List<String> totalQueries = [query];
      if (query.contains(" ")) {
        totalQueries.clear();
        totalQueries = query.split(" ");
      }

      String realQuery =
          "SELECT countries.name as countryName, states.name as stateName, cities.* FROM "
          "countries, states, cities WHERE cities.country_id = countries.id AND cities.state_id = states.id AND ";
      int i = 0;
      String inQuery = "";
      for (String key in totalQueries) {
        inQuery += "(states.name LIKE '%" +
            key +
            "%' OR cities.name LIKE '%" +
            key +
            "%' OR countries.name LIKE '%" +
            key +
            "%')";
        if (i < totalQueries.length - 1) {
          inQuery += " OR ";
        }
        i++;
      }
      realQuery += inQuery + " LIMIT 100";

      DataModel dataModel = await DatabaseController.query(realQuery);
      var states = dataModel.data;
      for (int i = 0; i < states.length; i++) {
        City city = City.fromMap(
          states[i],
          country: Country(
            name: states[i]["countryName"],
          ),
          state: Province(
            name: states[i]["stateName"],
          ),
        );

        mainList.add(city.name +
            "/" +
            city.state.name +
            " (" +
            city.country.name +
            "-" +
            city.countryCode +
            "-" +
            city.id.toString() +
            ")");
      }

      mainList.sort((a, b) => a.compareTo(b));

      setState(() {
        loading = false;
        this.citiesFuture = Future.value(mainList);
      });
    }
  }

  getTextField({
    double contentPadding,
    Color textColor = Colors.white,
    String hint,
    int maxLines = 1,
    int minLines = 1,
    TextEditingController controller,
    ValueChanged<String> onChanged,
    ValueChanged<String> onSubmitted,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Images.bigButton,
          fit: BoxFit.fill,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: TextStyle(
          fontSize: 15,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
        minLines: minLines,
        maxLines: maxLines,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp('[\'"/\\\\]')),
          LengthLimitingTextInputFormatter(
            32,
          ),
        ],
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: EdgeInsets.all(contentPadding),
          enabledBorder: InputBorder.none,
          errorMaxLines: 1,
          errorStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          labelStyle: TextStyle(
            fontSize: 13.5,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
          hintStyle: TextStyle(
            fontSize: 13.5,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
