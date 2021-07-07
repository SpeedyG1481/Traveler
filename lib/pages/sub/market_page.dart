import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

  bool firstLoading = true;
  bool canBuyOnThisPhone = false;

  Future<void> getProducts() async {
    Set<String> idS = Set.from([removeAdsId, reloadQuicknessId]);
    ProductDetailsResponse response = await iap.queryProductDetails(idS);
    setState(() {
      products = response.productDetails;
    });
  }

  Future<void> getPastPurchases() async {
    await iap.restorePurchases();
  }

  Future<void> verifyPurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == removeAdsId) {
    } else if (purchaseDetails.productID == reloadQuicknessId) {}
  }

  void initalizeIAP() async {
    setState(() {
      firstLoading = true;
    });
    canBuyOnThisPhone = await iap.isAvailable();

    if (canBuyOnThisPhone) {
      await getProducts();
      await getPastPurchases();

      final Stream purchaseUpdated = iap.purchaseStream;
      _subscription = purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (error) {
        canBuyOnThisPhone = false;
      });
    }
    setState(() {
      firstLoading = false;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("Burası show pending.");
        //_showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("An error occured.. 0x01");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await verifyPurchase(purchaseDetails);
          print("Ödül ikame edildi.");
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
          print("Satın alım tamamlandı..");
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
            child: firstLoading
                ? Center(
                    child: SpinKitFadingFour(
                      color: Colors.white,
                    ),
                  )
                : !canBuyOnThisPhone
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
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  //REMOVE ADS
                                  final PurchaseParam purchaseParam =
                                      PurchaseParam(
                                          productDetails: products[0]);
                                  InAppPurchase.instance.buyNonConsumable(
                                      purchaseParam: purchaseParam);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    top: 25,
                                    left: 25,
                                    right: 10,
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
                                    children: [
                                      AutoSizeText(
                                        "REMOVE",
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
                                        "ADS",
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
                                      Center(
                                        child: AutoSizeText(
                                          "2.99\$",
                                          maxLines: 1,
                                          maxFontSize: 35,
                                          minFontSize: 25,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 35,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: InkWell(
                                onTap: () async {
                                  //RELOAD QUICKNESS
                                  final PurchaseParam purchaseParam =
                                      PurchaseParam(
                                          productDetails: products[1]);
                                  InAppPurchase.instance.buyNonConsumable(
                                      purchaseParam: purchaseParam);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                    top: 25,
                                    left: 25,
                                    right: 10,
                                    bottom: 0,
                                  ),
                                  width: width / 1.5,
                                  height: height / 4,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: Images.marketVIP2),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AutoSizeText(
                                        "RELOAD",
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
                                        "QUICKNESS",
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
                                      Center(
                                        child: AutoSizeText(
                                          "2.99\$",
                                          maxLines: 1,
                                          maxFontSize: 35,
                                          minFontSize: 25,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 35,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
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
