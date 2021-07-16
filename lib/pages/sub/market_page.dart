import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:traveler/data/iap.dart';
import 'package:traveler/data/images.dart';
import 'package:traveler/language/language.dart';

final String removeAdsId = "com.mgs.traveler.removeads";
final String reloadQuicknessId = "com.mgs.traveler.reloadquickness";

class MarketPage extends StatefulWidget {
  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  InAppPurchase iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> products = [];

  bool canBuyOnThisPhone = false;
  bool restoreLoading = false;

  ProductDetails getProductByName(String name) {
    for (ProductDetails details in products) {
      if (details.id == name) {
        return details;
      }
    }
    return null;
  }

  Future<void> getProducts() async {
    Set<String> idS = Set.from([removeAdsId, reloadQuicknessId]);
    ProductDetailsResponse response = await iap.queryProductDetails(idS);
    setState(() {
      products = response.productDetails;
    });
    print("IAP Products Listed... Count: " + products.length.toString());
  }

  Future<void> getPastPurchases() async {
    await iap.restorePurchases();
  }

  Future<void> verifyPurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == removeAdsId) {
      print("IAP Remove ads given.");
      IAP.buyRemoveAds();
    } else if (purchaseDetails.productID == reloadQuicknessId) {
      print("IAP Reload quickness given.");
      IAP.buyReloadQuickness();
    }
  }

  void initalizeIAP() async {
    canBuyOnThisPhone = await iap.isAvailable();
    if (canBuyOnThisPhone) {
      await getProducts();

      final Stream purchaseUpdated = iap.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        canBuyOnThisPhone = false;
      });
    }

    setState(() {});
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("IAP Pending...");
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("IAP Error...");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          print("IAP Purchase or restore... : " +
              purchaseDetails.status.toString());
          await verifyPurchase(purchaseDetails);
        }
        if (purchaseDetails.pendingCompletePurchase) {
          print("IAP Purchase completing.");
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  @override
  void initState() {
    initalizeIAP();
    super.initState();
  }

  @override
  void dispose() {
    if (_subscription != null) _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Images.marketBackground,
              fit: BoxFit.fill,
            ),
          ),
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                !canBuyOnThisPhone
                    ? Center(
                        child: Container(
                          padding: EdgeInsets.all(
                            10,
                          ),
                          width: width / 1.25,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: Text(
                            Language.canNotBuyOnThisPhone,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Tooltip(
                              message: Language.removeAdsTooltip,
                              padding: EdgeInsets.all(
                                10,
                              ),
                              margin: EdgeInsets.all(10),
                              showDuration: Duration(seconds: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              textStyle: TextStyle(
                                color: Color(
                                  0xff1C88FF,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  if (await IAP.hasPurchased(removeAdsId)) {
                                    AwesomeDialog(
                                      btnOkText: Language.okey,
                                      context: context,
                                      dialogType: DialogType.WARNING,
                                      btnOkColor: Colors.orange,
                                      animType: AnimType.BOTTOMSLIDE,
                                      title: Language.warning,
                                      desc: Language.iapAlreadyPurchased,
                                      btnOkOnPress: () {},
                                    )..show();
                                    return;
                                  }

                                  //REMOVE ADS
                                  ProductDetails removeAdsDetails =
                                      getProductByName(removeAdsId);

                                  final PurchaseParam purchaseParam =
                                      PurchaseParam(
                                          productDetails: removeAdsDetails);
                                  await InAppPurchase.instance.buyNonConsumable(
                                      purchaseParam: purchaseParam);
                                },
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: 25,
                                      right: 25,
                                      bottom: 0,
                                    ),
                                    width: width / 1.5,
                                    height: height / 4,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: Images.marketVIP1),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AutoSizeText(
                                          Language.removeAdsLine1,
                                          maxLines: 1,
                                          maxFontSize: 40,
                                          minFontSize: 30,
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            foreground: Paint()
                                              ..shader = LinearGradient(
                                                colors: <Color>[
                                                  Color(0xffE26600),
                                                  Color(0xffFFE91C),
                                                  Color(0xffFFE91C),
                                                  Color(0xffFFE91C),
                                                  Color(0xffFF9700),
                                                  Color(0xffFF9700),
                                                  Color(0xffE26600),
                                                ],
                                              ).createShader(
                                                Rect.fromLTWH(
                                                  70.0,
                                                  50.0,
                                                  200.0,
                                                  70.0,
                                                ),
                                              ),
                                          ),
                                        ),
                                        AutoSizeText(
                                          Language.removeAdsLine2,
                                          maxLines: 1,
                                          maxFontSize: 40,
                                          minFontSize: 30,
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            foreground: Paint()
                                              ..shader = LinearGradient(
                                                colors: <Color>[
                                                  Color(0xffE26600),
                                                  Color(0xffFFE91C),
                                                  Color(0xffFFE91C),
                                                  Color(0xffFFE91C),
                                                  Color(0xffFF9700),
                                                  Color(0xffFF9700),
                                                  Color(0xffE26600),
                                                ],
                                              ).createShader(
                                                Rect.fromLTWH(
                                                  0.0,
                                                  65.0,
                                                  130.0,
                                                  70.0,
                                                ),
                                              ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Center(
                                          child: FutureBuilder(
                                            future:
                                                IAP.hasPurchased(removeAdsId),
                                            builder: (context, data) {
                                              if (!data.hasData) {
                                                return SpinKitDualRing(
                                                    color: Colors.white);
                                              }

                                              return products != null &&
                                                      products.length > 0
                                                  ? AutoSizeText(
                                                      data.data
                                                          ? Language.purchased
                                                          : getProductByName(
                                                                  removeAdsId)
                                                              .price,
                                                      maxLines: 1,
                                                      maxFontSize: 35,
                                                      minFontSize: 25,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 35,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : SpinKitDualRing(
                                                      color: Colors.white);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Tooltip(
                              message: Language.reloadQuicknessTooltip,
                              padding: EdgeInsets.all(
                                10,
                              ),
                              margin: EdgeInsets.all(10),
                              showDuration: Duration(seconds: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              textStyle: TextStyle(
                                color: Color(
                                  0xff1C88FF,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  if (await IAP
                                      .hasPurchased(reloadQuicknessId)) {
                                    AwesomeDialog(
                                      btnOkText: Language.okey,
                                      context: context,
                                      dialogType: DialogType.WARNING,
                                      btnOkColor: Colors.orange,
                                      animType: AnimType.BOTTOMSLIDE,
                                      title: Language.warning,
                                      desc: Language.iapAlreadyPurchased,
                                      btnOkOnPress: () {},
                                    )..show();
                                    return;
                                  }
                                  //RELOAD QUICKNESS

                                  ProductDetails reloadQuicknessDetails =
                                      getProductByName(reloadQuicknessId);

                                  final PurchaseParam purchaseParam =
                                      PurchaseParam(
                                          productDetails:
                                              reloadQuicknessDetails);
                                  InAppPurchase.instance.buyNonConsumable(
                                      purchaseParam: purchaseParam);
                                },
                                child: Center(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      left: 25,
                                      right: 25,
                                    ),
                                    width: width / 1.5,
                                    height: height / 4,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: Images.marketVIP2),
                                    ),
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AutoSizeText(
                                            Language.reloadQuicknessLine1,
                                            maxLines: 1,
                                            maxFontSize: 40,
                                            minFontSize: 30,
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              foreground: Paint()
                                                ..shader = LinearGradient(
                                                  colors: <Color>[
                                                    Color(0xffE26600),
                                                    Color(0xffFFE91C),
                                                    Color(0xffFFE91C),
                                                    Color(0xffFFE91C),
                                                    Color(0xffFF9700),
                                                    Color(0xffFF9700),
                                                    Color(0xffE26600),
                                                  ],
                                                ).createShader(
                                                  Rect.fromLTWH(
                                                    0.0,
                                                    0.0,
                                                    200.0,
                                                    70.0,
                                                  ),
                                                ),
                                            ),
                                          ),
                                          AutoSizeText(
                                            Language.reloadQuicknessLine2,
                                            maxLines: 1,
                                            maxFontSize: 40,
                                            minFontSize: 30,
                                            style: TextStyle(
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                              foreground: Paint()
                                                ..shader = LinearGradient(
                                                  colors: <Color>[
                                                    Color(0xffE26600),
                                                    Color(0xffFFE91C),
                                                    Color(0xffFFE91C),
                                                    Color(0xffFFE91C),
                                                    Color(0xffFF9700),
                                                    Color(0xffFF9700),
                                                    Color(0xffE26600),
                                                  ],
                                                ).createShader(
                                                  Rect.fromLTWH(
                                                    0.0,
                                                    0.0,
                                                    200.0,
                                                    70.0,
                                                  ),
                                                ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Center(
                                            child: FutureBuilder(
                                              future: IAP.hasPurchased(
                                                  reloadQuicknessId),
                                              builder: (context, data) {
                                                if (!data.hasData) {
                                                  return SpinKitDualRing(
                                                      color: Colors.white);
                                                }

                                                return products != null &&
                                                        products.length > 0
                                                    ? AutoSizeText(
                                                        data.data
                                                            ? Language.purchased
                                                            : getProductByName(
                                                                    reloadQuicknessId)
                                                                .price,
                                                        maxLines: 1,
                                                        maxFontSize: 35,
                                                        minFontSize: 25,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 35,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    : SpinKitDualRing(
                                                        color: Colors.white);
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
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
                Positioned(
                  right: 10,
                  top: 10,
                  child: Tooltip(
                    message: Language.restoreButtonTooltip,
                    padding: EdgeInsets.all(
                      10,
                    ),
                    margin: EdgeInsets.all(10),
                    showDuration: Duration(seconds: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                    ),
                    textStyle: TextStyle(
                      color: Color(
                        0xff1C88FF,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        if (restoreLoading) {
                          return;
                        }
                        setState(() {
                          restoreLoading = true;
                        });
                        await getPastPurchases();
                        setState(() {
                          restoreLoading = false;
                        });
                      },
                      child: CircleAvatar(
                        radius: 22,
                        child: restoreLoading
                            ? SpinKitHourGlass(
                                color: Color(0xff1C88FF),
                              )
                            : Icon(
                                MdiIcons.restart,
                                color: Color(0xff1C88FF),
                                size: 30,
                              ),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
